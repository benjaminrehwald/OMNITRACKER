LogMessage "wsREST_Ping DEBUG: Body (start)=" & Left(ActiveWsRESTRequest.InputBody, 1000)

On Error Resume Next

Dim strTitle, strDescription

strTitle = ActiveWsRESTRequest.GetBodyAttributeValue("title")
strDescription = ActiveWsRESTRequest.GetBodyAttributeValue("description")
strAffectedPerson = ActiveWsRESTRequest.GetBodyAttributeValue("affectedPersonEmail")

Dim objFolder, objNewInc
Set objFolder = ActiveSession.RequestFolders("CallTickets")
Set objNewInc = objFolder.Requests.Add

objNewInc.UserFields("Title").TValue = strTitle
objNewInc.UserFields("Description").TValue = strDescription

'B . Rehwald - Betroffene Person muss angelegt sein und hinterlegt werden, da hier mehrere Mailadressen notwendig sind gibt esn ur eine Person, daher via SCript
If objNewInc.Fields("AffectedPerson").IsNull Then
    'Set objAffectedPerson = objNewInc.Fields("AffectedPerson").TValue
    Set fld = ActiveSession.GetRequestFolderByPath("MasterData\HumanResources\Persons\Persons_OT")
    'set fld = ActiveSession.RequestFolders("MasterData\HumanResources\Persons")
    Set filt = fld.MakeFilter
    filt.UserField("Email Address") = strAffectedPerson
    ' filt.UserField("Title") = "Aray, Aylin"
    filt.UserFieldComparison("Email Address") = 15 ' otComparisonMatches
    Set objSearchResults = fld.Search(filt, False) '
    'LogMessage "gefundene Personen " & objSearchResults.Count
    If objSearchResults.Count = 1 Then

	Set objAffectedPerson = objSearchResults(0)
	objNewInc.Fields("AffectedPerson").TValue = objAffectedPerson
	If Not objAffectedPerson.Fields("Company").IsNull Then
	    objNewInc.Fields("ReportingCompany").TValue = objAffectedPerson.Fields("Company").TValue
	End If

	If Not objAffectedPerson.Fields("Location").IsNull Then
	    objNewInc.Fields("ReportingLocation").TValue = objAffectedPerson.Fields("Location").TValue
	End If
    End If
End If



objNewInc.Save

Dim lngErr, strErr, strTicketNr
lngErr = Err.Number
strErr = Err.Description

If lngErr = 0 Then
    strTicketNr = CStr(objNewInc.Fields("Number").TValue)
End If

Err.Clear
On Error GoTo 0

If lngErr = 0 Then
    ActiveWsRESTResponse.ContentType = "application/json"
    ActiveWsRESTResponse.Content     = "{""status"":""ok"",""ticketNr"":""" & strTicketNr & """}"
Else
    LogMessage "Err.Number=" & lngErr & " Err.Description=" & strErr
    ActiveWsRESTResponse.ContentType = "application/json"
    ActiveWsRESTResponse.Content     = "{""status"":""error"",""message"":""" & Replace(strErr, """", "'") & """}"
End If
