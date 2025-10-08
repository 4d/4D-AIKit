// Result class for Upload Part operations (add part)
Class extends OpenAIResult

/*
* Returns the upload part object from the API response
* @return {cs.OpenAIUploadPart} The upload part object, or Null if invalid response
*/
Function get part : cs:C1710.OpenAIUploadPart
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.id)=Is text:K8:3)))
		return Null:C1517
	End if 
	
	var $part:=Try(cs:C1710.OpenAIUploadPart.new($body))
	If ($part=Null:C1517)
		var $errors:=Last errors:C1799
		If (($errors#Null:C1517) && (This:C1470.errors=Null:C1517))
			This:C1470._errors:=$errors  // decoding error
		End if 
	End if 
	
	return $part
