Class extends OpenAIResult

Function get files : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.data)=Is collection:K8:32)))
		return New collection:C1472()
	End if 
	
	var $files:=New collection:C1472()
	var $file : Object
	For each ($file; $body.data)
		$files.push(cs:C1710.OpenAIFile.new($file))
	End for each 
	
	return $files
