// Additional instructions for the voice (only works with gpt-4o-mini-tts model). Max 500 characters.
property instructions : Text

// The audio format to generate. Options: mp3, opus, aac, flac, wav, pcm. Default: mp3
property response_format : Text

// The playback speed of the generated audio. Range: 0.25 to 4.0. Default: 1.0
property speed : Real

// The stream format for streaming responses. Options: sse, audio. Default: audio
property stream_format : Text

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)

Function body() : Object
	var $body:=Super:C1706.body()

	// Add instructions if provided (max 500 chars)
	If (Length:C16(String:C10(This:C1470.instructions))>0)
		If (Length:C16(This:C1470.instructions)>500)
			throw:C1805(1; "Instructions must not exceed 500 characters")
		End if
		$body.instructions:=This:C1470.instructions
	End if

	// Add response format if provided
	If (Length:C16(String:C10(This:C1470.response_format))>0)
		var $validFormats : Collection:=["mp3"; "opus"; "aac"; "flac"; "wav"; "pcm"]
		If ($validFormats.indexOf(This:C1470.response_format)=-1)
			throw:C1805(1; "Invalid response_format. Must be one of: "+$validFormats.join(", "))
		End if
		$body.response_format:=This:C1470.response_format
	End if

	// Add speed if provided (0.25 to 4.0)
	If (This:C1470.speed>0)
		If (This:C1470.speed<0.25) || (This:C1470.speed>4.0)
			throw:C1805(1; "Speed must be between 0.25 and 4.0")
		End if
		$body.speed:=This:C1470.speed
	End if

	// Add stream format if provided
	If (Length:C16(String:C10(This:C1470.stream_format))>0)
		var $validStreamFormats : Collection:=["sse"; "audio"]
		If ($validStreamFormats.indexOf(This:C1470.stream_format)=-1)
			throw:C1805(1; "Invalid stream_format. Must be one of: "+$validStreamFormats.join(", "))
		End if
		$body.stream_format:=This:C1470.stream_format
	End if

	return $body
