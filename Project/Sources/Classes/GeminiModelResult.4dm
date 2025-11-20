Class extends GeminiResult

Function get model : cs:C1710.GeminiModel
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if

	return cs:C1710.GeminiModel.new($body)

