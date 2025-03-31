If (Shift down:C543)
	
	var $doc:=Select document:C905(Folder:C1567(fk desktop folder:K87:19).platformPath; ".json"; "Select a json schema"; Allow alias files:K24:10)
	If (OK=1)
		
		Form:C1466.jsonSchema:=Try(JSON Parse:C1218(File:C1566(Document; fk platform path:K87:2).getText()))
		
	End if 
	
End if 