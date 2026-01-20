Class extends OpenAIResult

Function get model : cs:C1710.OpenAIModel
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if 
	If (Value type:C1509($body.data)=Is object:K8:27)
		$body:=$body.data
	End if 
	If (Not:C34(Value type:C1509($body.id)=Is text:K8:3))
		return Null:C1517
	End if 
	return cs:C1710.OpenAIModel.new($body)