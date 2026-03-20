'==============================================================================
' OMNITRACKER – Incident Auto-Assignment
' File   : scripts/incident/auto-assignment.vbs
' Event  : Incident → OnCreate (runs AFTER auto-routing.vbs)
' Purpose: Within the assigned group, find the agent with the lowest number of
'          open incidents and assign the ticket to that agent.
'          If the group has no available agents, the ticket stays unassigned
'          (group-level) so the group leader can assign manually.
'==============================================================================
Option Explicit

' #Include "common/utility-functions.vbs"

'------------------------------------------------------------------------------
' Entry point
'------------------------------------------------------------------------------
Sub OnCreate(oTicket)
    Const FIELD_ASSIGNED_AGENT  = "AssignedAgent"
    Const FIELD_ASSIGNED_GROUP  = "AssignedGroup"
    Const MAX_LOAD_PER_AGENT    = 20  ' Max open tickets before agent is skipped

    Dim sGroup
    sGroup = SafeGetField(oTicket, FIELD_ASSIGNED_GROUP)

    If Len(Trim(sGroup)) = 0 Then
        LogScriptError "auto-assignment.vbs", "AssignedGroup is empty; cannot auto-assign.", oTicket
        Exit Sub
    End If

    ' --- Find least-loaded active agent in the group ---
    Dim sBestAgent
    Dim nBestLoad
    sBestAgent = ""
    nBestLoad  = MAX_LOAD_PER_AGENT + 1  ' sentinel – anything lower wins

    On Error Resume Next
    Dim oGroupMembers
    Set oGroupMembers = OTApp.GetGroupMembers(sGroup)
    If Err.Number <> 0 Or oGroupMembers Is Nothing Then
        LogScriptError "auto-assignment.vbs", _
            "Cannot retrieve members of group '" & sGroup & "': " & Err.Description, oTicket
        Err.Clear
        Exit Sub
    End If
    On Error GoTo 0

    Dim oMember
    For Each oMember In oGroupMembers
        ' Only consider agents who are currently available (not Out-of-Office)
        If LCase(SafeGetField(oMember, FIELD_AVAILABILITY)) <> AVAILABILITY_OOO Then
            Dim nLoad
            nLoad = GetAgentOpenTicketCount(oMember.LoginName, "Incident")
            If nLoad < nBestLoad Then
                nBestLoad  = nLoad
                sBestAgent = oMember.LoginName
            End If
        End If
    Next

    ' --- Assign if a suitable agent was found ---
    If Len(Trim(sBestAgent)) > 0 And nBestLoad <= MAX_LOAD_PER_AGENT Then
        On Error Resume Next
        oTicket.SetFieldValue FIELD_ASSIGNED_AGENT, sBestAgent
        If Err.Number <> 0 Then
            LogScriptError "auto-assignment.vbs", _
                "Failed to set AssignedAgent to '" & sBestAgent & "': " & Err.Description, oTicket
            Err.Clear
        End If
        On Error GoTo 0
    Else
        ' Log that no agent was available; ticket remains at group level
        LogScriptError "auto-assignment.vbs", _
            "No available agent found in group '" & sGroup & "' (all at max load or OOO). " & _
            "Ticket left at group level.", oTicket
    End If
End Sub

'------------------------------------------------------------------------------
' Function : GetAgentOpenTicketCount
' Purpose  : Return the number of open tickets of a given object type
'            assigned to a specific agent login.
' Params   : sLogin      – agent login name
'            sObjectType – "Incident" | "ServiceRequest" | "Change"
' Returns  : Integer count
'------------------------------------------------------------------------------
Function GetAgentOpenTicketCount(sLogin, sObjectType)
    Dim nCount
    nCount = 0
    On Error Resume Next
    Dim oSearch
    Set oSearch = OTApp.CreateSearch(sObjectType)
    oSearch.AddFilter "AssignedAgent", "=", sLogin
    oSearch.AddFilter "Status", "<>", "Closed"
    oSearch.AddFilter "Status", "<>", "Resolved"
    oSearch.AddFilter "Status", "<>", "Fulfilled"
    nCount = oSearch.Count
    If Err.Number <> 0 Then
        nCount = 0
        Err.Clear
    End If
    On Error GoTo 0
    GetAgentOpenTicketCount = nCount
End Function
