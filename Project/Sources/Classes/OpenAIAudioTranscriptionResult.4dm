// Result class for audio transcription (speech-to-text)

Class extends OpenAIResult

// Get the transcription object from the response
Function get transcription() : cs:C1710.OpenAIAudioTranscription
	var $transcription : cs:C1710.OpenAIAudioTranscription
	
	var $body:=This:C1470._objectBody()
	If ($body#Null:C1517)
		$transcription:=cs:C1710.OpenAIAudioTranscription.new($body)
	End if 
	
	return $transcription
	
	// Convenience getter for the transcribed text
Function get text() : Text
	var $text : Text
	
	var $transcription:=This:C1470.transcription
	If ($transcription#Null:C1517)
		$text:=$transcription.text
	End if 
	
	return $text
	
	// Get raw text content for non-JSON response formats (text, srt, vtt)
Function get textContent() : Text
	var $textContent : Text
	
	If (This:C1470.request#Null:C1517) && (This:C1470.request.response#Null:C1517)
		If (This:C1470.request.response.body#Null:C1517)
			// For text formats, the body might be a blob containing text
			var $blob : Variant:=This:C1470.request.response.body
			Case of 
				: (Value type:C1509($blob)=Is text:K8:3)
					$textContent:=$blob
				: (OB Instance of:C1731($blob; 4D:C1709.Blob))
					$textContent:=Convert to text:C1012($blob; "UTF-8")
			End case 
		End if 
	End if 
	
	return $textContent
	