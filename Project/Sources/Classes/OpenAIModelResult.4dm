Class extends OpenAIResult

Function get model : cs:C1710.Model
	If (Not:C34(Value type:C1509(This:C1470.request.response.body.id)=Is text:K8:3))
		return Null:C1517
	End if 
	
	return cs:C1710.Model.new(This:C1470.request.response.body)