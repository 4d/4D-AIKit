Class extends OpenAIResult

Function get file : cs:C1710.OpenAIFile
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.id)=Is text:K8:3)))
		return Null:C1517
	End if 
	
	return cs:C1710.OpenAIFile.new($body)
