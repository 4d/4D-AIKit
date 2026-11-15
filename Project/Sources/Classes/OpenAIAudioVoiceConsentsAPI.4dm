// API resource for the consent recordings of custom voices
// A consent recording authorizes the creation of a voice from an audio sample
// https://developers.openai.com/api/reference/resources/audio/subresources/voice_consents

Class extends OpenAIAPIResource

Class constructor($client : cs.OpenAI)
	Super($client)
	
/*
* Upload a consent recording.
*
* @param $name {Text} The label of the consent recording (required)
* @param $language {Text} The BCP 47 language tag of the consent phrase, ie. en-US (required)
* @param $recording {4D.File|4D.Blob} The audio of the consent phrase (required)
* @param $parameters {cs.OpenAIParameters} Optional parameters. `filename` gives the file name of a blob.
* @return {cs.OpenAIAudioVoiceConsentResult} Result containing the consent recording
* @throws Error if name or language is empty, or if recording is not 4D.File or 4D.Blob
*/
Function create($name : Text; $language : Text; $recording : Variant; $parameters : cs.OpenAIParameters) : cs.OpenAIAudioVoiceConsentResult
	If (Length($name)=0)
		throw(1; "Expected a non-empty value for `name`")
	End if 
	
	If (Length($language)=0)
		throw(1; "Expected a non-empty value for `language`")
	End if 
	
	If (Not(OB Instance of($parameters; cs.OpenAIParameters)))
		$parameters:=cs.OpenAIParameters.new($parameters)
	End if 
	
	var $part:=This._client.audio._filePart($recording; String($parameters["filename"]))
	If ($part=Null)
		throw(1; "Expected a non-empty value for `recording` (must be 4D.File or 4D.Blob/Blob)")
	End if 
	
	return This._client._postFiles("/audio/voice_consents"; {name: $name; language: $language}; {recording: $part}; $parameters; cs.OpenAIAudioVoiceConsentResult)
	
/*
* Returns the consent recordings of the organization.
*
* @param $parameters {cs.OpenAIAudioVoiceConsentListParameters} Optional parameters for pagination
* @return {cs.OpenAIAudioVoiceConsentListResult} Result containing a collection of consent recordings
*/
Function list($parameters : cs.OpenAIAudioVoiceConsentListParameters) : cs.OpenAIAudioVoiceConsentListResult
	If (Not(OB Instance of($parameters; cs.OpenAIAudioVoiceConsentListParameters)))
		$parameters:=cs.OpenAIAudioVoiceConsentListParameters.new($parameters)
	End if 
	
	return This._client._getApiList("/audio/voice_consents"; $parameters.body(); $parameters; cs.OpenAIAudioVoiceConsentListResult)
	
/*
* Returns a consent recording.
*
* @param $consentId {Text} The ID of the consent recording (required)
* @param $parameters {cs.OpenAIParameters} Optional parameters for the request
* @return {cs.OpenAIAudioVoiceConsentResult} Result containing the consent recording
* @throws Error if consentId is empty
*/
Function retrieve($consentId : Text; $parameters : cs.OpenAIParameters) : cs.OpenAIAudioVoiceConsentResult
	If (Length($consentId)=0)
		throw(1; "Expected a non-empty value for `consentId`")
	End if 
	
	return This._client._get("/audio/voice_consents/"+$consentId; $parameters; cs.OpenAIAudioVoiceConsentResult)
	
/*
* Rename a consent recording. The recording itself could not be changed.
*
* @param $consentId {Text} The ID of the consent recording (required)
* @param $name {Text} The new label (required)
* @param $parameters {cs.OpenAIParameters} Optional parameters for the request
* @return {cs.OpenAIAudioVoiceConsentResult} Result containing the updated consent recording
* @throws Error if consentId or name is empty
*/
Function update($consentId : Text; $name : Text; $parameters : cs.OpenAIParameters) : cs.OpenAIAudioVoiceConsentResult
	If (Length($consentId)=0)
		throw(1; "Expected a non-empty value for `consentId`")
	End if 
	
	If (Length($name)=0)
		throw(1; "Expected a non-empty value for `name`")
	End if 
	
	return This._client._post("/audio/voice_consents/"+$consentId; {name: $name}; $parameters; cs.OpenAIAudioVoiceConsentResult)
	
/*
* Delete a consent recording.
*
* @param $consentId {Text} The ID of the consent recording (required)
* @param $parameters {cs.OpenAIParameters} Optional parameters for the request
* @return {cs.OpenAIAudioVoiceDeletedResult} Result containing the deletion status
* @throws Error if consentId is empty
*/
Function delete($consentId : Text; $parameters : cs.OpenAIParameters) : cs.OpenAIAudioVoiceDeletedResult
	If (Length($consentId)=0)
		throw(1; "Expected a non-empty value for `consentId`")
	End if 
	
	return This._client._delete("/audio/voice_consents/"+$consentId; $parameters; cs.OpenAIAudioVoiceDeletedResult)
