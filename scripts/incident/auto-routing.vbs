'==============================================================================
' OMNITRACKER – Incident Auto-Routing
' File   : scripts/incident/auto-routing.vbs
' Event  : Incident → OnCreate
' Purpose: Read the DefaultGroup from the selected Category object and set the
'          AssignedGroup field on the new Incident automatically.
'          Falls back to "Service Desk" if no routing rule is defined.
'==============================================================================
Option Explicit

' Include shared library (OMNITRACKER Script Include)
' #Include "common/utility-functions.vbs"

'------------------------------------------------------------------------------
' Entry point – called by OMNITRACKER on Incident OnCreate event
' oTicket : current Incident Business Object (provided by the runtime)
'------------------------------------------------------------------------------
Sub OnCreate(oTicket)
    Const FALLBACK_GROUP   = "Service Desk"
    Const FIELD_ASSIGNED   = "AssignedGroup"
    Const FIELD_CATEGORY   = "Category"

    Dim sDefaultGroup

    ' --- 1. Read routing group from Category ---
    sDefaultGroup = GetCategoryField(oTicket, CAT_FIELD_DEFAULT_GROUP)

    ' --- 2. Fall back to Service Desk if category has no routing rule ---
    If Len(Trim(sDefaultGroup)) = 0 Then
        sDefaultGroup = FALLBACK_GROUP
        LogScriptError "auto-routing.vbs", _
            "No DefaultGroup on Category – using fallback '" & FALLBACK_GROUP & "'", _
            oTicket
    End If

    ' --- 3. Set AssignedGroup on the ticket ---
    On Error Resume Next
    oTicket.SetFieldValue FIELD_ASSIGNED, sDefaultGroup
    If Err.Number <> 0 Then
        LogScriptError "auto-routing.vbs", _
            "Failed to set AssignedGroup to '" & sDefaultGroup & "': " & Err.Description, _
            oTicket
        Err.Clear
    End If
    On Error GoTo 0

    ' --- 4. Send confirmation mail to requester ---
    Dim oTokens
    Set oTokens = BuildTokenDict(oTicket)
    ' Overwrite SLA_Deadline token with freshly calculated value
    Dim nSLAHours
    nSLAHours = CInt(GetCategoryField(oTicket, CAT_FIELD_SLA_HOURS))
    If nSLAHours = 0 Then nSLAHours = 24  ' default if not configured
    oTokens(MAIL_TOKEN_SLA_DEADLINE) = _
        Format(CalcSLADeadline(Now(), nSLAHours), "dd.MM.yyyy HH:mm")

    Dim sRequesterMail
    sRequesterMail = SafeGetField(oTicket, "RequesterEmail")
    If Len(Trim(sRequesterMail)) > 0 Then
        SendMail sRequesterMail, _
                 "Your incident " & oTokens(MAIL_TOKEN_TICKET_ID) & " has been registered", _
                 RenderTemplate(GetTemplate_INC_Created(), oTokens), _
                 oTicket
    End If
End Sub
