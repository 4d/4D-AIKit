// Result class for single assistant operations (create, retrieve, or modify)
Class extends OpenAIResult

/*
* Returns the assistant object from the API response
* @return {cs.OpenAIAssistant} The assistant object, or Null if invalid response
*/
Function get assistant : cs:C1710.OpenAIAssistant
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.id)=Is text:K8:3)))
		return Null:C1517
	End if

	var $assistant:=Try(cs:C1710.OpenAIAssistant.new($body))
	If ($assistant=Null:C1517)
		var $errors:=Last errors:C1799
		If (($errors#Null:C1517) && (This:C1470.errors=Null:C1517))
			This:C1470._errors:=$errors  //decoding error
		End if
	End if

	return $assistant

