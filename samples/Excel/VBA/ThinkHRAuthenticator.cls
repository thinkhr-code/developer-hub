VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThinkHRAuthenticator"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
''
' ThinkHR Authenticator v1.0.0
' Based on Google Authenticator v3.0.8 by Tim Hall - https://github.com/VBA-tools/VBA-Web
'
' Custom IWebAuthenticator for authentication with ThinkHR APIs
'
' Details:
' - https://developers.thinkhr.com/
'
' Developers:
' - Register for Client Id and Client Secret: See Account Team
'
' Errors:
'
' @example
' ```VB.net
' Dim Auth As New ThinkHRAuthenticator
' Auth.Setup "API Endpoint, "Your Client Id", "Your Client Secret", "Username", "Password"
'
' ' Add authenticator to client
' Set Client.Authenticator = Auth
' ```
'
' @class ThinkHRAuthenticator
' @implements IWebAuthenticator v4.*
' @author rsmith-gilbert@thinkhr.com
'' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ '
Implements IWebAuthenticator
Option Explicit

' --------------------------------------------- '
' Constants and Private Variables
' --------------------------------------------- '

' --------------------------------------------- '
' Properties
' --------------------------------------------- '

Public APIEndpoint As String
Public ClientId As String
Public ClientSecret As String
Public Username As String
Public Password As String
Public Token As String
Public RefreshToken As String

' ============================================= '
' Public Methods
' ============================================= '

''
' Setup
'
' @param {String} APIEndpoint
' @param {String} ClientId
' @param {String} ClientSecret
' @param {String} Username
' @param {String} Password
' @param {String} RefreshToken
''
Public Sub Setup(APIEndpoint As String, ClientId As String, ClientSecret As String, Username As String, Password As String, RefreshToken As String)
    Me.APIEndpoint = APIEndpoint
    Me.ClientId = ClientId
    Me.ClientSecret = ClientSecret
    Me.Username = Username
    Me.Password = Password
    Me.RefreshToken = RefreshToken
End Sub


''
' Hook for taking action before a request is executed
'
' @param {WebClient} Client The client that is about to execute the request
' @param in|out {WebRequest} Request The request about to be executed
''
Private Sub IWebAuthenticator_BeforeExecute(ByVal Client As WebClient, ByRef Request As WebRequest)
    If Me.Token = "" Then
        Me.Token = Me.GetToken(Client)
    End If

    Request.SetHeader "Authorization", "Bearer " & Me.Token
End Sub

''
' Hook for taking action after request has been executed
'
' @param {WebClient} Client The client that executed request
' @param {WebRequest} Request The request that was just executed
' @param in|out {WebResponse} Response to request
''
Private Sub IWebAuthenticator_AfterExecute(ByVal Client As WebClient, ByVal Request As WebRequest, ByRef Response As WebResponse)
    ' e.g. Handle 401 Unauthorized or other issues
End Sub

''
' Hook for updating http before send
'
' @param {WebClient} Client
' @param {WebRequest} Request
' @param in|out {WinHttpRequest} Http
''
Private Sub IWebAuthenticator_PrepareHttp(ByVal Client As WebClient, ByVal Request As WebRequest, ByRef Http As Object)
    ' e.g. Update option, headers, etc.
End Sub

''
' Hook for updating cURL before send
'
' @param {WebClient} Client
' @param {WebRequest} Request
' @param in|out {String} Curl
''
Private Sub IWebAuthenticator_PrepareCurl(ByVal Client As WebClient, ByVal Request As WebRequest, ByRef Curl As String)
    ' e.g. Add flags to cURL
End Sub

''
' Get token
'
' @internal
' @param {WebClient} Client
' @return {String}
''
Public Function GetToken(Client As WebClient) As String
    On Error GoTo auth_Cleanup

    Dim auth_TokenClient As WebClient
    Dim auth_Request As New WebRequest
    Dim auth_Body As New Dictionary
    Dim auth_Response As WebResponse
    Dim basicAuth As New HttpBasicAuthenticator

    basicAuth.Setup Me.ClientId, Me.ClientSecret

    ' Clone client (to avoid accidental interactions)
    Set auth_TokenClient = Client.Clone
    Set auth_TokenClient.Authenticator = basicAuth
    auth_TokenClient.BaseUrl = Me.APIEndpoint

    ' Prepare token request
    auth_Request.Resource = "/v1/oauth/token"
    auth_Request.Method = WebMethod.HttpPost
    auth_Request.RequestFormat = WebFormat.FormUrlEncoded
    auth_Request.ResponseFormat = WebFormat.json

RetryToken:

Dim bLogging As Boolean: bLogging = WebHelpers.EnableLogging

    WebHelpers.EnableLogging = True
    If Me.RefreshToken <> "" Then
        WebHelpers.LogDebug "Using Refresh Token for authentication"
        auth_Body.Add "grant_type", "refresh_token"
        auth_Body.Add "refresh_token", Me.RefreshToken
    Else
        WebHelpers.LogDebug "Using Username for authentication"
        auth_Body.Add "grant_type", "password"
        auth_Body.Add "username", Me.Username
        auth_Body.Add "password", Me.Password
    End If
    WebHelpers.EnableLogging = bLogging

    Set auth_Request.Body = auth_Body

    Set auth_Response = auth_TokenClient.Execute(auth_Request)

    If auth_Response.StatusCode = WebStatusCode.Ok Then
        GetToken = auth_Response.Data("access_token")
        RefreshToken = auth_Response.Data("refresh_token")
    ElseIf Me.RefreshToken <> "" Then
        Me.RefreshToken = ""
        GoTo RetryToken
    Else
        Err.Raise 11041 + vbObjectError, "ThinkHRAuthenticator.GetToken", _
            auth_Response.StatusCode & ": " & auth_Response.Content
    End If

auth_Cleanup:

    Set auth_TokenClient = Nothing
    Set auth_Request = Nothing
    Set auth_Response = Nothing

    ' Rethrow error
    If Err.Number <> 0 Then
        Dim auth_ErrorDescription As String

        auth_ErrorDescription = "An error occurred while retrieving token." & vbNewLine
        If Err.Number - vbObjectError <> 11041 Then
            auth_ErrorDescription = auth_ErrorDescription & _
                Err.Number & VBA.IIf(Err.Number < 0, " (" & VBA.LCase$(VBA.Hex$(Err.Number)) & ")", "") & ": "
        End If
        auth_ErrorDescription = auth_ErrorDescription & Err.Description

        WebHelpers.LogError auth_ErrorDescription, "ThinkHRAuthenticator.GetToken", 11041 + vbObjectError
        Err.Raise 11041 + vbObjectError, "ThinkHRAuthenticator.GetToken", auth_ErrorDescription
    End If
End Function

' ============================================= '
' Private Methods
' ============================================= '

Private Function auth_LoginIsComplete(auth_IE As Object) As Boolean
    If Not auth_IE.Busy And auth_IE.ReadyState = 4 Then
        auth_LoginIsComplete = auth_LoginIsApproval(auth_IE) Or auth_LoginIsError(auth_IE)
    End If
End Function

Private Function auth_LoginIsApproval(auth_IE As Object) As Boolean
    Dim auth_UrlParts As Dictionary
    Set auth_UrlParts = WebHelpers.GetUrlParts(auth_IE.LocationURL)

    auth_LoginIsApproval = auth_UrlParts("Path") = "/o/oauth2/approval"
End Function

Private Function auth_LoginIsDenied(auth_IE As Object) As Boolean
    Dim auth_Document As Object
    Dim auth_Element As Object

    If auth_LoginIsApproval(auth_IE) Then
        For Each auth_Element In auth_IE.Document.Body.All
            If VBA.UCase(auth_Element.NodeName) = "P" And auth_Element.Id = "access_denied" Then
                auth_LoginIsDenied = True
                Exit Function
            End If
        Next auth_Element
    End If
End Function

Private Function auth_LoginIsError(auth_IE As Object) As Boolean
    auth_LoginIsError = InStr(1, auth_IE.Document.Body.innerHTML, "errorCode") > 0
End Function

Private Function auth_LoginExtractCode(auth_IE As Object) As String
    Dim auth_Element As Object

    If auth_LoginIsApproval(auth_IE) Then
        ' Extract authorization code
        For Each auth_Element In auth_IE.Document.Body.All
            If VBA.UCase(auth_Element.NodeName) = "INPUT" Then
                auth_LoginExtractCode = auth_Element.DefaultValue
                Exit Function
            End If
        Next auth_Element
    End If
End Function

Private Function auth_LoginExtractError(auth_IE As Object) As String
    Dim auth_Element As Object

    For Each auth_Element In auth_IE.Document.Body.All
        If auth_Element.Id = "errorCode" Then
            auth_LoginExtractError = auth_Element.innerHTML
        ElseIf auth_Element.Id = "errorDescription" Then
            auth_LoginExtractError = auth_LoginExtractError & ", " & auth_Element.innerHTML
            Exit Function
        End If
    Next auth_Element
End Function

