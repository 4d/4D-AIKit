//%attributes = {}
var $client:=cs:C1710.OpenAI.new()


If (Folder:C1567(fk desktop folder:K87:19).file("apiKey").exists)  // Just to test, do not do that
	$client.apiKey:=Folder:C1567(fk desktop folder:K87:19).file("apiKey").getText()
End if 
var $class : Text
For each ($class; cs:C1710)
	If ($class="DataStore")
		return 
	End if 
	
	var $code:=Folder:C1567(fk database folder:K87:14).file("Project/Sources/Classes/"+$class+".4dm").getText()
	
	var $messages:=[{role: "system"; content: "You are a helpful assistant. You will generate markdown description of a 4D class. Starting with class name as main title. Provide functions description with arguments in tables if any. Some example using 4d code block. Remove :C1710 from code. Ret"+"urn only the markdown for the provi"+"ded code by u"+"ser"}]
	$messages.push({role: "user"; content: "Class Name="+$class+"\n"+$code})
	var $chatResult:=$client.chat.completions.create($messages)
	
	Folder:C1567(fk database folder:K87:14).file("Documentation/Classes/"+$class+".md").setText($chatResult.choice.message.text)
	
End for each 