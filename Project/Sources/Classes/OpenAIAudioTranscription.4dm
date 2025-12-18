// Data class representing an audio transcription or translation response

// The transcribed or translated text
property text : Text

// The type of operation: "transcribe" or "translate"
property task : Text

// The language of the input audio in ISO-639-1 format
property language : Text

// The duration of the input audio in seconds
property duration : Real

// Segments of the transcription with timestamps (for verbose_json format)
property segments : Collection

// Individual words with timestamps (for verbose_json format)
property words : Collection

// Speaker diarization information (for diarized_json format)
property diarization : Object

// Usage information with token counts
property usage : Object

Class constructor($object : Object)
	If ($object=Null:C1517)
		return
	End if
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each
