// Result class for audio transcription (speech-to-text)

Class extends OpenAIResult

// Get the transcription object from the response. Null on API error, or with the non-JSON response formats (text, srt, vtt).
Function get transcription() : cs:C1710.OpenAIAudioTranscription
	If (Not:C34(This:C1470.success))
		return Null:C1517
	End if

	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if

	return cs:C1710.OpenAIAudioTranscription.new($body)

	// The transcribed text, whatever the response format. Empty on API error.
Function get text() : Text
	If (Not:C34(This:C1470.success))
		return ""
	End if

	var $transcription:=This:C1470.transcription
	If ($transcription#Null:C1517)
		return String:C10($transcription.text)
	End if

	// text, srt or vtt: the content without the trailing line feeds of the server
	var $text:=This:C1470.textContent
	var $last : Integer:=Length:C16($text)
	While (($last>0) && ((Character code:C91(Substring:C12($text; $last; 1))=Line feed:K15:40) || (Character code:C91(Substring:C12($text; $last; 1))=Carriage return:K15:38)))
		$last-=1
	End while
	return Substring:C12($text; 1; $last)

	// Get raw text content for non-JSON response formats (text, srt, vtt)
Function get textContent() : Text
	If ((This:C1470.request=Null:C1517) || (This:C1470.request.response=Null:C1517))
		return ""
	End if

	var $body : Variant:=This:C1470.request.response.body
	Case of
		: (Value type:C1509($body)=Is text:K8:3)
			return $body
		: ((Value type:C1509($body)=Is object:K8:27) && (OB Instance of:C1731($body; 4D:C1709.Blob)))
			return Convert to text:C1012($body; "UTF-8")
	End case

	return ""

