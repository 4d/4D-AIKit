// API resource for OpenAI Audio endpoints
// Supports text-to-speech, speech-to-text (transcription), and audio translation

Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
/*
* Generate audio from input text (text-to-speech).
*
* @param $input {Text} The text to generate audio for (required, max 4096 characters)
* @param $model {Text} The TTS model to use: tts-1, tts-1-hd, or gpt-4o-mini-tts (required)
* @param $voice {Text} The voice to use: alloy, ash, ballad, coral, echo, fable, onyx, nova, sage, shimmer, verse (required)
* @param $parameters {cs.OpenAIAudioSpeechParameters} Optional parameters including response_format, speed, instructions
* @return {cs.OpenAIAudioSpeechResult} Result containing the generated audio
* @throws Error if input is empty, exceeds 4096 chars, or voice/model is invalid
*/
Function speech($input : Text; $model : Text; $voice : Text; $parameters : cs:C1710.OpenAIAudioSpeechParameters) : cs:C1710.OpenAIAudioSpeechResult
	
	// Validate input text
	If (Length:C16($input)=0)
		throw:C1805(1; "Expected a non-empty value for `input`")
	End if 
	
	If (Length:C16($input)>4096)
		throw:C1805(1; "Input text must not exceed 4096 characters")
	End if 
	
	// Validate model
	If (Length:C16($model)=0)
		throw:C1805(1; "Expected a non-empty value for `model`")
	End if 
	
	// Validate voice
	If (Length:C16($voice)=0)
		throw:C1805(1; "Expected a non-empty value for `voice`")
	End if 
	
/*var $validVoices : Collection:=["alloy"; "ash"; "ballad"; "coral"; "echo"; "fable"; "onyx"; "nova"; "sage"; "shimmer"; "verse"]
If ($validVoices.indexOf($voice)=-1)
throw(1; "Invalid voice. Must be one of: "+$validVoices.join(", "))
End if */
	
	// Ensure parameters is correct type
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIAudioSpeechParameters)))
		$parameters:=cs:C1710.OpenAIAudioSpeechParameters.new($parameters)
	End if 
	
	// Build request body
	var $body : Object
	$body:=$parameters.body()
	$body.input:=$input
	$body.model:=$model
	$body.voice:=$voice
	
	// Make API request
	return This:C1470._client._post("/audio/speech"; $body; $parameters; cs:C1710.OpenAIAudioSpeechResult)
	
/*
* Transcribe audio into the input language (speech-to-text).
*
* @param $file {4D.File|4D.Blob} The audio file to transcribe (required)
* @param $model {Text} The transcription model: gpt-4o-transcribe, gpt-4o-mini-transcribe, whisper-1, gpt-4o-transcribe-diarize (required)
* @param $parameters {cs.OpenAIAudioTranscriptionParameters} Optional parameters including language, response_format, temperature
* @return {cs.OpenAIAudioTranscriptionResult} Result containing the transcription text
* @throws Error if file is not 4D.File or 4D.Blob, or if model is empty
*/
Function transcription($file : Variant; $model : Text; $parameters : cs:C1710.OpenAIAudioTranscriptionParameters) : cs:C1710.OpenAIAudioTranscriptionResult
	
	// Validate file parameter
	var $isFile:=False:C215
	var $isBlob:=False:C215
	
	If ($file#Null:C1517)
		Case of 
			: (Value type:C1509($file)=Is object:K8:27)
				$isFile:=OB Instance of:C1731($file; 4D:C1709.File)
				$isBlob:=OB Instance of:C1731($file; 4D:C1709.Blob)
			: (Value type:C1509($file)=Is BLOB:K8:12)
				$isBlob:=True:C214
		End case 
	End if 
	
	If (Not:C34($isFile) && Not:C34($isBlob))
		throw:C1805(1; "Expected a non-empty value for `file` (must be 4D.File or 4D.Blob/Blob)")
	End if 
	
	// Validate model
	If (Length:C16($model)=0)
		throw:C1805(1; "Expected a non-empty value for `model`")
	End if 
	
	// Ensure parameters is correct type
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIAudioTranscriptionParameters)))
		$parameters:=cs:C1710.OpenAIAudioTranscriptionParameters.new($parameters)
	End if 
	
	// Build request body (non-file fields)
	var $body : Object
	$body:=$parameters.body()
	$body.model:=$model
	
	// Build files object
	var $files : Object
	If (Length:C16(String:C10($parameters.filename))>0)
		$files:={file: {file: $file; filename: $parameters.filename}}
	Else 
		$files:={file: $file}
	End if 
	
	// Use _postFiles for multipart/form-data
	return This:C1470._client._postFiles("/audio/transcriptions"; $body; $files; $parameters; cs:C1710.OpenAIAudioTranscriptionResult)
	
/*
* Translate audio into English (audio translation).
*
* @param $file {4D.File|4D.Blob} The audio file to translate (required)
* @param $model {Text} The translation model: currently only whisper-1 is supported (required)
* @param $parameters {cs.OpenAIAudioTranslationParameters} Optional parameters including prompt, response_format, temperature
* @return {cs.OpenAIAudioTranslationResult} Result containing the English translation
* @throws Error if file is not 4D.File or 4D.Blob, or if model is empty
*/
Function translation($file : Variant; $model : Text; $parameters : cs:C1710.OpenAIAudioTranslationParameters) : cs:C1710.OpenAIAudioTranslationResult
	
	// Validate file parameter
	var $isFile:=False:C215
	var $isBlob:=False:C215
	
	If ($file#Null:C1517)
		Case of 
			: (Value type:C1509($file)=Is object:K8:27)
				$isFile:=OB Instance of:C1731($file; 4D:C1709.File)
				$isBlob:=OB Instance of:C1731($file; 4D:C1709.Blob)
			: (Value type:C1509($file)=Is BLOB:K8:12)
				$isBlob:=True:C214
		End case 
	End if 
	
	If (Not:C34($isFile) && Not:C34($isBlob))
		throw:C1805(1; "Expected a non-empty value for `file` (must be 4D.File or 4D.Blob/Blob)")
	End if 
	
	// Validate model
	If (Length:C16($model)=0)
		throw:C1805(1; "Expected a non-empty value for `model`")
	End if 
	
	// Ensure parameters is correct type
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIAudioTranslationParameters)))
		$parameters:=cs:C1710.OpenAIAudioTranslationParameters.new($parameters)
	End if 
	
	// Build request body (non-file fields)
	var $body : Object
	$body:=$parameters.body()
	$body.model:=$model
	
	// Build files object
	var $files : Object
	If (Length:C16(String:C10($parameters.filename))>0)
		$files:={file: {file: $file; filename: $parameters.filename}}
	Else 
		$files:={file: $file}
	End if 
	
	// Use _postFiles for multipart/form-data
	return This:C1470._client._postFiles("/audio/translations"; $body; $files; $parameters; cs:C1710.OpenAIAudioTranslationResult)
	