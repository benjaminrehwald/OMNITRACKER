'==============================================================================
' OMNITRACKER – Service Request Approval Workflow
' File   : scripts/service-request/approval-workflow.vbs
' Events : ServiceRequest → OnCreate
'          ServiceRequest → OnStatusChange (handles approval decisions)
' Purpose: Multi-level approval chain based on the Service Catalog item.
'          Level 1: Line Manager of the requester
'          Level 2: IT Service Owner / ApproverGroup
'          Timeout: escalate to ApproverGroup after 24 business hours
'==============================================================================
Option Explicit

' #Include "common/utility-functions.vbs"
' #Include "common/mail-templates.vbs"

'------------------------------------------------------------------------------
' OnCreate – route to approval if required, else straight to fulfillment
'------------------------------------------------------------------------------
Sub OnCreate(oTicket)
    Const FIELD_STATUS           = "Status"
    Const FIELD_APPROVAL_LEVEL   = "ApprovalLevel"
    Const FIELD_CURRENT_APPROVER = "CurrentApprover"

    Dim bApprovalRequired
    bApprovalRequired = CBool(GetCategoryField(oTicket, CAT_FIELD_APPROVAL_REQ))

    If Not bApprovalRequired Then
        ' No approval needed – go straight to fulfillment state
        oTicket.SetFieldValue FIELD_STATUS, SR_STATUS_APPROVED
        Exit Sub
    End If

    ' Set initial state and approval level
    oTicket.SetFieldValue FIELD_STATUS, SR_STATUS_PENDING_APPROVAL
    oTicket.SetFieldValue FIELD_APPROVAL_LEVEL, "1"

    ' Determine and notify Level-1 approver (line manager)
    Dim sLineManager
    sLineManager = GetLineManager(SafeGetField(oTicket, "RequesterLogin"))
    If Len(Trim(sLineManager)) > 0 Then
        oTicket.SetFieldValue FIELD_CURRENT_APPROVER, sLineManager
        NotifyApprover oTicket, sLineManager, "1"
    Else
        ' No line manager found – escalate to ApproverGroup
        Dim sApproverGroup
        sApproverGroup = GetCategoryField(oTicket, CAT_FIELD_APPROVER_GROUP)
        LogScriptError "approval-workflow.vbs", _
            "No line manager for requester; escalating to group '" & sApproverGroup & "'", _
            oTicket
        NotifyApproverGroup oTicket, sApproverGroup
    End If
End Sub

'------------------------------------------------------------------------------
' OnStatusChange – react to Approved / Rejected decisions
'------------------------------------------------------------------------------
Sub OnStatusChange(oTicket, sOldStatus, sNewStatus)
    Const FIELD_APPROVAL_LEVEL   = "ApprovalLevel"
    Const FIELD_CURRENT_APPROVER = "CurrentApprover"

    Select Case sNewStatus
        Case "L1 Approved"
            ' Level 1 approved – check if Level 2 or 3 needed
            Dim nApprovalLevel
            nApprovalLevel = CInt(GetCategoryField(oTicket, "ApprovalLevel"))
            If nApprovalLevel >= 2 Then
                oTicket.SetFieldValue FIELD_APPROVAL_LEVEL, "2"
                Dim sApproverGroup
                sApproverGroup = GetCategoryField(oTicket, CAT_FIELD_APPROVER_GROUP)
                NotifyApproverGroup oTicket, sApproverGroup
                oTicket.SetFieldValue "Status", SR_STATUS_PENDING_APPROVAL
            Else
                ' Only 1 level required – move to Approved
                FinaliseApproval oTicket, True
            End If

        Case "L2 Approved"
            ' Level 2 approved – check if Level 3 needed (e.g. CISO sign-off)
            Dim nApprovalLevel2
            nApprovalLevel2 = CInt(GetCategoryField(oTicket, "ApprovalLevel"))
            If nApprovalLevel2 >= 3 Then
                oTicket.SetFieldValue FIELD_APPROVAL_LEVEL, "3"
                Dim sL3ApproverGroup
                sL3ApproverGroup = SafeGetField(oTicket, "L3ApproverGroup")
                If Len(Trim(sL3ApproverGroup)) = 0 Then
                    sL3ApproverGroup = GetCategoryField(oTicket, CAT_FIELD_APPROVER_GROUP)
                End If
                NotifyApproverGroup oTicket, sL3ApproverGroup
                oTicket.SetFieldValue "Status", SR_STATUS_PENDING_APPROVAL
            Else
                FinaliseApproval oTicket, True
            End If

        Case "L3 Approved"
            FinaliseApproval oTicket, True

        Case "Rejected"
            FinaliseApproval oTicket, False

        Case SR_STATUS_APPROVED
            ' Approval complete – notify requester
            NotifyRequesterStatusChange oTicket, SR_STATUS_APPROVED, _
                "Your service request " & SafeGetField(oTicket, "TicketID") & " has been approved", _
                GetTemplate_SR_Approved()

        Case SR_STATUS_REJECTED
            NotifyRequesterStatusChange oTicket, SR_STATUS_REJECTED, _
                "Your service request " & SafeGetField(oTicket, "TicketID") & " has been rejected", _
                GetTemplate_SR_Rejected()
    End Select
End Sub

'------------------------------------------------------------------------------
' Sub : FinaliseApproval
' Purpose: Transition SR to Approved or Rejected and notify requester.
'------------------------------------------------------------------------------
Sub FinaliseApproval(oTicket, bApproved)
    If bApproved Then
        oTicket.SetFieldValue "Status", SR_STATUS_APPROVED
    Else
        oTicket.SetFieldValue "Status", SR_STATUS_REJECTED
    End If
End Sub

'------------------------------------------------------------------------------
' Sub : NotifyApprover
' Purpose: Send approval request mail to a named approver.
'------------------------------------------------------------------------------
Sub NotifyApprover(oTicket, sApproverLogin, sLevel)
    Dim sApproverMail
    sApproverMail = GetUserMailByLogin(sApproverLogin)
    If Len(Trim(sApproverMail)) = 0 Then
        LogScriptError "approval-workflow.vbs", _
            "No mail address for approver '" & sApproverLogin & "'", oTicket
        Exit Sub
    End If

    Dim sBody
    sBody = "You have a pending approval request (Level " & sLevel & ")." & vbCrLf & vbCrLf & _
            "Ticket    : " & SafeGetField(oTicket, "TicketID") & vbCrLf & _
            "Service   : " & SafeGetField(oTicket, "CatalogItem") & vbCrLf & _
            "Requested by: " & SafeGetField(oTicket, "RequesterName") & vbCrLf & _
            "Summary   : " & SafeGetField(oTicket, "Summary") & vbCrLf & vbCrLf & _
            "Please approve or reject in OMNITRACKER." & vbCrLf & _
            "If no response within 24 hours, the request will be escalated."
    SendMail sApproverMail, _
             "Approval required: " & SafeGetField(oTicket, "TicketID"), _
             sBody, oTicket
End Sub

'------------------------------------------------------------------------------
' Sub : NotifyApproverGroup
' Purpose: Send approval request to the fallback approver group mail address.
'------------------------------------------------------------------------------
Sub NotifyApproverGroup(oTicket, sGroupName)
    Dim sGroupMail
    sGroupMail = GetGroupMailAddress(sGroupName)
    If Len(Trim(sGroupMail)) = 0 Then
        LogScriptError "approval-workflow.vbs", _
            "No mail address for approver group '" & sGroupName & "'", oTicket
        Exit Sub
    End If

    Dim sBody
    sBody = "You have a pending approval request (Group fallback)." & vbCrLf & vbCrLf & _
            "Ticket    : " & SafeGetField(oTicket, "TicketID") & vbCrLf & _
            "Service   : " & SafeGetField(oTicket, "CatalogItem") & vbCrLf & _
            "Requested by: " & SafeGetField(oTicket, "RequesterName") & vbCrLf & _
            "Summary   : " & SafeGetField(oTicket, "Summary") & vbCrLf & vbCrLf & _
            "Please approve or reject in OMNITRACKER." & vbCrLf & _
            "If no response within 24 hours, the request will be escalated."
    SendMail sGroupMail, _
             "Approval required: " & SafeGetField(oTicket, "TicketID"), _
             sBody, oTicket
End Sub

'------------------------------------------------------------------------------
' Sub : NotifyRequesterStatusChange
' Purpose: Send a rendered template mail to the requester on status change.
'          Eliminates duplicated token-building / send pattern.
'------------------------------------------------------------------------------
Sub NotifyRequesterStatusChange(oTicket, sStatus, sSubject, sTemplate)
    Dim sRequesterMail
    sRequesterMail = SafeGetField(oTicket, "RequesterEmail")
    If Len(Trim(sRequesterMail)) = 0 Then Exit Sub
    Dim oTokens
    Set oTokens = BuildTokenDict(oTicket)
    SendMail sRequesterMail, sSubject, RenderTemplate(sTemplate, oTokens), oTicket
End Sub

'------------------------------------------------------------------------------
' Function : GetLineManager
' Purpose  : Look up the line manager login for a given user login.
'------------------------------------------------------------------------------
Function GetLineManager(sLogin)
    On Error Resume Next
    Dim oUser
    Set oUser = OTApp.GetUser(sLogin)
    If Err.Number <> 0 Or oUser Is Nothing Then
        GetLineManager = ""
        Err.Clear
        Exit Function
    End If
    GetLineManager = SafeGetField(oUser, "ManagerLogin")
    On Error GoTo 0
End Function

'------------------------------------------------------------------------------
' Function : GetUserMailByLogin
' Purpose  : Return the e-mail address of a user identified by login name.
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
' Function : GetGroupMailAddress
' Purpose  : Return the mail address of a group (needed when not using include)
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
