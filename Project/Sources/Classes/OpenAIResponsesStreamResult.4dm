Class extends OpenAIResult

Function get events : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.events)=Is collection:K8:32)))
		return []
	End if 
	
	return $body.events.map(Formula:C1597(cs:C1710.OpenAIResponseStreamEvent.new($1.value)))

Function get response : cs:C1710.OpenAIResponse
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if 
	
	// For streaming, we need to reconstruct the response from events
	If (Value type:C1509($body.response)=Is object:K8:27)
		return cs:C1710.OpenAIResponse.new($body.response)
	End if 
	
	return Null:C1517
