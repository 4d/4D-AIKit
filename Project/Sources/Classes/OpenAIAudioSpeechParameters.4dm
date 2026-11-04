// Additional instructions for the voice. Does not work with tts-1 and tts-1-hd.
property instructions : Text

// The audio format to generate, ie. mp3, opus, aac, flac, wav, pcm. Default: mp3
property response_format : Text

// The speed of the generated audio. From 0.25 to 4.0. Default: 1.0
property speed : Real

// The format to stream the audio in, ie. audio or sse. Default: audio
property stream_format : Text

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)

Function body() : Object
	var $body:=Super:C1706.body()

	If (Length:C16(String:C10(This:C1470.instructions))>0)
		$body.instructions:=This:C1470.instructions
	End if

	If (Length:C16(String:C10(This:C1470.response_format))>0)
		$body.response_format:=This:C1470.response_format
	End if

	If (This:C1470.speed>0)
		$body.speed:=This:C1470.speed
	End if

	If (Length:C16(String:C10(This:C1470.stream_format))>0)
		$body.stream_format:=This:C1470.stream_format
	End if

	return $body

