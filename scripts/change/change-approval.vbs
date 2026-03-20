'==============================================================================
' OMNITRACKER – Change Approval State Machine
' File   : scripts/change/change-approval.vbs
' Event  : Change → OnStatusChange
' Purpose: Drive the change through its approval lifecycle.
'          – Tracks vote counts (Approved / Rejected) on the Change object.
'          – Moves to CAB Approved when quorum is reached.
'          – Moves to CAB Rejected if any rejection exceeds the threshold.
'          – Handles Emergency CAB (smaller quorum, faster path).
'==============================================================================
Option Explicit

' #Include "common/utility-functions.vbs"
' #Include "common/mail-templates.vbs"

' Quorum constants (adjust to match your CAB size)
Const NORMAL_APPROVE_QUORUM  = 3   ' votes needed to approve a Normal change
Const EMERGENCY_APPROVE_QUORUM = 2 ' votes needed to approve an Emergency change
Const MAX_REJECT_VOTES       = 1   ' rejections that trigger CAB Rejected

'------------------------------------------------------------------------------
' Entry point
'------------------------------------------------------------------------------
Sub OnStatusChange(oTicket, sOldStatus, sNewStatus)
    Select Case sNewStatus
        Case CHG_STATUS_VOTE_CAST
            ' Triggered when a CAB member saves their vote
            EvaluateVotes oTicket

        Case CHG_STATUS_CAB_APPROVED
            HandleCABApproved oTicket

        Case CHG_STATUS_CAB_REJECTED
            HandleCABRejected oTicket

        Case CHG_STATUS_IMPLEMENTATION
            HandleImplementationStart oTicket

        Case CHG_STATUS_PIR
            HandlePIR oTicket
    End Select
End Sub

'------------------------------------------------------------------------------
' Sub : EvaluateVotes
' Purpose: Count approval and rejection votes; transition if quorum reached.
'------------------------------------------------------------------------------
Sub EvaluateVotes(oTicket)
    Const FIELD_APPROVE_VOTES = "CABApproveVotes"
    Const FIELD_REJECT_VOTES  = "CABRejectVotes"

    Dim nApprove
    Dim nReject
    nApprove = CInt(SafeGetField(oTicket, FIELD_APPROVE_VOTES))
    nReject  = CInt(SafeGetField(oTicket, FIELD_REJECT_VOTES))

    Dim nQuorum
    If LCase(SafeGetField(oTicket, "ChangeType")) = "emergency" Then
        nQuorum = EMERGENCY_APPROVE_QUORUM
    Else
        nQuorum = NORMAL_APPROVE_QUORUM
    End If

    If nReject >= MAX_REJECT_VOTES Then
        oTicket.SetFieldValue "Status", CHG_STATUS_CAB_REJECTED
    ElseIf nApprove >= nQuorum Then
        oTicket.SetFieldValue "Status", CHG_STATUS_CAB_APPROVED
    End If
    ' Otherwise stay in Under Review – more votes needed
End Sub

'------------------------------------------------------------------------------
' Sub : HandleCABApproved
' Purpose: Notify change owner that CAB has approved; implementation may begin.
'------------------------------------------------------------------------------
Sub HandleCABApproved(oTicket)
    Dim sOwnerMail
    sOwnerMail = GetUserMailByLogin(SafeGetField(oTicket, "ChangeOwner"))
    If Len(Trim(sOwnerMail)) > 0 Then
        Dim sBody
        sBody = "Your change request " & SafeGetField(oTicket, "TicketID") & _
                " has been approved by the CAB." & vbCrLf & vbCrLf & _
                "Summary      : " & SafeGetField(oTicket, "Summary") & vbCrLf & _
                "Planned start: " & SafeGetField(oTicket, "PlannedStart") & vbCrLf & _
                "Planned end  : " & SafeGetField(oTicket, "PlannedEnd") & vbCrLf & vbCrLf & _
                "You may proceed with implementation within the approved window." & vbCrLf & _
                "Please update the change record upon completion."
        SendMail sOwnerMail, _
                 "CAB Approved: " & SafeGetField(oTicket, "TicketID"), _
                 sBody, oTicket
    End If
End Sub

'------------------------------------------------------------------------------
' Sub : HandleCABRejected
' Purpose: Notify change owner that CAB has rejected the change.
'------------------------------------------------------------------------------
Sub HandleCABRejected(oTicket)
    Dim sOwnerMail
    sOwnerMail = GetUserMailByLogin(SafeGetField(oTicket, "ChangeOwner"))
    If Len(Trim(sOwnerMail)) > 0 Then
        Dim sBody
        sBody = "Your change request " & SafeGetField(oTicket, "TicketID") & _
                " has been rejected by the CAB." & vbCrLf & vbCrLf & _
                "Summary     : " & SafeGetField(oTicket, "Summary") & vbCrLf & _
                "CAB Comments: " & SafeGetField(oTicket, "CABComments") & vbCrLf & vbCrLf & _
                "Please revise the change record and resubmit for review."
        SendMail sOwnerMail, _
                 "CAB Rejected: " & SafeGetField(oTicket, "TicketID"), _
                 sBody, oTicket
    End If
End Sub

'------------------------------------------------------------------------------
' Sub : HandleImplementationStart
' Purpose: Record actual start time and notify stakeholders.
'------------------------------------------------------------------------------
Sub HandleImplementationStart(oTicket)
    ' Record actual start
    On Error Resume Next
    oTicket.SetFieldValue "ActualStart", Now()
    If Err.Number <> 0 Then
        LogScriptError "change-approval.vbs", "Failed to set ActualStart: " & Err.Description, oTicket
        Err.Clear
    End If
    On Error GoTo 0

    ' Notify all affected users if specified
    Dim sAffectedGroup
    sAffectedGroup = SafeGetField(oTicket, "AffectedGroup")
    If Len(Trim(sAffectedGroup)) > 0 Then
        Dim sGroupMail
        sGroupMail = GetGroupMailAddress(sAffectedGroup)
        If Len(Trim(sGroupMail)) > 0 Then
            Dim sBody
            sBody = "Please be advised that a planned change is now being implemented." & vbCrLf & vbCrLf & _
                    "Change ID    : " & SafeGetField(oTicket, "TicketID") & vbCrLf & _
                    "Summary      : " & SafeGetField(oTicket, "Summary") & vbCrLf & _
                    "Planned end  : " & SafeGetField(oTicket, "PlannedEnd") & vbCrLf & _
                    "Downtime     : " & SafeGetField(oTicket, "DowntimeMinutes") & " minutes" & vbCrLf & vbCrLf & _
                    "You may experience service interruption during this window."
            SendMail sGroupMail, _
                     "Planned Change in Progress: " & SafeGetField(oTicket, "TicketID"), _
                     sBody, oTicket
        End If
    End If
End Sub

'------------------------------------------------------------------------------
' Sub : HandlePIR
' Purpose: Transition to PIR state and notify change owner to complete review.
'------------------------------------------------------------------------------
Sub HandlePIR(oTicket)
    On Error Resume Next
    oTicket.SetFieldValue "ActualEnd", Now()
    On Error GoTo 0

    Dim sOwnerMail
    sOwnerMail = GetUserMailByLogin(SafeGetField(oTicket, "ChangeOwner"))
    If Len(Trim(sOwnerMail)) > 0 Then
        Dim sBody
        sBody = "Change " & SafeGetField(oTicket, "TicketID") & " has been implemented." & vbCrLf & vbCrLf & _
                "Please complete the Post-Implementation Review in OMNITRACKER within 2 business days." & vbCrLf & _
                "Include: outcome, issues encountered, and whether objectives were met."
        SendMail sOwnerMail, _
                 "PIR Required: " & SafeGetField(oTicket, "TicketID"), _
                 sBody, oTicket
    End If
End Sub

'------------------------------------------------------------------------------
' Function : GetUserMailByLogin (local copy)
'------------------------------------------------------------------------------
Function GetUserMailByLogin(sLogin)
    On Error Resume Next
    Dim oUser
    Set oUser = OTApp.GetUser(sLogin)
    If Err.Number <> 0 Or oUser Is Nothing Then
        GetUserMailByLogin = ""
        Err.Clear
        Exit Function
    End If
    GetUserMailByLogin = SafeGetField(oUser, "Email")
    On Error GoTo 0
End Function

'------------------------------------------------------------------------------
' Function : GetGroupMailAddress (local copy)
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
