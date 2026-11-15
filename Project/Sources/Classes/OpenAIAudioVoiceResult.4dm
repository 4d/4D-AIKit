// Result class for a voice creation
Class extends OpenAIResult

/*
* Returns the voice from the API response
* @return {cs.OpenAIAudioVoice} The voice, or Null if invalid response
*/
Function get voice : cs.OpenAIAudioVoice
	var $body:=This._objectBody()
	If (($body=Null) || ($body.error#Null) || (Not(This.success)))
		return Null
	End if 
	
	var $voice:=cs.OpenAIAudioVoice.new($body)
	If (Length(String($voice.id))=0)
		return Null
	End if 
	return $voice
