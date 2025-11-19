// Result class for delete assistant operation
Class extends OpenAIResult

/*
* Returns the deleted assistant status from the API response
* @return {cs.OpenAIAssistantDeleted} The deletion status object, or Null if invalid response
*/
Function get deleted : cs:C1710.OpenAIAssistantDeleted
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.id)=Is text:K8:3)))
		return Null:C1517
	End if

	var $deleted:=Try(cs:C1710.OpenAIAssistantDeleted.new($body))
	If ($deleted=Null:C1517)
		var $errors:=Last errors:C1799
		If (($errors#Null:C1517) && (This:C1470.errors=Null:C1517))
			This:C1470._errors:=$errors  //decoding error
		End if
	End if

	return $deleted

