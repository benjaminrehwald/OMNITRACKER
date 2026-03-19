'==============================================================================
' OMNITRACKER – Common Utility Functions
' File   : scripts/common/utility-functions.vbs
' Usage  : Include via OMNITRACKER Script Include mechanism or copy into any
'          event script that requires these helpers.
' Events : n/a – library only
'==============================================================================
Option Explicit

'------------------------------------------------------------------------------
' Constants – Group names, field names, and status values.
' Change ONLY here when the OMNITRACKER object model is updated.
'------------------------------------------------------------------------------

' Status values for Incident
Const INC_STATUS_NEW             = "New"
Const INC_STATUS_IN_PROGRESS     = "In Progress"
Const INC_STATUS_PENDING_USER    = "Pending (User)"
Const INC_STATUS_PENDING_3RD     = "Pending (3rd Party)"
Const INC_STATUS_ESCALATED       = "Escalated"
Const INC_STATUS_RESOLVED        = "Resolved"
Const INC_STATUS_CLOSED          = "Closed"

' Status values for Service Request
Const SR_STATUS_NEW              = "New"
Const SR_STATUS_PENDING_APPROVAL = "Pending Approval"
Const SR_STATUS_APPROVED         = "Approved"
Const SR_STATUS_REJECTED         = "Rejected"
Const SR_STATUS_IN_FULFILLMENT   = "In Fulfillment"
Const SR_STATUS_PENDING_USER     = "Pending (User)"
Const SR_STATUS_FULFILLED        = "Fulfilled"
Const SR_STATUS_CLOSED           = "Closed"

' Status values for Change
Const CHG_STATUS_DRAFT           = "Draft"
Const CHG_STATUS_SUBMITTED       = "Submitted"
Const CHG_STATUS_UNDER_REVIEW    = "Under Review"
Const CHG_STATUS_CAB_APPROVED    = "CAB Approved"
Const CHG_STATUS_CAB_REJECTED    = "CAB Rejected"
Const CHG_STATUS_IMPLEMENTATION  = "Implementation"
Const CHG_STATUS_PIR             = "Post-Implementation Review"
Const CHG_STATUS_CLOSED          = "Closed"
Const CHG_STATUS_VOTE_CAST       = "Vote Cast"

' Priority values
Const PRIO_CRITICAL              = "P1 - Critical"
Const PRIO_HIGH                  = "P2 - High"
Const PRIO_MEDIUM                = "P3 - Medium"
Const PRIO_LOW                   = "P4 - Low"

' Availability field values
Const FIELD_AVAILABILITY         = "Availability"
Const AVAILABILITY_OOO           = "out of office"

' Field names on Category object
Const CAT_FIELD_DEFAULT_GROUP    = "DefaultGroup"
Const CAT_FIELD_ESCALATION_GROUP = "EscalationGroup"
Const CAT_FIELD_APPROVAL_REQ     = "ApprovalRequired"
Const CAT_FIELD_APPROVER_GROUP   = "ApproverGroup"
Const CAT_FIELD_SLA_HOURS        = "SLA_Hours"
Const CAT_FIELD_AUTO_CLOSE_HOURS = "AutoClose_Hours"

'------------------------------------------------------------------------------
' Function : GetCategoryField
' Purpose  : Read a field value from the Category object linked to a ticket.
' Params   : oTicket    – current ticket Business Object
'            sFieldName – name of the field on the Category object
' Returns  : Field value as String, or "" if not found
'------------------------------------------------------------------------------
Function GetCategoryField(oTicket, sFieldName)
    Dim oCategory
    On Error Resume Next
    Set oCategory = oTicket.GetLinkedObject("Category")
    If Err.Number <> 0 Or oCategory Is Nothing Then
        GetCategoryField = ""
        Exit Function
    End If
    GetCategoryField = CStr(oCategory.GetFieldValue(sFieldName))
    On Error GoTo 0
End Function

'------------------------------------------------------------------------------
' Function : ClassifyTicket
' Purpose  : Determine whether a ticket should be Incident, SR, or Change
'            based on its source object name and category flags.
' Params   : oTicket – current ticket Business Object
' Returns  : "Incident" | "ServiceRequest" | "Change" | "Unknown"
'------------------------------------------------------------------------------
Function ClassifyTicket(oTicket)
    Dim sObjectName
    sObjectName = LCase(oTicket.ObjectName)
    Select Case sObjectName
        Case "incident"
            ClassifyTicket = "Incident"
        Case "servicerequest", "service request", "sr"
            ClassifyTicket = "ServiceRequest"
        Case "change", "changerequest"
            ClassifyTicket = "Change"
        Case Else
            ClassifyTicket = "Unknown"
    End Select
End Function

'------------------------------------------------------------------------------
' Function : CalcSLADeadline
' Purpose  : Calculate SLA deadline from now + N business hours.
'            Business hours are Mon–Fri 07:00–19:00 (CET).
'            Adjust the BUSINESS_START / BUSINESS_END constants for your site.
' Params   : dStart     – start datetime (Date)
'            nHours     – number of business hours to add (Integer)
' Returns  : Deadline as Date
'------------------------------------------------------------------------------
Function CalcSLADeadline(dStart, nHours)
    Const BUSINESS_START = 7   ' 07:00
    Const BUSINESS_END   = 19  ' 19:00
    Const HOURS_PER_DAY  = 12  ' business hours per day

    Dim dCurrent
    Dim nRemaining
    Dim nDayEnd
    Dim nDayAvail

    dCurrent   = dStart
    nRemaining = nHours

    Do While nRemaining > 0
        ' Skip weekends
        Dim nWeekday
        nWeekday = Weekday(dCurrent, vbMonday)  ' 1=Mon … 7=Sun
        If nWeekday >= 6 Then
            ' Saturday or Sunday – jump to next Monday at BUSINESS_START
            dCurrent = DateSerial(Year(dCurrent), Month(dCurrent), _
                                  Day(dCurrent) + (8 - nWeekday)) _
                     + TimeSerial(BUSINESS_START, 0, 0)
        Else
            ' How many business hours are left today from dCurrent?
            Dim nCurrentHour
            nCurrentHour = Hour(dCurrent)
            If nCurrentHour < BUSINESS_START Then
                ' Before business hours – jump to start of business
                dCurrent = DateSerial(Year(dCurrent), Month(dCurrent), _
                                      Day(dCurrent)) _
                         + TimeSerial(BUSINESS_START, 0, 0)
                nCurrentHour = BUSINESS_START
            ElseIf nCurrentHour >= BUSINESS_END Then
                ' After business hours – jump to next business day
                dCurrent = DateSerial(Year(dCurrent), Month(dCurrent), _
                                      Day(dCurrent) + 1) _
                         + TimeSerial(BUSINESS_START, 0, 0)
            Else
                nDayAvail = BUSINESS_END - nCurrentHour
                If nRemaining <= nDayAvail Then
                    dCurrent   = dCurrent + TimeSerial(nRemaining, 0, 0)
                    nRemaining = 0
                Else
                    nRemaining = nRemaining - nDayAvail
                    dCurrent   = DateSerial(Year(dCurrent), Month(dCurrent), _
                                            Day(dCurrent) + 1) _
                               + TimeSerial(BUSINESS_START, 0, 0)
                End If
            End If
        End If
    Loop

    CalcSLADeadline = dCurrent
End Function

'------------------------------------------------------------------------------
' Function : SafeGetField
' Purpose  : Read a field from a Business Object without raising an error.
' Params   : oObj       – Business Object
'            sFieldName – field name
' Returns  : Field value as String, or "" on error
'------------------------------------------------------------------------------
Function SafeGetField(oObj, sFieldName)
    On Error Resume Next
    SafeGetField = CStr(oObj.GetFieldValue(sFieldName))
    If Err.Number <> 0 Then SafeGetField = ""
    On Error GoTo 0
End Function

'------------------------------------------------------------------------------
' Sub     : LogScriptError
' Purpose : Write a structured error entry to the OMNITRACKER application log.
' Params  : sScript   – name of the calling script
'           sMessage  – human-readable error description
'           oTicket   – Business Object (may be Nothing)
'------------------------------------------------------------------------------
Sub LogScriptError(sScript, sMessage, oTicket)
    Dim sTicketID
    If Not oTicket Is Nothing Then
        sTicketID = SafeGetField(oTicket, "TicketID")
    Else
        sTicketID = "N/A"
    End If
    OTApp.LogMessage "ERROR [" & sScript & "] Ticket=" & sTicketID & " – " & sMessage
End Sub
