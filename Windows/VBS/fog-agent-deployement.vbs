On Error Resume Next
'Declaration variables
Public fog_agent_url, fog_agent_param_install, objFSO
strComputer = "."
'Init des objets
Set objFSO = CreateObject("Scripting.FileSystemObject")
' Fog url download agent
fog_agent_url = "http://fqdn/fog/client/download.php?newclient"
fog_agent_param_install = "/quiet" & " WEBADDRESS="& Chr(34) &"fqdn" & Chr(34) & " WEBROOT=" & Chr(34) &"/fog" & Chr(34)

'
'	Retourne si le poste est desktop ou autre
'
Function GetTypeComputer()
	Set objWMIService = GetObject("winmgmts:" _
		& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
	Set colChassis = objWMIService.ExecQuery _
		("Select * from Win32_SystemEnclosure")
	For Each objChassis in colChassis
		For  Each strChassisType in objChassis.ChassisTypes
			'Wscript.Echo strChassisType
			Select Case strChassisType
				Case 3
					GetTypeComputer = "desktop"
				Case 4
					GetTypeComputer = "desktop"
				Case 6 
					GetTypeComputer = "desktop"
				Case 7
					GetTypeComputer = "desktop"
				Case Else
					GetTypeComputer = "other"
			End Select
		Next
	Next
End Function

'
'	Permet le telechargement de fichier en VBS
'
' http://www.ericphelps.com/scripting/samples/wget/index.html
'
Function SaveWebBinary(strUrl) 'As Boolean
	Const adTypeBinary = 1  
	Const adSaveCreateOverWrite = 2
	Const ForWriting = 2
	Dim web, varByteArray, strData, strBuffer, lngCounter, ado
	'    On Error Resume Next
    'Download the file with any available object
    Err.Clear
    Set web = Nothing
    Set web = CreateObject("WinHttp.WinHttpRequest.5.1")
    If web Is Nothing Then Set web = CreateObject("WinHttp.WinHttpRequest")
    If web Is Nothing Then Set web = CreateObject("MSXML2.ServerXMLHTTP")
    If web Is Nothing Then Set web = CreateObject("Microsoft.XMLHTTP")
    web.Open "GET", strURL, False
    web.Send
    If Err.Number <> 0 Then
        SaveWebBinary = False
        Set web = Nothing
        Exit Function
    End If
    If web.Status <> "200" Then
        SaveWebBinary = False
        Set web = Nothing
        Exit Function
    End If
    varByteArray = web.ResponseBody
    Set web = Nothing
    'Now save the file with any available method
    On Error Resume Next
    Set ado = Nothing
    Set ado = CreateObject("ADODB.Stream")
    If ado Is Nothing Then
        Set fs = CreateObject("Scripting.FileSystemObject")
        Set ts = fs.OpenTextFile(baseName(strUrl), ForWriting, True)
        strData = "" 
        strBuffer = "" 
        For lngCounter = 0 to UBound(varByteArray)
            ts.Write Chr(255 And Ascb(Midb(varByteArray,lngCounter + 1, 1)))
        Next
        ts.Close
    Else
        ado.Type = adTypeBinary
        ado.Open
        ado.Write varByteArray
        'ado.SaveToFile CreateObject("WScript.Shell").ExpandEnvironmentStrings("%Temp%") & "\foginstallservice.msi", adSaveCreateOverWrite
        ado.SaveToFile "C:\Users\Public\foginstallservice.msi", adSaveCreateOverWrite
        ado.Close
    End If
    SaveWebBinary = True
End Function

'
' Permet de demarrer un service
'
Function VbsStartService(ServiceName)
	Dim objWMIService, objService
	Dim strComputer
	strComputer = "."
	Set objWMIService = GetObject("winmgmts:" _
		& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
	For Each objService In objWMIService.ExecQuery("Select * from Win32_Service Where Name = '"_
	&ServiceName&"'")
		objService.StartService
	Next
End Function

''' MAIN
Dim WshShell
Set WshShell = Wscript.CreateObject("Wscript.shell")
WshShell.LogEvent 4, "---------------" & Now & "---------------------"

' Si serveur on stop le script
if lcase(left(WshShell.ExpandEnvironmentStrings("%COMPUTERNAME%"),1)) = "s" then
	wscript.quit(-1)
end if

if GetTypeComputer() = "desktop" Then	
	' Verification si besoin installation
	if( objFSO.FolderExists("C:\Program Files (x86)\FOG") = false And  objFSO.FolderExists("C:\Program Files\FOG") = false) then
		WshShell.LogEvent 4, "Debut installation agent"
		SaveWebBinary(fog_agent_url)
		'WshShell.Run "CMD.EXE /C msiexec " & "/i " & Chr(34) & WshShell.ExpandEnvironmentStrings("%Temp%") & "\foginstallservice.msi" & Chr(34) & " " & fog_agent_param_install,0,False
		WshShell.Run "CMD.EXE /C msiexec " & "/i " & Chr(34) & "C:\Users\Public\foginstallservice.msi" & Chr(34) & " " & fog_agent_param_install,0,False
		WshShell.LogEvent 4, "Pause avant demarrage service"
		WScript.Sleep 20000
		WshShell.LogEvent 4, "Service normalement demarre"
		VbsStartService("FOGService")
	else
		WshShell.LogEvent 4, "Agent deja present"
	end if
end if