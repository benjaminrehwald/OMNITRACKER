'==============================================================================
' OMNITRACKER – Change CAB Notification
' File   : scripts/change/cab-notification.vbs
' Event  : Change → OnStatusChange
'          Triggers when status changes to "Submitted" (= RFC submitted for review)
' Purpose: Notify all active CAB members about a new change requiring review.
'          Sends a structured mail with risk score, implementation window, and
'          rollback plan summary.
'==============================================================================
Option Explicit

' #Include "common/utility-functions.vbs"
' #Include "common/mail-templates.vbs"

'------------------------------------------------------------------------------
' Entry point
'------------------------------------------------------------------------------
Sub OnStatusChange(oTicket, sOldStatus, sNewStatus)
    ' Only trigger when entering Submitted state
    If sNewStatus <> CHG_STATUS_SUBMITTED Then Exit Sub

    Const CAB_GROUP_NAME = "CAB Members"

    ' Standard changes skip CAB review
    If LCase(SafeGetField(oTicket, "ChangeType")) = "standard" Then
        ' Auto-approve standard changes
        oTicket.SetFieldValue "Status", CHG_STATUS_CAB_APPROVED
        LogScriptError "cab-notification.vbs", _
            "Standard change " & SafeGetField(oTicket, "TicketID") & " auto-approved.", _
            Nothing
        Exit Sub
    End If

    ' --- Notify all CAB members ---
    Dim oCABMembers
    On Error Resume Next
    Set oCABMembers = OTApp.GetGroupMembers(CAB_GROUP_NAME)
    If Err.Number <> 0 Or oCABMembers Is Nothing Then
        LogScriptError "cab-notification.vbs", _
            "Cannot retrieve CAB members from group '" & CAB_GROUP_NAME & "': " & Err.Description, _
            oTicket
        Err.Clear
        Exit Sub
    End If
    On Error GoTo 0

    Dim oTokens
    Set oTokens = BuildTokenDict(oTicket)

    Dim sSubject
    sSubject = "CAB Review Required: " & oTokens(MAIL_TOKEN_TICKET_ID) & _
               " – " & oTokens(MAIL_TOKEN_SUMMARY)

    Dim sBody
    sBody = BuildCABMailBody(oTicket, oTokens)

    Dim oMember
    For Each oMember In oCABMembers
        Dim sMemberMail
        sMemberMail = SafeGetField(oMember, "Email")
        If Len(Trim(sMemberMail)) > 0 Then
            SendMail sMemberMail, sSubject, sBody, oTicket
        End If
    Next

    ' Transition to Under Review
    oTicket.SetFieldValue "Status", CHG_STATUS_UNDER_REVIEW
End Sub

'------------------------------------------------------------------------------
' Function : BuildCABMailBody
' Purpose  : Compose the CAB notification mail body with all relevant details.
'------------------------------------------------------------------------------
Function BuildCABMailBody(oTicket, oTokens)
    Dim sRiskScore
    sRiskScore = CalculateRiskScore(oTicket)

    BuildCABMailBody = _
        "A change request has been submitted for CAB review." & vbCrLf & vbCrLf & _
        "────────────────────────────────────────" & vbCrLf & _
        " CHANGE DETAILS" & vbCrLf & _
        "────────────────────────────────────────" & vbCrLf & _
        "ID           : " & oTokens(MAIL_TOKEN_TICKET_ID) & vbCrLf & _
        "Type         : " & oTokens(MAIL_TOKEN_CHANGE_TYPE) & vbCrLf & _
        "Summary      : " & oTokens(MAIL_TOKEN_SUMMARY) & vbCrLf & _
        "Assigned to  : " & oTokens(MAIL_TOKEN_ASSIGNED_GROUP) & vbCrLf & vbCrLf & _
        "────────────────────────────────────────" & vbCrLf & _
        " RISK ASSESSMENT" & vbCrLf & _
        "────────────────────────────────────────" & vbCrLf & _
        "Risk Score   : " & sRiskScore & vbCrLf & _
        "Impact       : " & SafeGetField(oTicket, "RiskImpact") & vbCrLf & _
        "Likelihood   : " & SafeGetField(oTicket, "RiskLikelihood") & vbCrLf & vbCrLf & _
        "────────────────────────────────────────" & vbCrLf & _
        " IMPLEMENTATION" & vbCrLf & _
        "────────────────────────────────────────" & vbCrLf & _
        "Planned start: " & SafeGetField(oTicket, "PlannedStart") & vbCrLf & _
        "Planned end  : " & SafeGetField(oTicket, "PlannedEnd") & vbCrLf & _
        "Downtime     : " & SafeGetField(oTicket, "DowntimeMinutes") & " minutes" & vbCrLf & vbCrLf & _
        "────────────────────────────────────────" & vbCrLf & _
        " ROLLBACK PLAN" & vbCrLf & _
        "────────────────────────────────────────" & vbCrLf & _
        SafeGetField(oTicket, "RollbackPlan") & vbCrLf & vbCrLf & _
        "Please open OMNITRACKER to review the full change and cast your approval vote." & vbCrLf & _
        "Voting deadline: 24 hours from now."
End Function

'------------------------------------------------------------------------------
' Function : CalculateRiskScore
' Purpose  : Compute the numeric risk score from Impact and Likelihood fields.
'            Uses the 3x3 matrix defined in docs/itil-processes.md.
' Returns  : Risk score as String ("1" – "9"), or "?" on error
'------------------------------------------------------------------------------
Function CalculateRiskScore(oTicket)
    Dim nImpact
    Dim nLikelihood

    Select Case LCase(SafeGetField(oTicket, "RiskImpact"))
        Case "low"    : nImpact = 1
        Case "medium" : nImpact = 2
        Case "high"   : nImpact = 3
        Case Else     : nImpact = 0
    End Select

    Select Case LCase(SafeGetField(oTicket, "RiskLikelihood"))
        Case "low"    : nLikelihood = 1
        Case "medium" : nLikelihood = 2
        Case "high"   : nLikelihood = 3
        Case Else     : nLikelihood = 0
    End Select

    If nImpact = 0 Or nLikelihood = 0 Then
        CalculateRiskScore = "? (not set)"
    Else
        CalculateRiskScore = CStr(nImpact * nLikelihood)
    End If
End Function
