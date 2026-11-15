// API resource for the text-to-speech voices: create, delete and list
// https://developers.openai.com/api/reference/resources/audio/subresources/voices

// The custom voices known by this client. OpenAI has no endpoint to list them: see add(), save() and load().
property custom : Collection:=[]

Class extends OpenAIAPIResource

Class constructor($client : cs.OpenAI)
	Super($client)
	
	// MARK:- endpoints
	
/*
* Create a custom voice, from an audio sample with its consent recording, or from a prompt.
* If success, and not asynchronous, the voice is added to the custom voices of the client.
*
* @param $name {Text} The name of the voice (required)
* @param $parameters {cs.OpenAIAudioVoiceParameters} `audio_sample` and `consent`, or `prompt` (required)
* @return {cs.OpenAIAudioVoiceResult} Result containing the voice
* @throws Error if name is empty, or without valid audio_sample or prompt
*/
Function create($name : Text; $parameters : cs.OpenAIAudioVoiceParameters) : cs.OpenAIAudioVoiceResult
	If (Length($name)=0)
		throw(1; "Expected a non-empty value for `name`")
	End if 
	
	If (Not(OB Instance of($parameters; cs.OpenAIAudioVoiceParameters)))
		$parameters:=cs.OpenAIAudioVoiceParameters.new($parameters)
	End if 
	
	var $body:=$parameters.body()
	$body.name:=$name
	
	var $result : cs.OpenAIAudioVoiceResult
	If ($parameters.audio_sample#Null)
		
		var $part:=This._client.audio._filePart($parameters.audio_sample; String($parameters.filename))
		If ($part=Null)
			throw(1; "Expected a 4D.File or a 4D.Blob/Blob for `audio_sample`")
		End if 
		
		$result:=This._client._postFiles("/audio/voices"; $body; {audio_sample: $part}; $parameters; cs.OpenAIAudioVoiceResult)
		
	Else 
		
		If (Length(String($parameters.prompt))=0)
			throw(1; "Expected an `audio_sample` or a `prompt`")
		End if 
		
		If ($body.type=Null)
			$body.type:="prompt"
		End if 
		
		$result:=This._client._post("/audio/voices"; $body; $parameters; cs.OpenAIAudioVoiceResult)
		
	End if 
	
	If ((Not($parameters._isAsync())) && ($result.voice#Null))
		This.add($result.voice)
	End if 
	
	return $result
	
/*
* Delete a custom voice.
* If success, and not asynchronous, the voice is removed from the custom voices of the client.
*
* @param $voiceId {Text} The ID of the voice to delete (required)
* @param $parameters {cs.OpenAIParameters} Optional parameters for the request
* @return {cs.OpenAIAudioVoiceDeletedResult} Result containing the deletion status
* @throws Error if voiceId is empty
*/
Function delete($voiceId : Text; $parameters : cs.OpenAIParameters) : cs.OpenAIAudioVoiceDeletedResult
	If (Length($voiceId)=0)
		throw(1; "Expected a non-empty value for `voiceId`")
	End if 
	
	If (Not(OB Instance of($parameters; cs.OpenAIParameters)))
		$parameters:=cs.OpenAIParameters.new($parameters)
	End if 
	
	var $result : cs.OpenAIAudioVoiceDeletedResult:=This._client._delete("/audio/voices/"+$voiceId; $parameters; cs.OpenAIAudioVoiceDeletedResult)
	
	If ((Not($parameters._isAsync())) && ($result.success))
		This.remove($voiceId)
	End if 
	
	return $result
	
/*
* List the voices to use with speech().
*
* A server like OpenAI has no endpoint for that: the result is then its well-known voices,
* followed by the custom voices of the client, without any request.
* Otherwise the server is requested, and its response decoded whatever its format.
*
* @param $parameters {cs.OpenAIAudioVoiceListParameters} Optional parameters: path, model, query, custom
* @return {cs.OpenAIAudioVoiceListResult} Result containing a collection of voices
*/
Function list($parameters : cs.OpenAIAudioVoiceListParameters) : cs.OpenAIAudioVoiceListResult
	If (Not(OB Instance of($parameters; cs.OpenAIAudioVoiceListParameters)))
		$parameters:=cs.OpenAIAudioVoiceListParameters.new($parameters)
	End if 
	
	var $baseURL : Text:=String(This._client.baseURL)
	var $path : Text:=String($parameters.path)
	var $result : cs.OpenAIAudioVoiceListResult
	
	// MARK: well-known voices, no request
	If (Length($path)=0)
		var $voices:=This._wellKnown($baseURL; String($parameters.model))
		If ($voices#Null)
			
			If ($parameters.custom)
				$voices:=$voices.concat(This.custom)
			End if 
			
			$result:=cs.OpenAIAudioVoiceListResult.new()
			$result._voices:=$voices
			$result._terminated:=True
			_openAICallbacks($parameters; $result)
			return $result
			
		End if 
	End if 
	
	// MARK: request the server
	var $query:=$parameters.body()
	var $guess:=(Length($path)=0)
	
	If ($guess)
		$path:=This._listPath($baseURL)
		
		If (Position("api.elevenlabs.io"; $baseURL)>0)
			// not a bearer token
			$parameters.extraHeaders:=$parameters.extraHeaders || {}
			If ($parameters.extraHeaders["xi-api-key"]=Null)
				$parameters.extraHeaders["xi-api-key"]:=This._client.apiKey
			End if 
		End if 
		
		If ((Length(String($parameters.model))>0) && ($query.model=Null) && ($path="/audio/voices"))
			$query.model:=$parameters.model
		End if 
	End if 
	
	If ($guess && ($path="/audio/voices") && (Not($parameters._isAsync())))
		
		// some servers list their voices one level up: try it if not found
		var $throw:=Bool($parameters.throw)
		$parameters.throw:=False
		$result:=This._client._getApiList($path; $query; $parameters; cs.OpenAIAudioVoiceListResult)
		$parameters.throw:=$throw
		
		var $status : Integer:=($result.request.response=Null) ? 0 : Num($result.request.response.status)
		Case of 
			: (($status=404) || ($status=405))
				OB REMOVE($query; "model")
				var $fallback : cs.OpenAIAudioVoiceListResult:=This._client._getApiList("/voices"; $query; $parameters; cs.OpenAIAudioVoiceListResult)
				If ($fallback.success || $throw)
					return $fallback
				End if 
			: ($throw)
				$result.throw()
		End case 
		
		return $result
		
	End if 
	
	return This._client._getApiList($path; $query; $parameters; cs.OpenAIAudioVoiceListResult)
	
	// MARK:- custom voices
	
/*
* Add a voice to the custom voices of the client, to get it with list().
* A voice with the same id is replaced.
*
* @param $voice {Text|Object} The ID of the voice, or the voice ie. the one returned by create()
* @return {cs.OpenAIAudioVoice} The voice added, or Null without id
*/
Function add($voice : Variant) : cs.OpenAIAudioVoice
	var $added:=cs.OpenAIAudioVoice.new($voice)
	If (Length(String($added.id))=0)
		return Null
	End if 
	
	$added.custom:=True
	This.remove($added.id)
	This.custom.push($added)
	return $added
	
/*
* Remove a voice from the custom voices of the client. The voice is not deleted on the server, see delete().
*
* @param $voiceId {Text} The ID of the voice
* @return {Boolean} True if the voice was found
*/
Function remove($voiceId : Text) : Boolean
	var $count:=This.custom.length
	This.custom:=This.custom.filter(Formula(String($1.value.id)#$2); $voiceId)
	return This.custom.length<$count
	
/*
* Save the custom voices of the client into a JSON file, to load them later with load().
*
* @param $file {4D.File} The file to write
* @return {Boolean} True if saved
*/
Function save($file : 4D.File) : Boolean
	If (Not(OB Instance of($file; 4D.File)))
		throw(1; "Expected a 4D.File for `file`")
	End if 
	
	Try
		$file.setText(JSON Stringify({voices: This.custom}; *))
		return True
	Catch
		return False
	End try
	
/*
* Add the custom voices saved into a JSON file with save().
*
* @param $file {4D.File} The file to read
* @return {Boolean} True if loaded
*/
Function load($file : 4D.File) : Boolean
	If (Not(OB Instance of($file; 4D.File)))
		throw(1; "Expected a 4D.File for `file`")
	End if 
	
	If (Not($file.exists))
		return False
	End if 
	
	var $content : Variant:=Try(JSON Parse($file.getText()))
	Case of 
		: (Value type($content)=Is collection)
			// a simple list of voices or of IDs
		: ((Value type($content)=Is object) && (Value type($content.voices)=Is collection))
			$content:=$content.voices
		Else 
			return False
	End case 
	
	var $voice : Variant
	For each ($voice; $content)
		This.add($voice)
	End for each 
	return True
	
	// MARK:- utils
	
	// The voices of a server without endpoint to list them, Null if the server must be requested.
Function _wellKnown($baseURL : Text; $model : Text) : Collection
	var $names : Collection
	var $voiceModel : Text:=""
	
	Case of 
		: ((Position("api.openai.com"; $baseURL)>0) || (Position(".openai.azure.com"; $baseURL)>0))
			
			If (($model="tts-1") || ($model="tts-1-hd"))
				$names:=["alloy"; "ash"; "coral"; "echo"; "fable"; "nova"; "onyx"; "sage"; "shimmer"]
			Else 
				$names:=["alloy"; "ash"; "ballad"; "cedar"; "coral"; "echo"; "fable"; "marin"; "nova"; "onyx"; "sage"; "shimmer"; "verse"]
			End if 
			
		: (Position("api.groq.com"; $baseURL)>0)
			
			$voiceModel:="canopylabs/orpheus-v1-english"
			If ((Length($model)>0) && ($model#$voiceModel))
				return []  // not known
			End if 
			$names:=["autumn"; "diana"; "hannah"; "austin"; "daniel"; "troy"]
			
		Else 
			return Null
	End case 
	
	var $voices:=[]
	var $name : Text
	For each ($name; $names)
		var $voice:=cs.OpenAIAudioVoice.new({id: $name; name: Uppercase(Substring($name; 1; 1))+Substring($name; 2); type: "builtin"})
		If (Length($voiceModel)>0)
			$voice.model:=$voiceModel
		End if 
		$voices.push($voice)
	End for each 
	return $voices
	
	// The path of the endpoint which lists the voices
Function _listPath($baseURL : Text) : Text
	Case of 
		: (Position("api.x.ai"; $baseURL)>0)
			return "/tts/voices"
		: ((Position("api.together."; $baseURL)>0) || (Position("api.elevenlabs.io"; $baseURL)>0) || (Position("api.speechify.ai"; $baseURL)>0))
			return "/voices"
	End case 
	
	return "/audio/voices"  // Mistral and most of the local servers
