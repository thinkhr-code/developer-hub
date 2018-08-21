VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmSettings 
   Caption         =   "Settings"
   ClientHeight    =   4312
   ClientLeft      =   -288
   ClientTop       =   -1904
   ClientWidth     =   7696
   OleObjectBlob   =   "frmSettings.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmSettings"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Label11_Click()

End Sub

Private Sub CheckBox1_Click()

End Sub

Private Sub cbIncludeInactives_Click()

End Sub

Private Sub UserForm_Deactivate()
    LoadSettings
End Sub

Private Sub UserForm_Initialize()
Dim Sh As Worksheet
    Set Sh = ThinkHRWorkbook.Sheets("Settings")
    
    tbURL.Value = Sh.Cells(3, 2).Value
    tbClientId.Value = Sh.Cells(4, 2).Value
    tbClientSecret.Value = Sh.Cells(5, 2).Value
    tbUsername.Value = Sh.Cells(6, 2).Value
    tbPassword.Value = Sh.Cells(7, 2).Value
    tbDefaultRole.Value = Sh.Cells(8, 2).Value
    cbIncludeInactives.Value = IIf(Sh.Cells(9, 2).Value = "True", True, False)
    tbBrokerId.Value = Sh.Cells(10, 2).Value
    
    Sh.Visible = xlSheetVeryHidden ' Unhide is only possible using VBA code
End Sub

Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdSave_Click()
Dim Sh As Worksheet
    Set Sh = ThinkHRWorkbook.Sheets("Settings")
    
    If Len(tbURL.Value) > 8 And Right(tbURL.Value, 1) = "/" Then
        tbURL.Value = Left(tbURL.Value, Len(tbURL.Value) - 1)
    End If
    
    Sh.Cells(3, 2).Value = tbURL.Value
    Sh.Cells(4, 2).Value = tbClientId.Value
    Sh.Cells(5, 2).Value = tbClientSecret.Value
    Sh.Cells(6, 2).Value = tbUsername.Value
    Sh.Cells(7, 2).Value = tbPassword.Value
    Sh.Cells(8, 2).Value = tbDefaultRole.Value
    Sh.Cells(9, 2).Value = cbIncludeInactives.Value
    Sh.Cells(10, 2).Value = tbBrokerId.Value
    Unload Me
End Sub

Function ValidateFormValues()
Dim bValidValues As Boolean
Dim iPos As Integer

    bValidValues = True
    If InStr(1, tbURL.Value, "https://") <> 1 Or _
        InStr(1, tbURL.Value, ".") < 10 Or _
        InStr(1, tbURL.Value, ".") > Len(tbURL.Value) - 2 Or _
            Len(tbURL.Value) < 12 Then
        bValidValues = False
    End If
    
    If Len(tbClientId.Value) = 0 Then bValidValues = False
    If Len(tbClientSecret.Value) = 0 Then bValidValues = False
    If Len(tbUsername.Value) = 0 Then bValidValues = False
    If Len(tbPassword.Value) = 0 Then bValidValues = False
    If Len(tbDefaultRole.Value) = 0 Then bValidValues = False
    
    cmdSave.Enabled = bValidValues
End Function

Private Sub tbURL_Change()
    ValidateFormValues
End Sub

Private Sub tbClientId_Change()
    ValidateFormValues
End Sub

Private Sub tbClientSecret_Change()
    ValidateFormValues
End Sub

Private Sub tbUsername_Change()
    ValidateFormValues
End Sub

Private Sub tbPassword_Change()
    ValidateFormValues
End Sub

Private Sub tbDefaultRole_Change()
    ValidateFormValues
End Sub

Private Sub cbIncludeInactive_Change()
    ValidateFormValues
End Sub

