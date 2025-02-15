Class extends OpenAIResult

Function get choices : Collection
	var $body:=This:C1470.objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.choices)=Is collection:K8:32)))
		return []
	End if 
	
	return $body.choices.map(Formula:C1597(cs:C1710.OpenAIChoice.new($1.value)))
	
Function get choice : cs:C1710.OpenAIChoice
	var $body:=This:C1470.objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.choices)=Is collection:K8:32)))
		return Null:C1517
	End if 
	If ($body.choices.length=0)
		return Null:C1517
	End if 
	
	return cs:C1710.OpenAIChoice.new($body.choices.first())