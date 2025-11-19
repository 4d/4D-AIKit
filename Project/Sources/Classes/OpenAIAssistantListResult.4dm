// Result class for list assistants operation
Class extends OpenAIResult

/*
* Returns the collection of assistant objects from the API response
* @return {Collection} Collection of cs.OpenAIAssistant objects, or empty collection if invalid response
*/
Function get assistants : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.data)=Is collection:K8:32)))
		return []
	End if

	return $body.data.map(Formula:C1597(cs:C1710.OpenAIAssistant.new($1.value)))

/*
* Returns the first assistant ID in the list (for pagination)
* @return {Text} The first assistant ID, or empty string if no assistants
*/
Function get firstId : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if
	return String:C10($body.first_id)

/*
* Returns the last assistant ID in the list (for pagination)
* @return {Text} The last assistant ID, or empty string if no assistants
*/
Function get lastId : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if
	return String:C10($body.last_id)

/*
* Indicates whether there are more results available
* @return {Boolean} True if there are more results to fetch
*/
Function get hasMore : Boolean
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return False:C215
	End if
	return Bool:C1537($body.has_more)

