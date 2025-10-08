// Result class for Upload operations (create, complete, or cancel)
Class extends OpenAIResult

/*
* Returns the upload object from the API response
* @return {cs.OpenAIUpload} The upload object, or Null if invalid response
*/
Function get upload : cs:C1710.OpenAIUpload
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.id)=Is text:K8:3)))
		return Null:C1517
	End if 
	
	var $upload:=Try(cs:C1710.OpenAIUpload.new($body))
	If ($upload=Null:C1517)
		var $errors:=Last errors:C1799
		If (($errors#Null:C1517) && (This:C1470.errors=Null:C1517))
			This:C1470._errors:=$errors  // decoding error
		End if 
	End if 
	
	return $upload
