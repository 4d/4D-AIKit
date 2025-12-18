// Strategy for chunking audio. Can be "auto" string or an object with type property
property chunking_strategy : Variant

// Additional information to include in the response. Array can contain "logprobs"
property include : Collection

// List of known speaker names for diarization (up to 4 speakers)
property known_speaker_names : Collection

// Audio samples as data URLs for speaker references (2-10 seconds each)
property known_speaker_references : Collection

// The language of the input audio in ISO-639-1 format (e.g., "en", "fr", "es")
property language : Text

// Optional text to guide the model's style or continue a previous audio segment
property prompt : Text

// The format of the transcript output. Options: json, text, srt, verbose_json, vtt, diarized_json
property response_format : Text

// Enable streaming of the transcription response
property stream : Boolean

// Sampling temperature between 0 and 1. Default: 0
property temperature : Real

// Filename to use for blob uploads (optional)
property filename : Text

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)

Function body() : Object
	var $body:=Super:C1706.body()

	// Add chunking strategy if provided
	If (This:C1470.chunking_strategy#Null:C1517)
		$body.chunking_strategy:=This:C1470.chunking_strategy
	End if

	// Add include array if provided
	If (This:C1470.include#Null:C1517) && (This:C1470.include.length>0)
		$body.include:=This:C1470.include
	End if

	// Add known speaker names if provided
	If (This:C1470.known_speaker_names#Null:C1517) && (This:C1470.known_speaker_names.length>0)
		$body.known_speaker_names:=This:C1470.known_speaker_names
	End if

	// Add known speaker references if provided
	If (This:C1470.known_speaker_references#Null:C1517) && (This:C1470.known_speaker_references.length>0)
		$body.known_speaker_references:=This:C1470.known_speaker_references
	End if

	// Add language if provided
	If (Length:C16(String:C10(This:C1470.language))>0)
		$body.language:=This:C1470.language
	End if

	// Add prompt if provided
	If (Length:C16(String:C10(This:C1470.prompt))>0)
		$body.prompt:=This:C1470.prompt
	End if

	// Add response format if provided
	If (Length:C16(String:C10(This:C1470.response_format))>0)
		var $validFormats : Collection:=["json"; "text"; "srt"; "verbose_json"; "vtt"; "diarized_json"]
		If ($validFormats.indexOf(This:C1470.response_format)=-1)
			throw:C1805(1; "Invalid response_format. Must be one of: "+$validFormats.join(", "))
		End if
		$body.response_format:=This:C1470.response_format
	End if

	// Add stream if provided
	If (This:C1470.stream=True:C214)
		$body.stream:=This:C1470.stream
	End if

	// Add temperature if provided (0 to 1)
	If (This:C1470.temperature>0) || (This:C1470.temperature=0)
		If (This:C1470.temperature<0) || (This:C1470.temperature>1)
			throw:C1805(1; "Temperature must be between 0 and 1")
		End if
		$body.temperature:=This:C1470.temperature
	End if

	return $body
