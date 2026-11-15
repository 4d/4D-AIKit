// Result class for a single voice consent (create, retrieve or update)
Class extends OpenAIResult

/*
* Returns the consent recording from the API response
* @return {cs.OpenAIAudioVoiceConsent} The consent recording, or Null if invalid response
*/
Function get consent : cs.OpenAIAudioVoiceConsent
	var $body:=This._objectBody()
	If (($body=Null) || (Not(Value type($body.id)=Is text)) || (Not(This.success)))
		return Null
	End if 
	
	return cs.OpenAIAudioVoiceConsent.new($body)
