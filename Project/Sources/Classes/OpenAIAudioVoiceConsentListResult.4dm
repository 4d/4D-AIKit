// Result class for listing voice consents
Class extends OpenAIResult

/*
* Returns the consent recordings from the API response
* @return {Collection} Collection of cs.OpenAIAudioVoiceConsent objects, or empty collection if none found
*/
Function get consents : Collection
	var $body:=This._objectBody()
	If (($body=Null) || (Not(Value type($body.data)=Is collection)))
		return []
	End if 
	
	return $body.data.map(Formula(cs.OpenAIAudioVoiceConsent.new($1.value)))
	
/*
* Returns the ID of the first consent recording in the list
* @return {Text} The first ID, or empty string if not available
*/
Function get first_id : Text
	var $body:=This._objectBody()
	return ($body=Null) ? "" : String($body.first_id)
	
/*
* Returns the ID of the last consent recording in the list, to use as `after`
* @return {Text} The last ID, or empty string if not available
*/
Function get last_id : Text
	var $body:=This._objectBody()
	return ($body=Null) ? "" : String($body.last_id)
	
/*
* Indicates if there are more consent recordings beyond this page
* @return {Boolean} True if there are more to fetch
*/
Function get has_more : Boolean
	var $body:=This._objectBody()
	return ($body=Null) ? False : Bool($body.has_more)
