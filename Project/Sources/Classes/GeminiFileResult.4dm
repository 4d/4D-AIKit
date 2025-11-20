Class extends GeminiResult

Function get file : cs:C1710.GeminiFile
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if

	return cs:C1710.GeminiFile.new($body)

