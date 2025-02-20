//%attributes = {}
var $client:=cs:C1710.OpenAI.new()

If ((Folder:C1567(fk desktop folder:K87:19).file("apiKey").exists) && ($client.apiKey#Null:C1517))
	$client.apiKey:=Folder:C1567(fk desktop folder:K87:19).file("apiKey").getText()
End if 

var $databaseFolder:=Folder:C1567(fk home folder:K87:24).folder("git/packageManager")

var $systemPrompt:="You are a helpful assistant. You will generate markdown description of a 4D class."
$systemPrompt+="Starting with class name as main title."
$systemPrompt+="Provide functions description with arguments in tables if any."
$systemPrompt+="Some example using 4d code block. Using modern var syntax no C_."
$systemPrompt+=" In code no :C1710 or :C<number>."
$systemPrompt+="Return only the markdown for the provided code by user"
$systemPrompt+="No need to document constructor if only one object is passed"

var $classFile : 4D:C1709.File
For each ($classFile; $databaseFolder.folder("Project/Sources/Classes/").files().filter(Formula:C1597($1.value.extension=".4dm")))
	
	var $class:=$classFile.name
	var $docFile:=$databaseFolder.file("Documentation/Classes/"+$class+".md")
	
	If ($docFile.exists)
		continue  // we skip
	End if 
	
	var $code:=$classFile.getText()
	
	var $messages:=[{role: "system"; content: $systemPrompt}; {role: "user"; content: "Class Name="+$class+"\n"+$code}]
	
	var $chatResult:=$client.chat.completions.create($messages)
	
	If ($chatResult.success)
		$docFile.setText($chatResult.choice.message.text)
	End if 
	
End for each 