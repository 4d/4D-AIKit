// Result class for the deletion of a voice or of a voice consent
Class extends OpenAIResult

/*
* Returns the deletion status from the API response
* @return {cs.OpenAIAudioVoiceDeleted} The deletion status, or Null if invalid response
*/
Function get deleted : cs.OpenAIAudioVoiceDeleted
	var $body:=This._objectBody()
	If (($body=Null) || ($body.error#Null) || (Not(This.success)))
		return Null
	End if 
	
	return cs.OpenAIAudioVoiceDeleted.new($body)
