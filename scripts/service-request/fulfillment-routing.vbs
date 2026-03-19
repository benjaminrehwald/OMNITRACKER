'==============================================================================
' OMNITRACKER – Service Request Fulfillment Routing
' File   : scripts/service-request/fulfillment-routing.vbs
' Event  : ServiceRequest → OnStatusChange (triggers on Approved → In Fulfillment)
' Purpose: When a Service Request is approved, route it to the correct
'          fulfillment group and set the SLA deadline.
'==============================================================================
Option Explicit

' #Include "common/utility-functions.vbs"
' #Include "common/mail-templates.vbs"

'------------------------------------------------------------------------------
' Entry point
'------------------------------------------------------------------------------
Sub OnStatusChange(oTicket, sOldStatus, sNewStatus)
    ' Only act on the transition to Approved
    If sNewStatus <> SR_STATUS_APPROVED Then Exit Sub

    Const FIELD_ASSIGNED_GROUP  = "AssignedGroup"
    Const FIELD_STATUS          = "Status"
    Const FIELD_SLA_DEADLINE    = "SLA_Deadline"
    Const FALLBACK_GROUP        = "Service Desk"

    ' --- 1. Read fulfillment group from Catalog Item ---
    Dim sFulfillmentGroup
    sFulfillmentGroup = GetFulfillmentGroup(oTicket)
    If Len(Trim(sFulfillmentGroup)) = 0 Then
        sFulfillmentGroup = FALLBACK_GROUP
        LogScriptError "fulfillment-routing.vbs", _
            "No FulfillmentGroup found for catalog item; using fallback '" & FALLBACK_GROUP & "'", _
            oTicket
    End If

    ' --- 2. Assign to fulfillment group ---
    On Error Resume Next
    oTicket.SetFieldValue FIELD_ASSIGNED_GROUP, sFulfillmentGroup
    If Err.Number <> 0 Then
        LogScriptError "fulfillment-routing.vbs", _
            "Failed to set AssignedGroup: " & Err.Description, oTicket
        Err.Clear
    End If
    On Error GoTo 0

    ' --- 3. Calculate and store SLA deadline ---
    Dim nSLAHours
    nSLAHours = CInt(GetCategoryField(oTicket, CAT_FIELD_SLA_HOURS))
    If nSLAHours = 0 Then nSLAHours = 16  ' default 2 business days

    Dim dDeadline
    dDeadline = CalcSLADeadline(Now(), nSLAHours)
    On Error Resume Next
    oTicket.SetFieldValue FIELD_SLA_DEADLINE, dDeadline
    If Err.Number <> 0 Then
        LogScriptError "fulfillment-routing.vbs", _
            "Failed to set SLA_Deadline: " & Err.Description, oTicket
        Err.Clear
    End If
    On Error GoTo 0

    ' --- 4. Transition to In Fulfillment ---
    oTicket.SetFieldValue FIELD_STATUS, SR_STATUS_IN_FULFILLMENT

    ' --- 5. Notify fulfillment group ---
    Dim sGroupMail
    sGroupMail = GetGroupMailAddress(sFulfillmentGroup)
    If Len(Trim(sGroupMail)) > 0 Then
        Dim sBody
        sBody = "A new service request requires fulfillment." & vbCrLf & vbCrLf & _
                "Ticket      : " & SafeGetField(oTicket, "TicketID") & vbCrLf & _
                "Service     : " & SafeGetField(oTicket, "CatalogItem") & vbCrLf & _
                "Requester   : " & SafeGetField(oTicket, "RequesterName") & vbCrLf & _
                "Summary     : " & SafeGetField(oTicket, "Summary") & vbCrLf & _
                "SLA deadline: " & Format(dDeadline, "dd.MM.yyyy HH:mm") & vbCrLf & vbCrLf & _
                "Please open OMNITRACKER to review and action this request."
        SendMail sGroupMail, _
                 "New SR for fulfillment: " & SafeGetField(oTicket, "TicketID"), _
                 sBody, oTicket
    End If
End Sub

'------------------------------------------------------------------------------
' Function : GetFulfillmentGroup
' Purpose  : Read the FulfillmentGroup field from the linked Catalog Item.
'            Falls back to the Category DefaultGroup if the Catalog Item
'            does not define a dedicated fulfillment group.
' Params   : oTicket – Service Request Business Object
' Returns  : Group name as String
'------------------------------------------------------------------------------
Function GetFulfillmentGroup(oTicket)
    Dim sCatalogGroup

    On Error Resume Next
    Dim oCatalogItem
    Set oCatalogItem = oTicket.GetLinkedObject("CatalogItem")
    If Err.Number = 0 And Not oCatalogItem Is Nothing Then
        sCatalogGroup = SafeGetField(oCatalogItem, "FulfillmentGroup")
    End If
    On Error GoTo 0

    If Len(Trim(sCatalogGroup)) > 0 Then
        GetFulfillmentGroup = sCatalogGroup
    Else
        ' Fall back to Category DefaultGroup
        GetFulfillmentGroup = GetCategoryField(oTicket, CAT_FIELD_DEFAULT_GROUP)
    End If
End Function

'------------------------------------------------------------------------------
' Function : GetGroupMailAddress (local copy – avoids missing include error)
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
