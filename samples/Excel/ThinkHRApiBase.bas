Attribute VB_Name = "ThinkHRApiBase"
' Code derived from the Canvas API Example at https://community.canvaslms.com/groups/canvas-developers/blog/2017/05/16/download-data-to-excel-using-vba-and-the-api-workbook-with-code-attached

Option Explicit

' For Testing Purposes
Const cEnableLogging = True

' Defs for API
Const cTimeoutMs = 10000
Const cLimit = 1000
Const cParamLimit = "limit"
Const cParamOffset = "offset"
Const cParamSort = "sort"
Const cParamActive = "isActive"
Const cParamBroker = "brokerId"
Const cParamCompany = "companyId"
Const cMaxRetries = 3

' Defs for layout
Const cRowStartOfData = "2"
Const cTitleRow = "5"
Const cProgressRow = "6"
Const cStatusRow = "7"
Const cDownloadColumn = "A"
Const cUploadColumn = "D"

' Defs for Display
Public Const cTitle = "ThinkHR"
Const cDownArrow = 8595
Const cUpArrow = 8593
Const cEventRows = 100 ' How many rows to update between event checks

' Defs for data processing
Const cSections = 4
Const cBrokerRow = 4
Const cBrokerColumn = 2
Const cBrokerRange = "A4:B4"

' Settings, stored in hidden Settings sheet
Dim sURL As String
Dim sClientId As String
Dim sClientSecret As String
Dim sUserName As String
Dim sPassword As String
Dim sRefreshToken As String
Dim sDefaultRole As String
Dim bIncludeInactives As Boolean
Dim lMaxFetch As Long

' Filter from Start sheet
Dim lBrokerId As Long

' Global Authenticator
Dim Auth As ThinkHRAuthenticator

Dim bProcessing As Boolean ' to prevent restarting while busy running
Dim bCanceled As Boolean ' indicates the download process has been canceled

' Sub OnWorkbookLoad()
' Purpose: Perform special handling when the workbook is loaded, insures we always start in a known state
Sub OnWorkbookLoad()
Dim sName As Variant

    While ThinkHRWorkbook.ProtectStructure
        ThinkHRWorkbook.Unprotect InputBox("Please enter the workbook password")
    Wend

    For Each sName In Array("Settings", "Original Configurations", "Original Companies", "Original Users")
        If ThinkHRWorkbook.Worksheets(sName).Visible <> xlSheetVeryHidden Then
            ThinkHRWorkbook.Worksheets(sName).Visible = xlSheetVeryHidden
        End If
    Next sName

    ProtectWorksheet ThinkHRWorkbook.Worksheets("Start")
    ProtectWorksheet ThinkHRWorkbook.Worksheets("Configurations")
    ProtectWorksheet ThinkHRWorkbook.Worksheets("Companies")
    ProtectWorksheet ThinkHRWorkbook.Worksheets("Users")
    ProtectWorksheet ThinkHRWorkbook.Worksheets("Issues")

    WebHelpers.EnableLogging = cEnableLogging

    LogWithTime "Opening Workbook w/Debugging Enabled", True

    Application.EnableEvents = True ' Just in case they've been previously disabled
End Sub

' Sub OnWorksheetChange()
' Purpose: When text on a worksheet changes add a comment to that cell the first time through
' Notes: This breaks Undo in the worksheet
Sub OnWorksheetChange(ByVal Target As Range)
Dim cTarget As Range
Dim bHeader As Boolean
Dim rCurrPos As Range: Set rCurrPos = Application.ActiveCell
Dim sValue As String
Dim bProtected As Boolean
Dim sOriginal As Worksheet

    bProtected = Target.Worksheet.ProtectContents    ' Remember what protect state we were in before we started.

    On Error GoTo ErrHandler

    EditWorksheetStart Target.Worksheet
    Set sOriginal = ThinkHRWorkbook.Worksheets("Original " & Target.Worksheet.Name)

    LogWithTime "Worksheet (" & rCurrPos.Worksheet.Name & ") Changed, current position is " & rCurrPos

    ' This can be tricky, we may get more than one cell.
    ' Process is basically the same
    '    * Undo the changes
    '    * For each changed cell record the old value
    '    * Redo the changes
    '    * For each changed cell check for a comment
    '        * if no comment, add one w/the old value
    '        * if comment exists, check to see if the new value matches the comment for an undo

    If Target.Cells.Count >= 1 Then
        For Each cTarget In Target.Cells
            sValue = sOriginal.Range(cTarget.Address).Value
            bHeader = (Not Cells(1, cTarget.Column).Comment Is Nothing)

            If bHeader Then ' Only process the cell, if the header has a comment in that column (i.e. it's a field we use)
                ' Someone changed something, add a comment to this cell containing the previous value
                ' If comment already exists we don't need to do anything
                If cTarget.Comment Is Nothing Then
                    If sValue = "" Then             ' Handle empty values
                        cTarget.AddComment " "
                    Else
                        cTarget.AddComment sValue   ' Save the old value as a comment
                    End If
                Else
                    ' If the new value is blank or the same as the value in the comment
                    ' the user undid a change so clear the comment
                    If cTarget.Comment.Text = cTarget.Value Or (cTarget.Value = "" And cTarget.Comment.Text = " ") Then
                        cTarget.ClearComments
                    End If
                End If
            End If
        Next cTarget
    End If

ErrHandler:
    If Err.Number <> 0 Then ErrMsgBox "OnWorksheetChange", Err
    If Not rCurrPos Is Nothing Then
        rCurrPos.Worksheet.Activate ' Just in case we changed sheets
        rCurrPos.Activate
    End If

    EditWorksheetStop Target.Worksheet

    If Not bProtected Then
        Target.Worksheet.Unprotect
    End If

    DoEvents
End Sub

' Sub EditSettings()
' Purpose: show the settings form, only if no data is being downloaded
Sub EditSettings()
    If bProcessing = True Then Exit Sub ' to prevent restarting while already running
    frmSettings.Show
    LoadSettings
End Sub

' Sub DownloadAll()
' Purpose: This is the main sub to download data from ThinkHR.
Sub DownloadAll()
Dim Sh As Worksheet
Dim iRecords As Long

    LogWithTime "DownloadAll Started"

    If bProcessing = True Then ' if true, this function is already running
        RequestAbortDownload 'pop the question if aborting the download is desired, if confirmed bCanceled will be set to yes
        LogWithTime "DownloadAll Aborted"
        Exit Sub ' to prevent restarting while already running
    End If

    On Error GoTo FinishUp

    Set Sh = ThinkHRWorkbook.Sheets("Start")

    bProcessing = True                  ' indicate DownloadAll is already running
    bCanceled = False                   ' reset the status
    LoadSettings
    If ValidateSettings = False Then
        frmSettings.Show                ' automatically open the settings window if no or incorrect settings are present
        GoTo FinishUp                   ' don't proceed downloading
    End If

    Sh.Unprotect  ' Unprotect the start sheet so we can update the stats

    lBrokerId = TrimValue(Sh.Cells(cBrokerRow, cBrokerColumn).Value)

    ClearStats

    UpdateDownloadProgress 0

    InitializeAuthentication

    iRecords = GetRecords(ThinkHRWorkbook.Sheets("Configurations"), "configurations", "+configurationId", 1)

    iRecords = GetRecords(ThinkHRWorkbook.Sheets("Companies"), "companies", "+companyId", 2)

    iRecords = GetRecords(ThinkHRWorkbook.Sheets("Users"), "users", "+userId", 3)

    iRecords = GetRecords(ThinkHRWorkbook.Sheets("Issues"), "issues", "+created", 4)

    UpdateDownloadProgress 100

    ThinkHRWorkbook.RefreshAll

FinishUp:
    If bCanceled = False And Err.Number <> 0 Then ErrMsgBox "DownloadAll", Err
    bProcessing = False ' to prevent restarting while already running

    ProtectWorksheet Sh  ' Protect the start sheet so users can't fudge the info

    LogWithTime "DownloadAll Finished"
End Sub

' Sub UploadAll()
' Purpose: This is the main sub to upload changed data to ThinkHR.
Sub UploadAll()
Dim Sh As Worksheet
Dim iRecords As Long
Dim iCurrentRow, iCurrentCol As Integer

    If bProcessing = True Then ' if true, this function is already running
        RequestAbortUpload 'pop the question if aborting the download is desired, if confirmed bCanceled will be set to yes
        Exit Sub ' to prevent restarting while already running
    End If

    On Error GoTo FinishUp

    bProcessing = True                  ' indicate DownloadAll is already running
    bCanceled = False                   ' reset the status
    LoadSettings
    If ValidateSettings = False Then
        frmSettings.Show                ' automatically open the settings window if no or incorrect settings are present
        GoTo FinishUp                   ' don't proceed downloading
    End If

    Set Sh = ThinkHRWorkbook.ActiveSheet

    Sh.Unprotect

    ClearUploadStats

    UpdateUploadProgress 0

    InitializeAuthentication

    iRecords = PutRecords(ThinkHRWorkbook.Sheets("Configurations"), "configurations", "configuration", 1)   ' Configurations first, in case we added new ones

    iRecords = PutRecords(ThinkHRWorkbook.Sheets("Companies"), "companies", "company", 2)   ' Companies next

    iRecords = PutRecords(ThinkHRWorkbook.Sheets("Users"), "users", "user", 3)      ' Users Last

    UpdateUploadProgress 100

FinishUp:
    If bCanceled = False And Err.Number <> 0 Then ErrMsgBox "UploadAll", Err
    bProcessing = False ' to prevent restarting while already running

    ProtectWorksheet Sh  ' Protect the start sheet so users can't fudge the info
End Sub

' Sub LoadSettings()
' Purpose: Load all settings in variables before downloading is possible. Each time the Download data is clicked this function is executed
Sub LoadSettings()
Dim Sh As Worksheet: Set Sh = ThinkHRWorkbook.Sheets("Settings")
Dim sStart As Worksheet: Set sStart = ThinkHRWorkbook.Sheets("Start")
Dim sOldUser As String: sOldUser = sUserName

    On Error GoTo FinishUp

    sURL = Sh.Cells(3, 2).Value
    sClientId = Sh.Cells(4, 2).Value
    sClientSecret = Sh.Cells(5, 2).Value
    sUserName = Sh.Cells(6, 2).Value
    sPassword = Sh.Cells(7, 2).Value
    sDefaultRole = Sh.Cells(8, 2).Value
    bIncludeInactives = Sh.Cells(9, 2).Value
    lMaxFetch = Sh.Cells(10, 2).Value
    sRefreshToken = Sh.Cells(11, 2).Value

    ' Based on the username we will either expose the broker filter or hide it
    'ThinkHRWorkbook.Sheets("Start").Unprotect
    If InStr(sUserName, "@thinkhr.com") Then
        sStart.Range(cBrokerRange).Font.Color = vbBlack
    Else
        sStart.Range(cBrokerRange).Font.Color = vbWhite
    End If

    ' In addition, if the username has changed, then clear the previous broker field value & reset the refresh token
    If sOldUser <> "" And sUserName <> sOldUser Then
        sStart.Cells(cBrokerRow, cBrokerColumn).Value = ""
    End If

FinishUp:
    If Err.Number <> 0 Then ErrMsgBox "LoadSettings", Err

End Sub

' Function ValidateSettings() As Boolean
' Purpose: validate the entered settings, if it returns false it will indicate that downloading data from ThinkHR will fail
Function ValidateSettings() As Boolean
    On Error GoTo FinishUp
    ValidateSettings = True

    ' validate the url. Url must start with https:// and the username, password, and role should be defined.
    If Not (InStr(1, sURL, "https://") = 1 And _
        InStr(1, sURL, ".") > 10 And _
            InStr(1, sURL, ".") < Len(sURL) - 2) Then
        ValidateSettings = False
    End If

    ' make sure a client id is provided
    If Len(sClientId) = 0 Then
        ValidateSettings = False
    End If

    ' make sure a client secret is provided
    If Len(sClientSecret) = 0 Then
        ValidateSettings = False
    End If

    ' make sure a username is provided
    If Len(sUserName) = 0 Then
        ValidateSettings = False
    End If

    ' make sure a password is provided
    If Len(sPassword) = 0 Then
        ValidateSettings = False
    End If

    ' make sure a default role is provided
    If Len(sDefaultRole) = 0 Then
        ValidateSettings = False
    End If

FinishUp:
    If Err.Number <> 0 Then ErrMsgBox "ValidateSettings", Err

End Function

' Function GetRecords(Sh As Worksheet, sType As String, sSort As String, iSection As Integer) As Long
' Purpose: performs API call to get the data of a specific type, sorted using sSort from the ThinkHR Platform
' Dependencies: WebResponse offered via https://github.com/VBA-tools/VBA-Web
Function GetRecords(Sh As Worksheet, sType As String, sSort As String, iSection As Integer) As Long
Dim Response As WebResponse
Dim iCount As Integer
Dim rHead As Range
Dim cRecords As Collection
Dim iOffset As Long: iOffset = 0
Dim iTotal As Long: iTotal = 0
Dim bTest As Boolean

    LogWithTime "Starting GetRecords - " & sType

    On Error GoTo FinishUp

    ClearDataWorksheet Sh
    Set rHead = Sh.Rows(1).SpecialCells(xlCellTypeComments)     ' Save some time and get the header only once
    bTest = (rHead(1, 1).Comment.Text = "companyId")  ' Special testing needed if processing Company records

    ' Testing
    If WebHelpers.EnableLogging Then
    Dim rCell As Range

        For Each rCell In rHead
            Debug.Print rCell.Value & " : " & rCell.Comment.Text
        Next rCell
        Debug.Print vbLf
    End If

LoadRecords:

    DoEvents                                            ' process any mouseclicks or keyboard strikes if any
    If bCanceled = True Then GoTo FinishUp              ' abort downloading if user requested to abort

    Set Response = SubmitListRequest("/v1/" & sType, lMaxFetch, iOffset, sSort)
    If Response.StatusCode = WebStatusCode.Ok Then ' Ok - 200
        If VBA.TypeName(Response.Data(sType)) <> "Empty" Then
            Set cRecords = Response.Data(sType)

            On Error Resume Next ' Just in case there is an error processing a record, continue w/the next record.

            DoEvents                                            ' process any mouseclicks or keyboard strikes if any
            If bCanceled = True Then GoTo FinishUp              ' abort downloading if user requested to abort

            iCount = UpdateWorksheet(Sh, rHead, cRecords, iOffset, bTest)

            If bTest And iCount <> cRecords.Count Then  ' If we are searching for Companies and we found the broker then stop looking
                bTest = False
            End If

            iTotal = iTotal + iCount
            iOffset = iOffset + cRecords.Count

            On Error GoTo FinishUp ' if an error happens now, resuming is pointless

            UpdateStats cStatusRow + iSection - 1, cDownloadColumn, cDownArrow, iTotal, sType

            UpdateDownloadProgress ((iSection - 1) / cSections + (iOffset / Response.Data("totalRecords") / cSections)) * 100

            If Response.Data("limit") = cRecords.Count Then
                GoTo LoadRecords
            End If
        Else
            UpdateDownloadProgress iSection / cSections * 100
        End If
    Else
        LogWithTime "Failed Response - " & Response.Body
        ResponseStatusErrorMsg Response.StatusCode, Response.Data
    End If

    Sh.Cells.EntireColumn.AutoFit

    DoEvents                                            ' process any mouseclicks or keyboard strikes if any
    If bCanceled = True Then GoTo FinishUp              ' abort downloading if user requested to abort

FinishUp:
    If Err.Number <> 0 Then ErrMsgBox "GetRecords", Err
    If iOffset > 0 Then GetRecords = iOffset

    BackupRecords Sh

    LogWithTime "Ending GetRecords - " & sType & " - " & GetRecords & " Records Processed", True
End Function

' Function PutRecords(Sh As Worksheet, sApi As String, sEntity As String, iSection As Integer) As Long
' Purpose: performs API call to put the changed data of a specific entity into the ThinkHR Platform
' Dependencies: WebResponse offered via https://github.com/VBA-tools/VBA-Web
Function PutRecords(Sh As Worksheet, sApi As String, sEntity As String, iSection As Integer) As Long
Dim iCount As Long: iCount = 0
Dim rHead As Range
Dim rMatch As Range
Dim rRow As Range
Dim rCell As Range
Dim sEntityProper As String
Dim sChange As String
Dim iTotalRows As Long: iTotalRows = 0
Dim iLastRow As Long: iLastRow = 0

    LogWithTime "Starting PutRecords - " & sApi

    PutRecords = 0

    On Error GoTo FinishUp

    Set rHead = Sh.Rows(1).SpecialCells(xlCellTypeComments)     ' Only get the Header info once.
    Set rMatch = Sh.Rows("2:" & Sh.Rows.Count).SpecialCells(xlCellTypeComments)  ' Find all cells which have changed, skip the header

    sEntityProper = StrConv(sEntity, vbProperCase)
    sChange = sEntityProper & " changes"

    For Each rRow In rMatch.Rows    ' Calculate the number of affected rows based on the matched areas
        If rRow.Row <> iLastRow Then
            iTotalRows = iTotalRows + 1
            iLastRow = rRow.Row
        End If
    Next rRow

    If MsgBox("Preparing to upload " & rMatch.Count & " " & sChange & " for " & iTotalRows & " " & sEntityProper & " record(s).  Proceed?", _
                vbYesNo, "Upload " & sChange) <> vbYes Then
        UpdateStats cStatusRow + iSection - 1, cUploadColumn, cUpArrow, PutRecords, sApi
        UpdateUploadProgress ((iSection - 1) / cSections + (1 / cSections)) * 100
        GoTo FinishUp
    End If

    iLastRow = 0
    For Each rRow In rMatch.Rows
        If rRow.Row <> iLastRow Then
            iLastRow = rRow.Row

            ' Because we may get multiple areas within a single row, we're going to pass the row number instead of the cells
            If UploadRecord(Sh, rHead, iLastRow, sApi, sEntity) Then
                PutRecords = PutRecords + 1
            End If
        End If

        iCount = iCount + 1 ' Always count the work

        UpdateStats cStatusRow + iSection - 1, cUploadColumn, cUpArrow, PutRecords, sApi

        UpdateUploadProgress ((iSection - 1) / cSections + (iCount / rMatch.Count / cSections)) * 100

        DoEvents                                            ' process any mouseclicks or keyboard strikes if any
        If bCanceled = True Then GoTo FinishUp              ' abort downloading if user requested to abort
    Next rRow

FinishUp:
    If Err.Number = 1004 Then   ' Special Case - Nothing to do, just return 0 for records updated
        UpdateStats cStatusRow + iSection - 1, cUploadColumn, cUpArrow, 0, sApi
        UpdateUploadProgress (iSection / cSections) * 100
    ElseIf Err.Number <> 0 Then
        ErrMsgBox "PutRecords", Err
    End If

    LogWithTime "Finished PutRecords - " & sApi, True

End Function

' Function UploadRecord(Sh As Worksheet, rHead As Range, iRow As Long, sApi As String, sEntity As String) As Boolean
' Purpose: Retrieve all updated cells from the provided Worksheet and send to ThinkHR, returns True if successful
Function UploadRecord(Sh As Worksheet, rHead As Range, iRow As Long, sApi As String, sEntity As String) As Boolean
Dim Response As WebResponse
Dim rCell As Range
Dim rMatch As Range
Dim i As Integer: i = 0
Dim sName As String
Dim sValue As String
Dim oRecord As New Dictionary
Dim sBody As String: sBody = ""
Dim aFields() As String
Dim oTemp As Object
Dim sField As String
Dim sEndpoint As String
Dim bDeactivate As Boolean: bDeactivate = False

    On Error GoTo FinishUp

    EditWorksheetStart Sh

    UploadRecord = True ' Start off assuming we'll be successful

    sEndpoint = "/v1/" & sApi & "/" & Sh.Cells(iRow, 1).Value

    Set rMatch = Sh.Rows(iRow).SpecialCells(xlCellTypeComments)  ' Find all cells which have changed, skip the header

    For Each rCell In rMatch
        sName = rHead.Columns(rCell.Column).Comment.Text
        sValue = Trim(rCell.Value)

        ' Special handling for Active field - needs to be done separately, via patch
        If sName = "isActive" Then
            If sValue = "True" Then 'Reactivate before performing other updates
                Set Response = SubmitActiveRequest(sEndpoint, True)
                If Response.StatusCode <> WebStatusCode.Ok Then ' We failed - not Ok - 200
                    UploadRecord = False
                    ResponseStatusErrorMsg Response.StatusCode, Response.Data
                    GoTo FinishUp
                End If
            Else
                bDeactivate = True  ' Deactivate after making other updates
            End If
            GoTo NextField
        End If

        If InStr(sName, ".") Then  ' Nested Field
            aFields = Split(sName, ".")
            Set oTemp = oRecord

            For i = LBound(aFields) To UBound(aFields) - 1
                sField = aFields(i)

                If Not oTemp.Exists(sField) Then
                    oTemp.Add sField, New Dictionary
                End If
                Set oTemp = oTemp(sField)
            Next i
            oTemp.Add aFields(i), sValue
        Else
            oRecord.Add sName, sValue
        End If

NextField:
    Next rCell

    ' If we have changes to make, submit them now.
    If Not oRecord Is Nothing And oRecord.Count > 0 Then
        Set Response = SubmitUpdateRequest(sEndpoint, WebHelpers.ConvertToJson(oRecord))
        If Response.StatusCode = WebStatusCode.Ok Then ' Ok - 200
            If VBA.TypeName(Response.Data(sEntity)) <> "Empty" Then
                Dim nRecord As Object

                Set nRecord = Response.Data(sEntity)

               ' Check each cell and clear the comments if updated correctly.
               ' Consider it successful only if ALL fields were updated.
                For Each rCell In rMatch.Cells
                    Dim sNewValue As String

                    sName = rHead.Columns(rCell.Column).Comment.Text
                    sValue = Trim(rCell.Value)

                    ' Special handling for Active field - skip it during validation here as we handle it elsewhere
                    If sName = "isActive" Then
                        GoTo NextValidation
                    End If

                    If InStr(sName, ".") Then  ' Nested Field
                        aFields = Split(sName, ".")
                        Set oTemp = oRecord

                        For i = LBound(aFields) To UBound(aFields) - 1
                            sField = aFields(i)

                            If Not oTemp.Exists(sField) Then
                                UploadRecord = False    ' Expected field missing - FAIL
                                Exit For
                            Else
                                Set oTemp = oTemp(sField)
                            End If
                        Next i

                        sNewValue = oTemp(aFields(i))
                    Else
                        sNewValue = oRecord(sName)
                    End If

                    If UploadRecord And sNewValue <> sValue Then
                        UploadRecord = False
                        Exit For
                    End If

NextValidation:
                Next rCell
            Else
                UploadRecord = False
            End If
        Else
            UploadRecord = False
            ResponseStatusErrorMsg Response.StatusCode, Response.Data
            GoTo FinishUp
        End If
    End If

    ' Now that possible updates are completed, deactivate if requested
    If UploadRecord And bDeactivate Then
        Set Response = SubmitActiveRequest(sEndpoint, False)
        If Response.StatusCode <> WebStatusCode.Ok Then ' We failed - not Ok - 200
            UploadRecord = False
            ResponseStatusErrorMsg Response.StatusCode, Response.Data
            GoTo FinishUp
        End If
    End If

    If UploadRecord Then
        rMatch.ClearComments
    End If

    DoEvents                                            ' process any mouseclicks or keyboard strikes if any
    If bCanceled = True Then GoTo FinishUp              ' abort downloading if user requested to abort

FinishUp:
    If Err.Number <> 0 Then ErrMsgBox "UploadRecord", Err

    EditWorksheetStop Sh
End Function

' Function UpdateWorksheet(Sh As Worksheet, rHead As Range, cRecords As Collection, iOffset As Long, bTest As Boolean) As Long
' Purpose: Load the specified worksheet starting at the offset (+ the header, of course) w/information of sType from the provided cRecords collection
Function UpdateWorksheet(Sh As Worksheet, rHead As Range, cRecords As Collection, iOffset As Long, bTest As Boolean) As Long
Dim oRecord As Object
Dim rCell As Range
Static iRow As Long
Dim aFields() As String

    ' Reset our starting row when the offset = 0, first call in series
    If iOffset = 0 Then
        iRow = 2
    End If

    LogWithTime "Updating Worksheet - " & cRecords.Count & " Records"

    EditWorksheetStart Sh

    UpdateWorksheet = 0

    On Error GoTo FinishUp

    For Each oRecord In cRecords
        ' Special case, don't include the company record for the broker themselves
        If bTest Then
            If oRecord("companyId") = oRecord("brokerId") Then
                bTest = False   ' Found it - Don't do this test again
                GoTo NextRecord
            End If
        End If

        For Each rCell In rHead
            Dim sField As String: sField = rCell.Comment.Text
            Dim rDest As Range: Set rDest = Sh.Cells(iRow, rCell.Column)

            If Left(sField, 1) <> "=" And InStr(sField, ",") Then    ' Formula Field, Inline
                aFields = Split(sField, ",", 2)

                Dim sValue As String: sValue = oRecord(aFields(0))

                If sValue <> "" Then
                    rDest.Value = Replace(aFields(1), aFields(0), oRecord(aFields(0)))
                End If
            ElseIf InStr(sField, "=") Then                      ' Formula Field, Reference
                rDest.Value = Replace(sField, "1,", iRow & ",")
            ElseIf InStr(sField, ".") Then                      ' Nested Field
                Dim oTemp As Object: Set oTemp = oRecord
                Dim i As Integer

                aFields = Split(sField, ".")

                For i = LBound(aFields) To UBound(aFields) - 1
                    Set oTemp = oTemp(aFields(i))
                    If oTemp Is Nothing Then
                        Exit For
                    End If
                Next i

                If oTemp Is Nothing Then
                    rDest.Value = ""
                Else
                    rDest.Value = TrimValue(oTemp(aFields(i)))
                End If
            Else
                rDest.Value = TrimValue(oRecord(sField))
            End If
        Next rCell

        iRow = iRow + 1
        UpdateWorksheet = UpdateWorksheet + 1

NextRecord:
        If iRow Mod cEventRows = 0 Then             ' check for events every 10 rows
            DoEvents                                ' process any mouseclicks or keyboard strikes if any
            If bCanceled = True Then GoTo FinishUp  ' abort downloading if user requested to abort
        End If
    Next oRecord

FinishUp:
    If Err.Number <> 0 Then ErrMsgBox "UpdateWorksheet", Err

    EditWorksheetStop Sh

    LogWithTime "Updating Worksheet Complete", True
End Function

' Sub BackupRecords( Sh As Worksheet )
' Purpose: Make a backup of the data on a worksheet so we can compare against it.
Sub BackupRecords(Sh As Worksheet)
Dim sBackup As Worksheet

    On Error GoTo FinishUp

    LogWithTime "BackupRecords (" & Sh.Name & ") Started"

    Application.EnableEvents = False

    On Error Resume Next    ' In the event of an error, go to the next line

    Set sBackup = ThisWorkbook.Sheets("Original " & Sh.Name)

    On Error GoTo FinishUp  ' Reset error handling for this procedure

    If Not sBackup Is Nothing Then
        sBackup.UsedRange.ClearContents

        Sh.Cells.Copy sBackup.Cells
    End If

FinishUp:
    If Err.Number <> 0 Then ErrMsgBox "BackupRecords", Err

    Application.EnableEvents = True

    LogWithTime "BackupRecords (" & Sh.Name & ") Completed"
End Sub

' Sub ClearAll()
' Purpose: Clears all data sheets and removes all values from the hidden Settings sheet.
Sub ClearAll()

    If MsgBox("You are about to clear all data AND settings from this workbook." & vbCrLf & _
            "Are you sure you want to remove everything?", _
                vbYesNo, "Delete it ALL") = vbYes Then

        Application.EnableEvents = False    ' Disable events while we process

        ClearDataWorksheet ThinkHRWorkbook.Sheets("Configurations")
        ClearDataWorksheet ThinkHRWorkbook.Sheets("Companies")
        ClearDataWorksheet ThinkHRWorkbook.Sheets("Users")
        ClearDataWorksheet ThinkHRWorkbook.Sheets("Issues")

        ClearRange ThinkHRWorkbook.Sheets("Settings").Range("B3:B11")

        ClearStats

        Application.EnableEvents = True     ' Enable events now that we're done
    End If

End Sub

' Sub ClearDataWorksheet(Sh As Worksheet)
' Purpose: Clears a data sheet before loading with new data
Sub ClearDataWorksheet(Sh As Worksheet)
Dim wCurrSheet As Worksheet: Set wCurrSheet = ActiveWorkbook.ActiveSheet    ' Save where we currently are

    LogWithTime "ClearDataWorksheet (" & Sh.Name & ") Started"

    EditWorksheetStart Sh

    ' Clear any filters which might be active.
    Sh.AutoFilter.ShowAllData

    Sh.Select
    Sh.Range("A2").Select   ' Select the first cell in the sheet

    ' We have a header, so clear everything underneath it.
    ClearRange Sh.Range("2:" & Sh.Rows.Count)

    ' reset column widths
    Sh.Cells.EntireColumn.AutoFit

    wCurrSheet.Activate ' Return focus to where we started

    EditWorksheetStop Sh

    LogWithTime "ClearDataWorksheet (" & Sh.Name & ") Finished", True
End Sub

' Sub ClearRange( rSelection As Range )
' Purpose: Clears the provided range of all content and comments
Sub ClearRange(rSelection As Range)
    rSelection.ClearContents
    rSelection.ClearComments
End Sub

' Sub ClearStats()
' Purpose: Clears all stats from the Start data sheet before loading the workbook with new data
Sub ClearStats()
Dim Sh As Worksheet: Set Sh = ThinkHRWorkbook.Sheets("Start")
    LogWithTime "ClearStats (" & Sh.Name & ") Started"

    ClearRange Sh.Range(cTitleRow & ":" & (cTitleRow + cSections + 3))

    LogWithTime "ClearStats (" & Sh.Name & ") Finished", True
End Sub

' Sub ClearUploadStats()
' Purpose: Clears the upload stats from the Start data sheet before updating with new data
Sub ClearUploadStats()
Dim Sh As Worksheet: Set Sh = ThinkHRWorkbook.Sheets("Start")
    LogWithTime "ClearUploadStats (" & Sh.Name & ") Started"

    ClearRange Sh.Range(cUploadColumn & cTitleRow & ":" & cUploadColumn & Sh.Rows.Count)

    LogWithTime "ClearUploadStats (" & Sh.Name & ") Finished", True
End Sub

' Sub EditWorksheetStart( Sh As Worksheet )
' Purpose: Protect a data worksheet so that it's usable but safe
Sub EditWorksheetStart(Sh As Worksheet)
    LogWithTime "EditWorkSheetStart (" & Sh.Name & ") Called"

    Application.EnableEvents = False    ' Disable events while we process
    Application.ScreenUpdating = False  ' Disable screen events while we process
    Sh.Unprotect                        ' Unprotect the sheet so we can edit
End Sub

' Sub EditWorksheetStop( Sh As Worksheet )
' Purpose: Protect a data worksheet so that it's usable but safe
Sub EditWorksheetStop(Sh As Worksheet)
    ProtectWorksheet Sh                 ' Protect the worksheet again
    Application.ScreenUpdating = True   ' Enable screen events now that we're done
    Application.EnableEvents = True     ' Enable events now that we're done

    LogWithTime "EditWorkSheetStop (" & Sh.Name & ") Called", True
End Sub

' Sub ErrMsgBox( sName As String, Err As ErrObject )
' Purpose: Display Errors consistently
Sub ErrMsgBox(sName As String, eErr As ErrObject)
    MsgBox "An error occurred in " & sName & "." & vbCrLf & eErr.Description
End Sub

' Sub InititalizeAuthentication
' Purpose: Initialize the Authentication handler for the web requests.  The Token should last long enough to complete a serious of tasks
' Dependencies: Several modules offered via https://github.com/VBA-tools/VBA-Web (WebHelpers, WebClient, WebRequest, WebResponse, etc.)
Sub InitializeAuthentication()
    Set Auth = New ThinkHRAuthenticator
    Auth.Setup sURL, sClientId, sClientSecret, sUserName, sPassword, sRefreshToken
End Sub

' Sub ProtectWorksheet ( Sh As Worksheet )
' Purpose: Protect a data worksheet so that it's usable but safe
Sub ProtectWorksheet(Sh As Worksheet)
    Sh.Unprotect    ' Unprotect the sheet to reset things
    Sh.Protect UserInterfaceOnly:=True, AllowSorting:=True, AllowFiltering:=True ' Protect the sheet so that VBA can make changes and users can sort, filter and edit the unlocked fields.
End Sub

' Function SubmitActiveRequest(sEndpoint As String, bValue As Boolean) As WebResponse
' Purpose: Submits a request to (de)activate an object at the provided endpoint and returns the response object
' Dependencies: Several modules offered via https://github.com/VBA-tools/VBA-Web (WebHelpers, WebClient, WebRequest, WebResponse, etc.)
Function SubmitActiveRequest(sEndpoint As String, bValue As Boolean) As WebResponse
Dim dActive As New Dictionary: dActive.Add "isActive", IIf(bValue, 1, 0)

    Set SubmitActiveRequest = SubmitRequest(WebMethod.HttpPatch, sEndpoint, , WebHelpers.ConvertToJson(dActive))
End Function

' Function SubmitCreateRequest(sEndpoint As String, sBody As String) As WebResponse
' Purpose: Submits a request to create an object to the provided endpoint and returns the response object
' Dependencies: Several modules offered via https://github.com/VBA-tools/VBA-Web (WebHelpers, WebClient, WebRequest, WebResponse, etc.)
Function SubmitCreateRequest(sEndpoint As String, sBody As String) As WebResponse
    Set SubmitCreateRequest = SubmitRequest(WebMethod.HttpPost, sEndpoint, , sBody)
End Function

' Function SubmitListRequest(sEndpoint As String, Optional iLimit As Variant, Optional iOffset As Variant, Optional sSort As Variant) As WebResponse
' Purpose: Submits a request to retrieve objects from the provide dendpoint and returns the response object
' Dependencies: Several modules offered via https://github.com/VBA-tools/VBA-Web (WebHelpers, WebClient, WebRequest, WebResponse, etc.)
Function SubmitListRequest(sEndpoint As String, Optional iLimit As Variant, Optional iOffset As Variant, Optional sSort As Variant) As WebResponse
Dim dParams As New Dictionary

    If IsMissing(iLimit) Or iLimit = 0 Then
        dParams.Add cParamLimit, cLimit
    Else
        dParams.Add cParamLimit, iLimit
    End If

    If Not IsMissing(iOffset) Then
        dParams.Add cParamOffset, iOffset
    End If

    If Not IsMissing(sSort) Then
        dParams.Add cParamSort, sSort
    End If

    If InStr(1, sEndpoint, "/issues") = 0 Then              ' Special case - Issues don't have an isActive column
        If Not bIncludeInactives Then
            dParams.Add cParamActive, 1
        End If
    End If

    If lBrokerId > 0 Then
        If InStr(1, sEndpoint, "/configurations") Then      ' Special case - configuration API is inconsistent and doesn't use brokerId, only companyId.
            dParams.Add cParamCompany, lBrokerId
        Else
            dParams.Add cParamBroker, lBrokerId
        End If
    End If

    Set SubmitListRequest = SubmitRequest(WebMethod.HttpGet, sEndpoint, dParams)
End Function

' Function SubmitUpdateRequest(sEndpoint As String, sBody As String) As WebResponse
' Purpose: Submits a request to update an object to the provided endpoint and returns the response object
' Dependencies: Several modules offered via https://github.com/VBA-tools/VBA-Web (WebHelpers, WebClient, WebRequest, WebResponse, etc.)
Function SubmitUpdateRequest(sEndpoint As String, sBody As String) As WebResponse
    Set SubmitUpdateRequest = SubmitRequest(WebMethod.HttpPut, sEndpoint, , sBody)
End Function

' Function SubmitRequest(Method As WebMethod, sEndpoint As String, dParams As Dictionary, sBody As String) As WebResponse
' Purpose: Submits a request to the provided endpoint and returns the response object
' Dependencies: Several modules offered via https://github.com/VBA-tools/VBA-Web (WebHelpers, WebClient, WebRequest, WebResponse, etc.)
Function SubmitRequest(Method As WebMethod, sEndpoint As String, Optional dParams As Dictionary = Nothing, Optional sBody As String = "") As WebResponse
Dim Client As New WebClient
Dim Request As New WebRequest
Dim sKey As Variant
Dim iRetry As Integer: iRetry = 0

    Client.BaseUrl = sURL
    Client.TimeoutMs = cTimeoutMs
    Set Client.Authenticator = Auth

    Request.Resource = sEndpoint
    Request.Method = Method
    Request.Format = WebFormat.json
    Request.ResponseFormat = WebFormat.json

    If Not dParams Is Nothing Then
        For Each sKey In dParams.Keys
            Request.AddQuerystringParam CStr(sKey), dParams(sKey)
        Next sKey
    End If

    If sBody <> "" Then
        Request.Body = sBody
    End If

    LogWithTime "Submitting request - " & sEndpoint

    WebHelpers.EnableLogging = False

SubmitRequest:

    Set SubmitRequest = Client.Execute(Request)

    If Err.Number = 0 And SubmitRequest.StatusCode = 502 Then
        iRetry = iRetry + 1
        If iRetry < cMaxRetries Then
            LogWithTime "Gateway error - retrying"
            GoTo SubmitRequest
        End If
     ElseIf Err.Number <> 0 Or SubmitRequest.StatusCode <> WebStatusCode.Ok Then
        WebHelpers.EnableLogging = True
        WebHelpers.LogRequest Client, Request
        WebHelpers.LogResponse SubmitRequest
    End If

    If Auth.RefreshToken <> ThinkHRWorkbook.Sheets("Settings").Cells(11, 2).Value Then  ' Update the refresh token
        ThinkHRWorkbook.Sheets("Settings").Cells(11, 2).Value = Auth.RefreshToken
    End If

    WebHelpers.EnableLogging = cEnableLogging

    LogWithTime "Submit request finished - " & sEndpoint, True

End Function

' Sub RequestAbortDownload()
' Purpose: Prompts to stop processing upload any further
Sub RequestAbortDownload()
    If MsgBox("Downloading data from ThinkHR is still in progress." & vbCrLf & _
            "Are you sure to abort downloading?", _
                vbYesNo, "Abort download") = vbYes Then
        bCanceled = True
    End If
End Sub

' Sub RequestAbortUpload()
' Purpose: Prompts to stop processing upload any further
Sub RequestAbortUpload()
    If MsgBox("Uploading data to ThinkHR is still in progress." & vbCrLf & _
            "Are you sure to abort uploading?", _
                vbYesNo, "Abort download") = vbYes Then
        bCanceled = True
    End If
End Sub

' Sub ResponseStatusErrorMsg(ErrorCode As String, oResponse As Object)
' Purpose: Displays a message in case of any connection errors
Sub ResponseStatusErrorMsg(StatusCode As String, oResponse As Object)
Dim ErrorMsg As String
Dim StatusDescription As String

    If StatusCode = 401 Then ' We'll eventually catch this and handle it gracefully, but until then
        MsgBox "Authentication token expired, exiting"
        bCanceled = True
    ElseIf StatusCode = 404 Then ' If the record can't be found just log it and keep going
        WebHelpers.LogWarning "Record not found, continuing : " & oResponse("message")
    Else
        StatusDescription = oResponse("status")
        If oResponse("message") <> Empty Then
            StatusDescription = StatusDescription & " - " & oResponse("message")
        End If
        If oResponse("exceptionDetail") <> Empty Then
            StatusDescription = StatusDescription & " - " & oResponse("exceptionDetail")
        End If
        If oResponse("error") <> Empty Then
            StatusDescription = StatusDescription & " - " & oResponse("error")
        End If

        ErrorMsg = "ThinkHR returned the message: " & Trim(Str(StatusCode)) & " - " & StatusDescription
        ErrorMsg = ErrorMsg & vbCrLf & "Would you like to abort?"
        If MsgBox(ErrorMsg, vbYesNo, "Unable to complete the request") = vbYes Then
            bCanceled = True
        End If
    End If
End Sub

' Function TrimValue(Source As Variant) As String
' Purpose: Trim a value and return it as a string.  If no value present, return an empty string.
Function TrimValue(Source As Variant) As String
Dim SourceType As String

    SourceType = VBA.TypeName(Source)
    TrimValue = ""

    On Error GoTo FinishUp

    If SourceType = "String" Then
        TrimValue = Trim(Source)
    ElseIf SourceType <> "Empty" Then
        TrimValue = Trim(Str(Source))
    End If

FinishUp:
    If Err.Number <> 0 Then ErrMsgBox "TrimValue", Err

End Function

' Sub UpdateDownloadProgress(iPercent As Double)
' Purpose: Updates the percentage of the download progress in cell A6
Sub UpdateDownloadProgress(iPercent As Double)
Dim Sh As Worksheet: Set Sh = ThinkHRWorkbook.Sheets("Start")

    If iPercent >= 0 Then
        Sh.Cells(cProgressRow, 1).Value = iPercent / 100
        Sh.Cells(cProgressRow, 2).Value = "downloaded"
    End If

    If iPercent = 0 Then     ' We're starting, timestamp it
        Sh.Cells(cProgressRow + cSections + 1, 1).Value = "Started"
        Sh.Cells(cProgressRow + cSections + 1, 2).Value = Now
    ElseIf iPercent = 100 Then  ' We're done, timestamp it
        Sh.Cells(cProgressRow + cSections + 2, 1).Value = "Completed"
        Sh.Cells(cProgressRow + cSections + 2, 2).Value = Now
    End If
End Sub

' Sub UpdateStats(iRow As Integer, iColumn As Integer, iArrow As Integer, iCount As Long, sType As String)
' Purpose: Update the statistics about how many of an item were downloaded/uploaded
Sub UpdateStats(iRow As Integer, sColumn As String, iArrow As Integer, iCount As Long, sType As String)
Dim Sh As Worksheet: Set Sh = ThinkHRWorkbook.Sheets("Start")
Dim iColumn As Integer: iColumn = Range(sColumn & "1").Column       'Column is a name (e.g. D) and we need it to be a number (e.g. 4)
Dim rTargetA As Range: Set rTargetA = Sh.Cells(iRow, iColumn)
Dim rTargetB As Range: Set rTargetB = Sh.Cells(iRow, iColumn + 1)

    rTargetA.HorizontalAlignment = xlRight
    rTargetA.VerticalAlignment = xlTop
    rTargetA.Value = ChrW(iArrow) & " " & Trim(Str(iCount)) ' display the number of records

    rTargetB.HorizontalAlignment = xlLeft
    rTargetB.VerticalAlignment = xlTop
    rTargetB.Value = StrConv(sType, vbProperCase)           ' Capitalize the type of record
End Sub

' Sub UpdateUploadProgress(iPercent As Double)
' Purpose: Updates the percentage of the upload progress in cell D6
Sub UpdateUploadProgress(iPercent As Double)
Dim Sh As Worksheet: Set Sh = ThinkHRWorkbook.Sheets("Start")

    If iPercent >= 0 Then
        Sh.Cells(cProgressRow, 4).Value = iPercent / 100
        Sh.Cells(cProgressRow, 5).Value = "uploaded"
    End If

    If iPercent = 0 Then     ' We're starting, timestamp it
        Sh.Cells(cProgressRow + cSections + 1, 4).Value = "Started"
        Sh.Cells(cProgressRow + cSections + 1, 5).Value = Now
    ElseIf iPercent = 100 Then  ' We're done, timestamp it
        Sh.Cells(cProgressRow + cSections + 2, 4).Value = "Completed"
        Sh.Cells(cProgressRow + cSections + 2, 5).Value = Now
    End If
End Sub

' Sub DebugPrintDictColl(ByVal Obj As Object, Optional Depth As Long = 0)
' Purpose: Recursive Sub to iterate through all items from the Response.Data object.
' Example: After Response.Data has been populated, call DebugJson Response.Data
Sub DebugPrintDictColl(ByVal Obj As Object, Optional Depth As Long = 0)
Dim Key As Variant
Dim Value As Variant
Dim Indent As String

    Indent = String(Depth * 2, " ")

    If VBA.TypeName(Obj) = "Dictionary" Then
        For Each Key In Obj.Keys
            If VBA.VarType(Obj(Key)) = vbObject Then
                Debug.Print Indent & Key & ":"
                DebugPrintDictColl Obj(Key), Depth + 1
            Else
                Debug.Print Indent & Key & ": " & Chr(34) & Obj(Key) & Chr(34)
            End If
        Next Key
    ElseIf VBA.TypeName(Obj) = "Collection" Then
        For Each Value In Obj
            If VBA.VarType(Value) = vbObject Then
                DebugPrintDictColl Value, Depth + 1
            Else
                Debug.Print Chr(34) & Value & Chr(34)
            End If
        Next Value
    End If

    Debug.Print "======"
End Sub


