//%attributes = {"invisible":true,"executedOnServer":true}
#DECLARE() : Object

var $file : 4D:C1709.File
var $userData:=Folder:C1567(fk data folder:K87:12; *).file("Settings/AIProviders.json")
If ($userData.exist)
	return JSON Parse:C1218($userData.getText())
End if 

var $user:=Folder:C1567(fk database folder:K87:14; *).file("Settings/AIProviders.json")
If ($user.exist)
	return JSON Parse:C1218($user.getText())
End if 

var $structure:=Folder:C1567("/SOURCES"; *).file("AIProviders.json")  // TODO: check work with 4DZ, else use zip
If ($structure.exist)
	return JSON Parse:C1218($structure.getText())
End if 

return {}