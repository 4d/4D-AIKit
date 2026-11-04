// Data class representing an audio transcription response

// The transcribed text
property text : Text

// The type of operation, ie. "transcribe" (verbose_json and diarized_json formats)
property task : Text

// The language of the input audio (verbose_json format)
property language : Text

// The languages detected in the audio, as a collection of {code} (gpt-transcribe)
property languages : Collection

// The duration of the input audio in seconds (verbose_json and diarized_json formats)
property duration : Real

// Segments of the transcription with timestamps (verbose_json format), and speaker (diarized_json format)
property segments : Collection

// Individual words with timestamps (verbose_json format, with timestamp_granularities containing "word")
property words : Collection

// The log probabilities of the tokens (with include containing "logprobs")
property logprobs : Collection

// Usage information with token counts or duration
property usage : Object

Class constructor($object : Object)
	If ($object=Null:C1517)
		return
	End if
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each

