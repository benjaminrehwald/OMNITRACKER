'==============================================================================
' OMNITRACKER – Shared Mail Template Helpers
' File   : scripts/common/mail-templates.vbs
' Usage  : Include in any script that sends notification mails.
' Events : n/a – library only
'==============================================================================
Option Explicit

'------------------------------------------------------------------------------
' Constants – mail subjects and substitution tokens
'------------------------------------------------------------------------------
Const MAIL_TOKEN_TICKET_ID      = "{TicketID}"
Const MAIL_TOKEN_SUMMARY        = "{Summary}"
Const MAIL_TOKEN_ASSIGNED_GROUP = "{AssignedGroup}"
Const MAIL_TOKEN_REQUESTER      = "{RequesterName}"
Const MAIL_TOKEN_SLA_DEADLINE   = "{SLA_Deadline}"
Const MAIL_TOKEN_STATUS         = "{Status}"
Const MAIL_TOKEN_RESOLUTION     = "{Resolution}"
Const MAIL_TOKEN_CATALOG_ITEM   = "{CatalogItem}"
Const MAIL_TOKEN_CHANGE_TYPE    = "{ChangeType}"

'------------------------------------------------------------------------------
' Function : RenderTemplate
' Purpose  : Replace substitution tokens in a template string.
' Params   : sTemplate – template string containing {TOKEN} placeholders
'            oTokens   – Scripting.Dictionary of token→value mappings
' Returns  : Rendered string
'------------------------------------------------------------------------------
Function RenderTemplate(sTemplate, oTokens)
    Dim sResult
    Dim key
    sResult = sTemplate
    For Each key In oTokens.Keys
        sResult = Replace(sResult, key, oTokens(key))
    Next
    RenderTemplate = sResult
End Function

'------------------------------------------------------------------------------
' Function : BuildTokenDict
' Purpose  : Build a standard token dictionary from a ticket object.
' Params   : oTicket – Business Object
' Returns  : Scripting.Dictionary
'------------------------------------------------------------------------------
Function BuildTokenDict(oTicket)
    Dim oDict
    Set oDict = CreateObject("Scripting.Dictionary")

    oDict(MAIL_TOKEN_TICKET_ID)      = SafeGetField(oTicket, "TicketID")
    oDict(MAIL_TOKEN_SUMMARY)        = SafeGetField(oTicket, "Summary")
    oDict(MAIL_TOKEN_ASSIGNED_GROUP) = SafeGetField(oTicket, "AssignedGroup")
    oDict(MAIL_TOKEN_REQUESTER)      = SafeGetField(oTicket, "RequesterName")
    oDict(MAIL_TOKEN_SLA_DEADLINE)   = SafeGetField(oTicket, "SLA_Deadline")
    oDict(MAIL_TOKEN_STATUS)         = SafeGetField(oTicket, "Status")
    oDict(MAIL_TOKEN_RESOLUTION)     = SafeGetField(oTicket, "Resolution")
    oDict(MAIL_TOKEN_CATALOG_ITEM)   = SafeGetField(oTicket, "CatalogItem")
    oDict(MAIL_TOKEN_CHANGE_TYPE)    = SafeGetField(oTicket, "ChangeType")

    Set BuildTokenDict = oDict
End Function

'------------------------------------------------------------------------------
' Function : GetTemplate_INC_Created
' Purpose  : Mail template – Incident created confirmation to requester.
'------------------------------------------------------------------------------
Function GetTemplate_INC_Created()
    GetTemplate_INC_Created = _
        "Your incident {TicketID} has been registered." & vbCrLf & vbCrLf & _
        "Summary      : {Summary}" & vbCrLf & _
        "Assigned to  : {AssignedGroup}" & vbCrLf & _
        "SLA deadline : {SLA_Deadline}" & vbCrLf & vbCrLf & _
        "We will keep you informed of any progress." & vbCrLf & _
        "Please do not reply to this mail; update the ticket in the portal."
End Function

'------------------------------------------------------------------------------
' Function : GetTemplate_INC_Resolved
' Purpose  : Mail template – Incident resolved notification to requester.
'------------------------------------------------------------------------------
Function GetTemplate_INC_Resolved()
    GetTemplate_INC_Resolved = _
        "Your incident {TicketID} has been resolved." & vbCrLf & vbCrLf & _
        "Summary    : {Summary}" & vbCrLf & _
        "Resolution : {Resolution}" & vbCrLf & vbCrLf & _
        "If the issue persists, please reopen the ticket in the portal within 5 days." & vbCrLf & _
        "Otherwise it will be closed automatically after 72 hours."
End Function

'------------------------------------------------------------------------------
' Function : GetTemplate_SR_Created
' Purpose  : Mail template – Service Request created confirmation to requester.
'------------------------------------------------------------------------------
Function GetTemplate_SR_Created()
    GetTemplate_SR_Created = _
        "Your service request {TicketID} has been registered." & vbCrLf & vbCrLf & _
        "Service      : {CatalogItem}" & vbCrLf & _
        "Summary      : {Summary}" & vbCrLf & _
        "SLA deadline : {SLA_Deadline}" & vbCrLf & vbCrLf & _
        "Current status: {Status}" & vbCrLf & _
        "You will be notified when approval is completed or when the service is ready."
End Function

'------------------------------------------------------------------------------
' Function : GetTemplate_SR_Approved
' Purpose  : Mail template – Service Request approved notification.
'------------------------------------------------------------------------------
Function GetTemplate_SR_Approved()
    GetTemplate_SR_Approved = _
        "Your service request {TicketID} has been approved." & vbCrLf & vbCrLf & _
        "Service      : {CatalogItem}" & vbCrLf & _
        "Assigned to  : {AssignedGroup}" & vbCrLf & _
        "SLA deadline : {SLA_Deadline}" & vbCrLf & vbCrLf & _
        "Fulfillment is now in progress."
End Function

'------------------------------------------------------------------------------
' Function : GetTemplate_SR_Rejected
' Purpose  : Mail template – Service Request rejected notification.
'------------------------------------------------------------------------------
Function GetTemplate_SR_Rejected()
    GetTemplate_SR_Rejected = _
        "Your service request {TicketID} has been rejected." & vbCrLf & vbCrLf & _
        "Service : {CatalogItem}" & vbCrLf & _
        "Summary : {Summary}" & vbCrLf & vbCrLf & _
        "Please contact your line manager or the IT Service Desk for further information."
End Function

'------------------------------------------------------------------------------
' Function : GetTemplate_SR_Fulfilled
' Purpose  : Mail template – Service Request fulfilled notification.
'------------------------------------------------------------------------------
Function GetTemplate_SR_Fulfilled()
    GetTemplate_SR_Fulfilled = _
        "Your service request {TicketID} has been fulfilled." & vbCrLf & vbCrLf & _
        "Service    : {CatalogItem}" & vbCrLf & _
        "Resolution : {Resolution}" & vbCrLf & vbCrLf & _
        "Please confirm in the portal within 48 hours." & vbCrLf & _
        "If you do not respond, the request will be closed automatically."
End Function

'------------------------------------------------------------------------------
' Function : GetTemplate_CHG_CABNotification
' Purpose  : Mail template – CAB notification for a new change submission.
'------------------------------------------------------------------------------
Function GetTemplate_CHG_CABNotification()
    GetTemplate_CHG_CABNotification = _
        "A change request requires CAB review." & vbCrLf & vbCrLf & _
        "Change ID   : {TicketID}" & vbCrLf & _
        "Type        : {ChangeType}" & vbCrLf & _
        "Summary     : {Summary}" & vbCrLf & vbCrLf & _
        "Please review the full change record in OMNITRACKER and cast your vote."
End Function

'------------------------------------------------------------------------------
' Sub     : SendMail
' Purpose : Send a notification e-mail via the OMNITRACKER mail subsystem.
' Params  : sTo       – recipient e-mail address
'           sSubject  – mail subject
'           sBody     – rendered mail body
'           oTicket   – source Business Object (for audit trail)
'------------------------------------------------------------------------------
Sub SendMail(sTo, sSubject, sBody, oTicket)
    On Error Resume Next
    Dim oMail
    Set oMail = OTApp.CreateMailMessage()
    oMail.To      = sTo
    oMail.Subject = sSubject
    oMail.Body    = sBody
    oMail.Send

    If Err.Number <> 0 Then
        LogScriptError "mail-templates.vbs/SendMail", _
                       "Failed to send mail to " & sTo & ": " & Err.Description, _
                       oTicket
        Err.Clear
    End If
    On Error GoTo 0
End Sub
