Class extends GeminiResult

Function get files : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.files)=Is collection:K8:32)))
		return []
	End if

	return $body.files.map(Formula:C1597(cs:C1710.GeminiFile.new($1.value)))

Function get nextPageToken : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if
	return String:C10($body.nextPageToken)

