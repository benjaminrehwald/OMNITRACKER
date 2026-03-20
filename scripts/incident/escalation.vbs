'==============================================================================
' OMNITRACKER – Incident SLA Escalation
' File   : scripts/incident/escalation.vbs
' Event  : Incident → OnSLABreach  (also works for Service Request)
' Purpose: When an SLA breach occurs:
'          1. Escalate the ticket to the EscalationGroup defined on the Category.
'          2. Set ticket status to "Escalated".
'          3. Notify the escalation group and the requester.
'          4. Increment the EscalationCount field for KPI tracking.
'==============================================================================
Option Explicit

' #Include "common/utility-functions.vbs"
' #Include "common/mail-templates.vbs"

'------------------------------------------------------------------------------
' Entry point – called by OMNITRACKER on SLA breach
'------------------------------------------------------------------------------
Sub OnSLABreach(oTicket)
    Const FIELD_STATUS           = "Status"
    Const FIELD_ASSIGNED_GROUP   = "AssignedGroup"
    Const FIELD_ESCALATION_COUNT = "EscalationCount"
    Const FALLBACK_ESCALATION    = "IT Management"

    ' --- 1. Get escalation group from Category ---
    Dim sEscGroup
    sEscGroup = GetCategoryField(oTicket, CAT_FIELD_ESCALATION_GROUP)

    If Len(Trim(sEscGroup)) = 0 Then
        sEscGroup = FALLBACK_ESCALATION
        LogScriptError "escalation.vbs", _
            "No EscalationGroup on Category – using fallback '" & FALLBACK_ESCALATION & "'", _
            oTicket
    End If

    ' --- 2. Update ticket fields ---
    On Error Resume Next
    oTicket.SetFieldValue FIELD_ASSIGNED_GROUP, sEscGroup
    oTicket.SetFieldValue FIELD_STATUS, INC_STATUS_ESCALATED

    ' Increment escalation counter for KPI reporting
    Dim nCount
    nCount = CInt(SafeGetField(oTicket, FIELD_ESCALATION_COUNT))
    oTicket.SetFieldValue FIELD_ESCALATION_COUNT, CStr(nCount + 1)

    If Err.Number <> 0 Then
        LogScriptError "escalation.vbs", "Field update failed: " & Err.Description, oTicket
        Err.Clear
    End If
    On Error GoTo 0

    ' --- 3. Notify escalation group ---
    Dim sGroupMail
    sGroupMail = GetGroupMailAddress(sEscGroup)
    If Len(Trim(sGroupMail)) > 0 Then
        Dim oTokens
        Set oTokens = BuildTokenDict(oTicket)
        Dim sSubject
        sSubject = "SLA BREACH – " & SafeGetField(oTicket, "TicketID") & " – " & _
                   SafeGetField(oTicket, "Summary")
        Dim sBody
        sBody = "Ticket " & oTokens(MAIL_TOKEN_TICKET_ID) & " has breached its SLA and " & _
                "has been escalated to your group (" & sEscGroup & ")." & vbCrLf & vbCrLf & _
                "Summary      : " & oTokens(MAIL_TOKEN_SUMMARY) & vbCrLf & _
                "Status       : " & oTokens(MAIL_TOKEN_STATUS) & vbCrLf & _
                "Requester    : " & oTokens(MAIL_TOKEN_REQUESTER) & vbCrLf & vbCrLf & _
                "Please take ownership immediately."
        SendMail sGroupMail, sSubject, sBody, oTicket
    End If

    ' --- 4. Notify requester ---
    Dim sRequesterMail
    sRequesterMail = SafeGetField(oTicket, "RequesterEmail")
    If Len(Trim(sRequesterMail)) > 0 Then
        Dim sRequesterBody
        sRequesterBody = "We apologise that your ticket " & _
                         SafeGetField(oTicket, "TicketID") & _
                         " has exceeded its SLA target." & vbCrLf & vbCrLf & _
                         "It has been escalated to our " & sEscGroup & " team " & _
                         "and will be handled with highest priority." & vbCrLf & _
                         "We will update you as soon as possible."
        SendMail sRequesterMail, _
                 "Update on your ticket " & SafeGetField(oTicket, "TicketID"), _
                 sRequesterBody, _
                 oTicket
    End If
End Sub

'------------------------------------------------------------------------------
' Function : GetGroupMailAddress
' Purpose  : Retrieve the distribution list e-mail address for an assignment group.
' Params   : sGroupName – name of the group
' Returns  : E-mail address as String, or "" if not found
'------------------------------------------------------------------------------
Function GetGroupMailAddress(sGroupName)
    On Error Resume Next
    Dim oGroup
    Set oGroup = OTApp.GetGroup(sGroupName)
    If Err.Number <> 0 Or oGroup Is Nothing Then
        GetGroupMailAddress = ""
        Err.Clear
        Exit Function
    End If
    GetGroupMailAddress = SafeGetField(oGroup, "MailAddress")
    On Error GoTo 0
End Function
