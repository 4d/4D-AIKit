Class extends OpenAIResult

Function get models : Collection
	If (Not:C34(Value type:C1509(This:C1470.request.response.body.data)=Is collection:K8:32))
		return []
	End if 
	
	return This:C1470.request.response.body.data.map(Formula:C1597(cs:C1710.Model.new($1.value)))