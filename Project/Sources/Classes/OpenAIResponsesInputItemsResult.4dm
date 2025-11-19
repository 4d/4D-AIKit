Class extends OpenAIResult

/*
* Returns the input items from the API response.
* @return Collection of raw input item objects, or an empty collection if none are found
*/
Function get items : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.data)=Is collection:K8:32)))
		return []
	End if 
	return $body.data

Function get first_id : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if 
	return String:C10($body.first_id)

Function get last_id : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if 
	return String:C10($body.last_id)

Function get has_more : Boolean
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return False:C215
	End if 
	return Bool:C1537($body.has_more)
