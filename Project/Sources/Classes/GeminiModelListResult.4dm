Class extends GeminiResult

Function get models : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.models)=Is collection:K8:32)))
		return []
	End if

	return $body.models.map(Formula:C1597(cs:C1710.GeminiModel.new($1.value)))

