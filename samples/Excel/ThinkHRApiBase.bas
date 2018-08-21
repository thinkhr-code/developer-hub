Attribute VB_Name = "ThinkHRApiBase"
' Code derived from the Canvas API Example at https://community.canvaslms.com/groups/canvas-developers/blog/2016/05/16/download-data-to-excel-using-vba-and-the-api-workbook-with-code-attached

Option Explicit
' Defs for API
Const cTimeoutMs = 10000
Const cLimit = 1000
Const cFetchLimit = 500
Const cParamLimit = "limit"
Const cParamOffset = "offset"
Const cParamSort = "sort"
Const cParamActive = "isActive"
Const cParamBroker = "brokerId"
Const cParamCompany = "companyId"

' Defs for layout
Const cRowStartOfData = "2"
Const cTitleRow = "5"
Const cProgressRow = "6"
Const cDownloadRow = "7"

' Defs for Column A and B
Public Const cTitle = "ThinkHR"

Const cSections = 3


' Settings, stored in hidden Settings sheet
Dim sURL As String
Dim sClientId As String
Dim sClientSecret As String
Dim sUserName As String
Dim sPassword As String
Dim sToken As String
Dim sDefaultRole As String
Dim bIncludeInactives As Boolean
Dim lBrokerId As Long

Dim bProcessing As Boolean ' to prevent restarting while busy running
Dim bCanceled As Boolean ' indicates the download process has been canceled

' Function ClearSettings()
' Purpose: Clear all settings from the notebook
Function ClearSettings()
Dim Sh As Worksheet

    Set Sh = ThinkHRWorkbook.Sheets("Settings")
    
    Sh.Range("B3:B10").ClearContents
    Sh.Range("B3:B10").ClearComments
    
End Function
' Sub EditSettings()
' Purpose: show the settings form, only if no data is being downloaded
Sub EditSettings()
    If bProcessing = True Then Exit Sub ' to prevent restarting while already running
    frmSettings.Show
End Sub

' Function LoadSettings()
' Purpose: Load all settings in variables before downloading is possible. Each time the Download data is clicked this function is executed
Function LoadSettings()
Dim Sh As Worksheet

    Set Sh = ThinkHRWorkbook.Sheets("Settings")
    
    sURL = Sh.Cells(3, 2).Value
    sClientId = Sh.Cells(4, 2).Value
    sClientSecret = Sh.Cells(5, 2).Value
    sUserName = Sh.Cells(6, 2).Value
    sPassword = Sh.Cells(7, 2).Value
    sDefaultRole = Sh.Cells(8, 2).Value
    bIncludeInactives = Sh.Cells(9, 2).Value
    lBrokerId = Sh.Cells(10, 2).Value
End Function

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
End Function

' Sub GetRecords()
' Purpose: This is the main sub to download data from ThinkHR.
Sub GetRecords()
Dim Sh As Worksheet
Dim iRecords As Long
Dim iCurrentRow, iCurrentCol As Integer

    If bProcessing = True Then ' if true, this function is already running
        RequestAbortDownload 'pop the question if aborting the download is desired, if confirmed bCanceled will be set to yes
        Exit Sub ' to prevent restarting while already running
    End If
    
    On Error GoTo FinishUp
    bProcessing = True                  ' indicate GetRecords is already running
    bCanceled = False                   ' reset the status
    LoadSettings
    If ValidateSettings = False Then
        frmSettings.Show                ' automatically open the settings window if no or incorrect settings are present
        GoTo FinishUp                   ' don't proceed downloading
    End If
    
    Set Sh = ThinkHRWorkbook.ActiveSheet
    
    UpdateDownloadProgress 0

    iCurrentRow = cDownloadRow
    iCurrentCol = 1
    
    ClearStats
    
    DoEvents                                ' process any mouseclicks or keyboard strikes if any
    If bCanceled = True Then GoTo FinishUp  ' abort downloading if user requested to abort
    
    iRecords = GetAllCompanies()
    
    Sh.Cells(iCurrentRow, iCurrentCol).HorizontalAlignment = xlRight
    Sh.Cells(iCurrentRow, iCurrentCol).VerticalAlignment = xlTop
    Sh.Cells(iCurrentRow, iCurrentCol).Value = ChrW(8595) & " " & Trim(Str(iRecords)) ' display the number of Companies
    
    iCurrentCol = iCurrentCol + 1

    Sh.Cells(iCurrentRow, iCurrentCol).HorizontalAlignment = xlLeft
    Sh.Cells(iCurrentRow, iCurrentCol).VerticalAlignment = xlTop
    Sh.Cells(iCurrentRow, iCurrentCol).Value = "companies"
    
    DoEvents                                            ' process any mouseclicks or keyboard strikes if any
    If bCanceled = True Then GoTo FinishUp              ' abort downloading if user requested to abort
    
    iRecords = GetAllUsers()
    
    iCurrentRow = iCurrentRow + 1
    iCurrentCol = 1

    Sh.Cells(iCurrentRow, iCurrentCol).HorizontalAlignment = xlRight
    Sh.Cells(iCurrentRow, iCurrentCol).VerticalAlignment = xlTop
    Sh.Cells(iCurrentRow, iCurrentCol).Value = ChrW(8595) & " " & Trim(Str(iRecords)) ' display the number of Users
    
    iCurrentCol = iCurrentCol + 1

    Sh.Cells(iCurrentRow, iCurrentCol).HorizontalAlignment = xlLeft
    Sh.Cells(iCurrentRow, iCurrentCol).VerticalAlignment = xlTop
    Sh.Cells(iCurrentRow, iCurrentCol).Value = "users"
    
    DoEvents                                            ' process any mouseclicks or keyboard strikes if any
    If bCanceled = True Then GoTo FinishUp              ' abort downloading if user requested to abort
    
    iRecords = GetAllConfigurations()
    
    iCurrentRow = iCurrentRow + 1
    iCurrentCol = 1

    Sh.Cells(iCurrentRow, iCurrentCol).HorizontalAlignment = xlRight
    Sh.Cells(iCurrentRow, iCurrentCol).VerticalAlignment = xlTop
    Sh.Cells(iCurrentRow, iCurrentCol).Value = ChrW(8595) & " " & Trim(Str(iRecords)) ' display the number of Configurations
    
    iCurrentCol = iCurrentCol + 1

    Sh.Cells(iCurrentRow, iCurrentCol).HorizontalAlignment = xlLeft
    Sh.Cells(iCurrentRow, iCurrentCol).VerticalAlignment = xlTop
    Sh.Cells(iCurrentRow, iCurrentCol).Value = "configurations"
    
    UpdateDownloadProgress 100
    DoEvents                                            ' process any mouseclicks or keyboard strikes if any
    If bCanceled = True Then GoTo FinishUp              ' abort downloading if user requested to abort
    
FinishUp:
    If bCanceled = False And Err.Number <> 0 Then MsgBox "An error occurred." & vbCrLf & Err.Description
    bProcessing = False ' to prevent restarting while already running
End Sub

' Function GetAllCompanies() As Long
' Purpose: performs API call to get the course name associated by the course id. It is also the first call performed, if it fails it indicates a connection error
' Dependencies: WebResponse offered via https://github.com/VBA-tools/VBA-Web
Function GetAllCompanies() As Long

Dim Response As WebResponse
Dim cResponse As Collection
Dim stItem As Company
Dim i As Integer
Dim cRecords As Collection
Dim iOffset As Long

    iOffset = 0

    On Error GoTo FinishUp

    ClearDataSheet ThinkHRWorkbook.Sheets("Companies")

LoadCompanies:

    Set Response = SubmitRequest("/v1/companies", cFetchLimit, iOffset, "+companyId")
    If Response.StatusCode = WebStatusCode.Ok Then ' Ok - 200
        Set cResponse = New Collection
        Set cRecords = Response.Data("companies")

        On Error Resume Next ' Just in case there is an error processing a record, continue w/the next record.
        For i = 1 To cRecords.Count
            Set stItem = CompanyImport(cRecords(i))
            cResponse.Add stItem, stItem.Id
        Next i
        On Error GoTo FinishUp ' if an error happens now, resuming is pointless
        
        LoadDataSheetCompany cResponse, iOffset

        iOffset = iOffset + cRecords.Count
        
        UpdateDownloadProgress (iOffset / Response.Data("totalRecords") * 100) / cSections

        If Response.Data("limit") = cRecords.Count Then
            GoTo LoadCompanies
        End If
    Else
        ResponseStatusErrorMsg Response.StatusCode, Response.StatusDescription
    End If
    
FinishUp:
    If Err.Number <> 0 Then MsgBox "An error occurred." & vbCrLf & Err.Description
    If cResponse.Count > 0 Then GetAllCompanies = iOffset

End Function

' Function CompanyImport( oSrc As Object ) As Company
' Purpose: Load an API record into an object of type Company
Function CompanyImport(oSrc) As Company
Dim record As New Company
Dim oLocation As Object

    Set oLocation = oSrc("location")

    record.Id = GetDictonaryValue(oItem, "companyId")
    record.Name = GetDictonaryValue(oSrc, "companyName")
    record.DisplayName = GetDictonaryValue(oSrc, "displayName")
    record.Phone = GetDictonaryValue(oSrc, "phone")
    record.AddressLine = GetDictonaryValue(oLocation, "address")
    record.AddressLine2 = GetDictonaryValue(oLocation, "address2")
    record.City = GetDictonaryValue(oLocation, "city")
    record.State = GetDictonaryValue(oLocation, "state")
    record.Zip = GetDictonaryValue(oLocation, "zip")
    record.Industry = GetDictonaryValue(oItem, "industry")
    record.Size = GetDictonaryValue(oItem, "companySize")
    record.Producer = GetDictonaryValue(oItem, "producer")
    record.ConfigurationName = GetDictonaryValue(oItem, "configurationName")
    record.Custom1 = GetDictonaryValue(oItem, "customField1")
    record.Custom2 = GetDictonaryValue(oItem, "customField2")
    record.Custom3 = GetDictonaryValue(oItem, "customField3")
    record.Custom4 = GetDictonaryValue(oItem, "customField4")
    record.Custom5 = GetDictonaryValue(oItem, "customField5")
    

    Set CompanyImport = record

End Function


' Function LoadDataSheetCompany(cRecords As Collection, iRow As Long)
' Purpose: Loads the Companies work sheet w/the contents of the the collection provided.  The collection is assumed to contain Company objects.
Function LoadDataSheetCompany(cRecords As Collection, iRow As Long)
Dim row As Long
Dim Sh As Worksheet
Dim record As Company

    On Error GoTo FinishUp

    Set Sh = ThinkHRWorkbook.Sheets("Companies")
    row = iRow + 2 'Account for header'
    
    For Each record In cRecords
        Sh.Cells(row, 1).Value = record.Id
        Sh.Cells(row, 2).Value = record.Name
        Sh.Cells(row, 3).Value = record.DisplayName
        Sh.Cells(row, 4).Value = record.Phone
        Sh.Cells(row, 5).Value = record.AddressLine
        Sh.Cells(row, 6).Value = record.AddressLine2
        Sh.Cells(row, 7).Value = record.City
        Sh.Cells(row, 8).Value = record.State
        Sh.Cells(row, 9).Value = record.Zip
        Sh.Cells(row, 10).Value = record.Industry
        Sh.Cells(row, 11).Value = record.Size
        Sh.Cells(row, 12).Value = record.Producer
        Sh.Cells(row, 13).Value = record.ConfigurationName
        Sh.Cells(row, 14).Value = record.Custom1
        Sh.Cells(row, 15).Value = record.Custom2
        Sh.Cells(row, 16).Value = record.Custom3
        Sh.Cells(row, 17).Value = record.Custom4
        Sh.Cells(row, 18).Value = record.Custom5
        
        row = row + 1
    Next

    Sh.Cells.EntireColumn.AutoFit
    
FinishUp:
    If Err.Number <> 0 Then MsgBox "An error occurred." & vbCrLf & Err.Description

End Function

' Function GetAllUsers() As Long
' Purpose: performs API call to get the course name associated by the course id. It is also the first call performed, if it fails it indicates a connection error
' Dependencies: WebResponse offered via https://github.com/VBA-tools/VBA-Web
Function GetAllUsers() As Long

Dim Response As WebResponse
Dim cResponse As Collection
Dim stItem As User
Dim i As Integer
Dim cRecords As Collection
Dim oItem As Object
Dim iOffset As Long

    iOffset = 0

    On Error GoTo FinishUp

    ClearDataSheet ThinkHRWorkbook.Sheets("Users")

LoadUsers:

    Set Response = SubmitRequest("/v1/users", cFetchLimit, iOffset, "+userId")
    If Response.StatusCode = WebStatusCode.Ok Then ' Ok - 200
        Set cResponse = New Collection
        Set cRecords = Response.Data("users")
        
        On Error Resume Next ' Just in case there is an error processing a record, continue w/the next record.
        For i = 1 To cRecords.Count
            Set oItem = cRecords(i)
            Set stItem = New User ' see class module User
            
            stItem.Id = GetDictonaryValue(oItem, "userId")
            stItem.FirstName = GetDictonaryValue(oItem, "firstName")
            stItem.LastName = GetDictonaryValue(oItem, "lastName")
            stItem.CompanyName = GetDictonaryValue(oItem, "companyName")
            stItem.Email = GetDictonaryValue(oItem, "email")
            stItem.Username = GetDictonaryValue(oItem, "userName")
            stItem.JobTitle = GetDictonaryValue(oItem, "jobTitle")
            stItem.Phone = GetDictonaryValue(oItem, "phone")
            stItem.Department = GetDictonaryValue(oItem, "department")
            stItem.Role = GetDictonaryValue(oItem, "role")
            stItem.Custom1 = GetDictonaryValue(oItem, "customField1")
            stItem.Custom2 = GetDictonaryValue(oItem, "customField2")
            stItem.Custom3 = GetDictonaryValue(oItem, "customField3")
            stItem.Custom4 = GetDictonaryValue(oItem, "customField4")
            stItem.CompanyId = GetDictonaryValue(oItem, "companyId")

            cResponse.Add stItem, stItem.Id
        Next i
        On Error GoTo FinishUp ' if an error happens now, resuming is pointless
        
        LoadDataSheetUser cResponse, iOffset
        
        iOffset = iOffset + cRecords.Count
        
        UpdateDownloadProgress (iOffset / Response.Data("totalRecords") * 100) / cSections

        If Response.Data("limit") = cRecords.Count Then
            GoTo LoadUsers
        End If
    Else
        ResponseStatusErrorMsg Response.StatusCode, Response.StatusDescription
    End If
    
FinishUp:
    If Err.Number <> 0 Then MsgBox "An error occurred." & vbCrLf & Err.Description
    If cResponse.Count > 0 Then GetAllUsers = iOffset

End Function

' Function LoadDataSheetUser(cRecords As Collection, iRow As Long)
' Purpose: Loads the Users worksheet w/the contents of the the collection provided.  The collection is assumed to contain User objects.
Function LoadDataSheetUser(cRecords As Collection, iRow As Long)
Dim row As Long
Dim Sh As Worksheet
Dim record As User

    On Error GoTo FinishUp

    Set Sh = ThinkHRWorkbook.Sheets("Users")
    row = iRow + 2 'Account for header'
    
    For Each record In cRecords
        Sh.Cells(row, 1).Value = record.Id
        Sh.Cells(row, 2).Value = record.FirstName
        Sh.Cells(row, 3).Value = record.LastName
        Sh.Cells(row, 4).Value = record.CompanyName
        Sh.Cells(row, 5).Value = record.Email
        Sh.Cells(row, 6).Value = record.Username
        Sh.Cells(row, 7).Value = record.JobTitle
        Sh.Cells(row, 8).Value = record.Phone
        Sh.Cells(row, 9).Value = record.Department
        Sh.Cells(row, 10).Value = record.Role
        Sh.Cells(row, 11).Value = record.Custom1
        Sh.Cells(row, 12).Value = record.Custom2
        Sh.Cells(row, 13).Value = record.Custom3
        Sh.Cells(row, 14).Value = record.Custom4
        
        row = row + 1
    Next
    
    Sh.Cells.EntireColumn.AutoFit

FinishUp:
    If Err.Number <> 0 Then MsgBox "An error occurred." & vbCrLf & Err.Description

End Function

' Function GetAllConfigurations() As Long
' Purpose: performs API call to get the course name associated by the course id. It is also the first call performed, if it fails it indicates a connection error
' Dependencies: WebResponse offered via https://github.com/VBA-tools/VBA-Web
Function GetAllConfigurations() As Long

Dim Response As WebResponse
Dim cResponse As Collection
Dim stItem As Config
Dim i As Integer
Dim cRecords As Collection
Dim oItem As Object
Dim iOffset As Long

    iOffset = 0

    On Error GoTo FinishUp
    
    ClearDataSheet ThinkHRWorkbook.Sheets("Configurations")

LoadConfigurations:

    Set Response = SubmitRequest("/v1/configurations", cFetchLimit, iOffset, "+configurationId")
    If Response.StatusCode = WebStatusCode.Ok Then ' Ok - 200
        Set cResponse = New Collection
        Set cRecords = Response.Data("configurations")
        
        On Error Resume Next ' Just in case there is an error processing a record, continue w/the next record.
        For i = 1 To cRecords.Count
            Set oItem = cRecords(i)
            Set stItem = New Config ' see class module config
            
            stItem.Id = GetDictonaryValue(oItem, "configurationId")
            stItem.BrokerId = GetDictonaryValue(oItem, "companyId")
            stItem.BrokerName = GetDictonaryValue(oItem, "brokerName")
            stItem.Key = GetDictonaryValue(oItem, "configurationKey")
            stItem.Name = GetDictonaryValue(oItem, "configurationName")
            stItem.Description = GetDictonaryValue(oItem, "description")
            stItem.Active = IIf(GetDictonaryValue(oItem, "isActive") = 1, True, False)
            stItem.Master = IIf(GetDictonaryValue(oItem, "masterConfiguration") = 1, True, False)

            cResponse.Add stItem, stItem.Id
        Next i
        On Error GoTo FinishUp ' if an error happens now, resuming is pointless
        
        LoadDataSheetConfiguration cResponse, iOffset

        iOffset = iOffset + cRecords.Count
        
        UpdateDownloadProgress (iOffset / Response.Data("totalRecords") * 100) / cSections

        If Response.Data("limit") = cRecords.Count Then
            GoTo LoadConfigurations
        End If
    Else
        ResponseStatusErrorMsg Response.StatusCode, Response.StatusDescription
    End If
    
FinishUp:
    If Err.Number <> 0 Then MsgBox "An error occurred." & vbCrLf & Err.Description
    If cResponse.Count > 0 Then GetAllConfigurations = iOffset

End Function

' Sub SendRecords()
' Purpose: This is the main sub to upload changed data to ThinkHR.
Sub SendRecords()
    MsgBox "Coming Soon, please be patient."
End Sub

' Function LoadDataSheetConfiguration(cRecords As Collection, iRow As Long)
' Purpose: Loads the Configurations worksheet w/the contents of the the collection provided.  The collection is assumed to contain config objects.
Function LoadDataSheetConfiguration(cRecords As Collection, iRow As Long)
Dim row As Long
Dim Sh As Worksheet
Dim record As Config

    On Error GoTo FinishUp

    Set Sh = ThinkHRWorkbook.Sheets("Configurations")
    row = iRow + 2 'Account for header'
    
    For Each record In cRecords
        Sh.Cells(row, 1).Value = record.Id
        Sh.Cells(row, 2).Value = record.BrokerId
        Sh.Cells(row, 3).Value = record.BrokerName
        Sh.Cells(row, 4).Value = record.Key
        Sh.Cells(row, 5).Value = record.Name
        Sh.Cells(row, 6).Value = record.Description
        Sh.Cells(row, 7).Value = record.Active
        Sh.Cells(row, 8).Value = record.Master
        
        row = row + 1
    Next

    Sh.Cells.EntireColumn.AutoFit

FinishUp:
    If Err.Number <> 0 Then MsgBox "An error occurred." & vbCrLf & Err.Description

End Function

' Function ClearAllDataSettings()
' Purpose: Clears all data sheets and removes all values from the hidden Settings sheet.
Function ClearAllDataSettings()

    If MsgBox("You are about to clear all data AND settings from this workbook." & vbCrLf & _
            "Are you sure you want to remove everything?", _
                vbYesNo, "Delete it ALL") = vbYes Then
                
        ClearDataSheet ThinkHRWorkbook.Sheets("Companies")
        ClearDataSheet ThinkHRWorkbook.Sheets("Users")
        ClearDataSheet ThinkHRWorkbook.Sheets("Configurations")
        
        ClearSettings
        
        ClearStats
    End If

End Function

' Function ClearDataSheet(Sh As Worksheet)
' Purpose: Clears a data sheet before loading with new data
Function ClearDataSheet(Sh As Worksheet)
    'We have a header, so clear everything underneath it.
    Sh.Range("2:" & Sh.Rows.Count).ClearContents
    Sh.Range("2:" & Sh.Rows.Count).ClearComments
    Sh.Cells.EntireColumn.AutoFit
End Function

' Function ClearStats()
' Purpose: Clears a data sheet before loading with new data
Function ClearStats()
Dim Sh As Worksheet

    Set Sh = ThinkHRWorkbook.Sheets("Start")

    ' Clear any stats/information from last download
    Sh.Range(cTitleRow & ":" & Sh.Rows.Count).ClearContents
    Sh.Range(cTitleRow & ":" & Sh.Rows.Count).ClearComments

End Function

' Function SubmitRequest(sEndpoint As String, Optional iLimit As Variant, Optional iOffset As Variant, Optional sSort As Variant) As WebResponse
' Purpose: Submits a request to the provide endpoint and returns the response object
' Dependencies: Several modules offered via https://github.com/VBA-tools/VBA-Web (WebHelpers, WebClient, WebRequest, WebResponse, etc.)
Function SubmitRequest(sEndpoint As String, Optional iLimit As Variant, Optional iOffset As Variant, Optional sSort As Variant) As WebResponse
Dim Client As New WebClient
Dim Auth As New ThinkHRAuthenticator
Dim Request As New WebRequest

    Auth.Setup sURL, sClientId, sClientSecret, sUserName, sPassword

    Client.BaseUrl = sURL
    Client.TimeoutMs = cTimeoutMs
    Set Client.Authenticator = Auth

    Request.Resource = sEndpoint
    Request.Method = WebMethod.HttpGet
    Request.Format = WebFormat.Json
    Request.ResponseFormat = WebFormat.Json
    
    If IsMissing(iLimit) Then
        Request.AddQuerystringParam cParamLimit, cLimit
    Else
        Request.AddQuerystringParam cParamLimit, iLimit
    End If
    
    If Not IsMissing(iOffset) Then
        Request.AddQuerystringParam cParamOffset, iOffset
    End If
    
    If Not IsMissing(sSort) Then
        Request.AddQuerystringParam cParamSort, sSort
    End If
    
    If Not bIncludeInactives Then
        Request.AddQuerystringParam cParamActive, 1
    End If
    
    If lBrokerId > 0 Then
        If InStr(1, sEndpoint, "/configurations") Then      ' Special case - configuration API is inconsistent and doesn't use brokerId, only companyId.
            Request.AddQuerystringParam cParamCompany, lBrokerId
        Else
            Request.AddQuerystringParam cParamBroker, lBrokerId
        End If
    End If
    
    Set SubmitRequest = Client.Execute(Request)
End Function

' Function RequestAbortDownload()
' Purpose: Prompts to stop processing any further
Function RequestAbortDownload()
    If MsgBox("Downloading data from ThinkHR is still in progress." & vbCrLf & _
            "Are you sure to abort downloading?", _
                vbYesNo, "Abort download") = vbYes Then
        bCanceled = True
    End If
End Function

' Function UpdateDownloadProgress(iPercent As Double)
' Purpose: Updates the percentage of the download progress in cell A3
Function UpdateDownloadProgress(iPercent As Double)
Dim Sh As Worksheet

    Set Sh = ThinkHRWorkbook.Sheets("Start")

    If iPercent >= 0 Then
        Sh.Cells(cProgressRow, 1).Value = iPercent / 100
        Sh.Cells(cProgressRow, 2).Value = "downloaded"
    End If
End Function

' Function ResponseStatusErrorMsg(ErrorCode As String)
' Purpose: Displays a message in case of any connection errors
Function ResponseStatusErrorMsg(StatusCode As String, StatusDescription As String)
Dim ErrorMsg As String

    ErrorMsg = "ThinkHR returned the message: " & Trim(Str(StatusCode)) & " - " & StatusDescription
    ErrorMsg = ErrorMsg & vbCrLf & "Would you like to abort?"
    If MsgBox(ErrorMsg, vbYesNo, "Unable to complete the request") = vbYes Then
        bCanceled = True
    End If
End Function

' Function GetDictonaryValue(Source As Object, SourceField As String)
' Purpose: Retrieve a dictionary value and return it as a string.  If no value present, return an empty string.
Function GetDictonaryValue(Source As Object, SourceField As String)
Dim SourceType As String

    SourceType = VBA.TypeName(Source(SourceField))
    GetDictonaryValue = ""
    
    On Error GoTo FinishUp
    
    If SourceType = "String" Then
        GetDictonaryValue = Trim(Source(SourceField))
    ElseIf SourceType <> "Empty" Then
        GetDictonaryValue = Trim(Str(Source(SourceField)))
    End If

FinishUp:
    If Err.Number <> 0 Then MsgBox "An error occurred." & vbCrLf & Err.Description

End Function

' Function DebugPrintDictColl(ByVal Obj As Object, Optional Depth As Long = 0)
' Purpose: Recursive function to iterate through all items from the Response.Data object.
' Example: After Response.Data has been populated, call DebugJson Response.Data
Function DebugPrintDictColl(ByVal Obj As Object, Optional Depth As Long = 0)
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
End Function
