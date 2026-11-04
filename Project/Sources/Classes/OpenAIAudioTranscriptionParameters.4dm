// Strategy for chunking audio. Can be "auto" or a voice activity detection configuration: {type: "server_vad"; threshold: 0.5}
property chunking_strategy : Variant

// Additional information to include in the response, ie. "logprobs"
property include : Collection

// Words or phrases to guide the transcription (gpt-transcribe)
property keywords : Collection

// List of known speaker names for diarization (up to 4 speakers)
property known_speaker_names : Collection

// Audio samples as data URLs for speaker references (2-10 seconds each)
property known_speaker_references : Collection

// The language of the input audio in ISO-639-1 format (e.g., "en", "fr", "es")
property language : Text

// Possible languages of the input audio in ISO-639-1 format (gpt-transcribe)
property languages : Collection

// Optional text to guide the model's style or continue a previous audio segment
property prompt : Text

// The format of the transcript output, ie. json, text, srt, verbose_json, vtt, diarized_json
property response_format : Text

// Enable streaming of the transcription response. You must provide a formula.
property stream : Boolean

// Sampling temperature between 0 and 1. Default: 0
property temperature : Real

// The timestamp granularities to populate, ie. "word" and "segment". Need the response format verbose_json.
property timestamp_granularities : Collection

// File name to use for blob uploads, its extension tells the audio format (optional)
property filename : Text

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)

Function body() : Object
	var $body:=Super:C1706.body()

	If (This:C1470.chunking_strategy#Null:C1517)
		$body.chunking_strategy:=This:C1470.chunking_strategy
	End if

	var $key : Text
	For each ($key; ["include"; "keywords"; "known_speaker_names"; "known_speaker_references"; "languages"; "timestamp_granularities"])
		If ((This:C1470[$key]#Null:C1517) && (This:C1470[$key].length>0))
			$body[$key]:=This:C1470[$key]
		End if
	End for each

	If (Length:C16(String:C10(This:C1470.language))>0)
		$body.language:=This:C1470.language
	End if

	If (Length:C16(String:C10(This:C1470.prompt))>0)
		$body.prompt:=This:C1470.prompt
	End if

	If (Length:C16(String:C10(This:C1470.response_format))>0)
		$body.response_format:=This:C1470.response_format
	End if

	If (This:C1470.stream=True:C214)
		$body.stream:=This:C1470.stream
	End if

	If (This:C1470.temperature>=0)
		$body.temperature:=This:C1470.temperature
	End if

	return $body

