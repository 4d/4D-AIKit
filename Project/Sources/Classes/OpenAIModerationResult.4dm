Class extends OpenAIResult

Function get moderation : cs:C1710.OpenAIModeration
	If (Not:C34(Value type:C1509(This:C1470.request.response.body.id)=Is text:K8:3))
		return Null:C1517
	End if 
	
	return cs:C1710.OpenAIModeration.new(This:C1470.request.response.body)