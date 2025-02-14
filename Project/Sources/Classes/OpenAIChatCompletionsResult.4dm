Class extends OpenAIResult

Function get choices : Collection
	If (Not:C34(Value type:C1509(This:C1470.request.response.body.choices)=Is collection:K8:32))
		return []
	End if 
	
	return This:C1470.request.response.body.choices.map(Formula:C1597(cs:C1710.ChatCompletion.new($1.value)))