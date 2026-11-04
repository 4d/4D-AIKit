// API resource for OpenAI Audio endpoints
// Supports text-to-speech and speech-to-text (transcription)

Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)

/*
* Generate audio from input text (text-to-speech).
*
* @param $input {Text} The text to generate audio for (required)
* @param $model {Text} The TTS model to use (required)
* @param $voice {Text|Object} A voice name, or a custom voice reference as {id: "voice_1234"} (required)
* @param $parameters {cs.OpenAIAudioSpeechParameters} Optional parameters including response_format, speed, instructions
* @return {cs.OpenAIAudioSpeechResult} Result containing the generated audio
* @throws Error if input, model or voice is empty
*/
Function speech($input : Text; $model : Text; $voice : Variant; $parameters : cs:C1710.OpenAIAudioSpeechParameters) : cs:C1710.OpenAIAudioSpeechResult

	If (Length:C16($input)=0)
		throw:C1805(1; "Expected a non-empty value for `input`")
	End if

	If (Length:C16($model)=0)
		throw:C1805(1; "Expected a non-empty value for `model`")
	End if

	Case of
		: (Value type:C1509($voice)=Is text:K8:3)
			If (Length:C16($voice)=0)
				throw:C1805(1; "Expected a non-empty value for `voice`")
			End if
		: (Value type:C1509($voice)=Is object:K8:27)
			If (Length:C16(String:C10($voice.id))=0)
				throw:C1805(1; "Expected an `id` for the custom `voice`")
			End if
		Else
			throw:C1805(1; "Expected a Text or an Object for `voice`")
	End case

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIAudioSpeechParameters)))
		$parameters:=cs:C1710.OpenAIAudioSpeechParameters.new($parameters)
	End if

	var $body : Object
	$body:=$parameters.body()
	$body.input:=$input
	$body.model:=$model
	$body.voice:=$voice

	return This:C1470._client._post("/audio/speech"; $body; $parameters; cs:C1710.OpenAIAudioSpeechResult)

/*
* Transcribe audio into the input language (speech-to-text).
*
* @param $file {4D.File|4D.Blob} The audio file to transcribe (required)
* @param $model {Text} The transcription model (required)
* @param $parameters {cs.OpenAIAudioTranscriptionParameters} Optional parameters including language, response_format, temperature
* @return {cs.OpenAIAudioTranscriptionResult} Result containing the transcription text
* @throws Error if file is not 4D.File or 4D.Blob, or if model is empty
*/
Function transcription($file : Variant; $model : Text; $parameters : cs:C1710.OpenAIAudioTranscriptionParameters) : cs:C1710.OpenAIAudioTranscriptionResult

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIAudioTranscriptionParameters)))
		$parameters:=cs:C1710.OpenAIAudioTranscriptionParameters.new($parameters)
	End if

	If (Bool:C1537($parameters.stream))
		ASSERT:C1129($parameters._isAsync(); "When streaming you must provide a formula")
	End if

	var $isFile:=False:C215
	var $isBlob:=False:C215

	Case of
		: (Value type:C1509($file)=Is object:K8:27)
			$isFile:=OB Instance of:C1731($file; 4D:C1709.File)
			$isBlob:=OB Instance of:C1731($file; 4D:C1709.Blob)
		: (Value type:C1509($file)=Is BLOB:K8:12)
			$isBlob:=True:C214
			$file:=4D:C1709.Blob.new($file)
	End case

	If (Not:C34($isFile) && Not:C34($isBlob))
		throw:C1805(1; "Expected a non-empty value for `file` (must be 4D.File or 4D.Blob/Blob)")
	End if

	If (Length:C16($model)=0)
		throw:C1805(1; "Expected a non-empty value for `model`")
	End if

	var $body : Object
	$body:=$parameters.body()
	$body.model:=$model

	// the server identifies the audio format with the extension of the file name
	var $filename : Text:=String:C10($parameters["filename"])
	If ((Length:C16($filename)=0) && $isBlob)
		$filename:=This:C1470._audioFilename($file)
	End if

	var $files : Object
	If (Length:C16($filename)>0)
		$files:={file: {file: $file; filename: $filename}}
	Else
		$files:={file: $file}
	End if

	return This:C1470._client._postFiles("/audio/transcriptions"; $body; $files; $parameters; cs:C1710.OpenAIAudioTranscriptionResult)

	// MARK:- utils
	
	// Find a file name for an audio blob, from the signature of its format.
Function _audioFilename($blob : 4D:C1709.Blob) : Text
	var $bytes : Blob:=$blob.slice(0; 12)
	var $size : Integer:=BLOB size:C605($bytes)

	var $signature : Text:=""
	var $index : Integer
	For ($index; 0; $size-1)
		$signature+=($bytes{$index}=0) ? " " : Char:C90($bytes{$index})  // no nul in text
	End for

	Case of
		: (Position:C15("RIFF"; $signature; *)=1)
			return "audio.wav"
		: (Position:C15("OggS"; $signature; *)=1)
			return "audio.ogg"
		: (Position:C15("fLaC"; $signature; *)=1)
			return "audio.flac"
		: (Position:C15("ftyp"; $signature; *)=5)
			return "audio.m4a"
		: ($size<2)
			return "audio.mp3"
		: (($bytes{0}=0x001A) && ($bytes{1}=0x0045))
			return "audio.webm"  // EBML header
	End case

	return "audio.mp3"  // ID3 tag or MPEG frame sync: the signature is not reliable, and it is the most common

