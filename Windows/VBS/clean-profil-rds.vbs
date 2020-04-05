'#
'#	@author: Romain Drouche
'#	@website : https://rdr-it.com
'#	@validation : W2012/W2012R2/W2016 sans UPD
'#
On Error Resume Next

' Declaration
Const DeleteReadOnly = TRUE
Dim oFSO, userFolder, subFolders, oShell

' Vars
userFolder = "C:\users"

' Declaration des Objets
Set oFSO = CreateObject("Scripting.FileSystemObject")
Set oShell = CreateObject("WScript.Shell")


subFolders = oFSO.GetFolder(userFolder)

For Each f1 in oFSO.GetFolder(userFolder).SubFolders
	'msgbox (f1.name)
	dir_chrome_cache = userFolder & "\" & f1.name & "\AppData\Local\Google\Chrome\User Data\Default\Cache"
	dir_chrome_app_cache = userFolder & "\" & f1.name & "\AppData\Local\Google\Chrome\User Data\Default\Application Cache\Cache"
	dir_chrome_media_cache = userFolder & "\" & f1.name & "\AppData\Local\Google\Chrome\User Data\Default\Media Cache"
	
	' Nettoyage Cache after W8 (IE)
	If(oFSO.FolderExists(userFolder & "\" & f1.name & "\AppData\Local\Microsoft\Windows\INetCache\IE" )) then
		DeleteAllSubFolder(userFolder & "\" & f1.name & "\AppData\Local\Microsoft\Windows\INetCache\IE")
	End If
	
	' Nettoyage Google
	If(oFSO.FolderExists(dir_chrome_cache)) then
		CleanDir(dir_chrome_cache)
	End If
	
	If(oFSO.FolderExists(dir_chrome_app_cache)) then
		CleanDir(dir_chrome_app_cache)
	End If
	
	If(oFSO.FolderExists(dir_chrome_media_cache)) then
		CleanDir(dir_chrome_media_cache)
	End If
	
Next

' Nettoyage temp Windows
oShell.run "cmd /c DEL C:\Windows\Temp\*.* /S /Q"

'msgbox ("Nettoyage termine")


Sub DeleteAllSubFolder(folder)
	On Error Resume Next
	For Each fc in oFSO.GetFolder(folder).SubFolders
		oFSO.DeleteFolder(folder & "\" & fc.name)
	Next
End Sub

Sub CleanDir(folder)
	On Error Resume Next
	oFSO.DeleteFile(folder & "\*"), DeleteReadOnly
	oFSO.DeleteFolder(folder & "\*"), DeleteReadOnly
End Sub