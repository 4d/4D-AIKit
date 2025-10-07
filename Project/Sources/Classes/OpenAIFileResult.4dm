// Result class for single file operations (upload or retrieve)
Class extends OpenAIResult

/*
* Returns the file object from the API response
* @return {cs.OpenAIFile} The file object, or Null if invalid response
*/
Function get file : cs:C1710.OpenAIFile
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.id)=Is text:K8:3)))
		return Null:C1517
	End if 
	
	var $file:=Try(cs:C1710.OpenAIFile.new($body))
	If ($file=Null:C1517)
		var $errors:=Last errors:C1799
		If (($errors#Null:C1517) && (This:C1470.errors=Null:C1517))
			This:C1470._errors:=$errors  //decoding error
		End if 
	End if 
	
	return $file
	