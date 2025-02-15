Class extends OpenAIResult

Function get models : Collection
	var $body:=This:C1470.objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.data)=Is collection:K8:32)))
		return []
	End if 
	
	return $body.data.map(Formula:C1597(cs:C1710.OpenAIModel.new($1.value)))