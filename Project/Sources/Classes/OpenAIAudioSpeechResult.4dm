// Result class for audio speech generation (text-to-speech)

Class extends OpenAIResult

// Convert the audio response to a blob. Null if there is no audio, ie. on API error.
Function asBlob() : 4D:C1709.Blob
	If (Not:C34(This:C1470.success))
		return Null:C1517
	End if

	var $body : Variant:=This:C1470.request.response.body
	If ((Value type:C1509($body)=Is object:K8:27) && (OB Instance of:C1731($body; 4D:C1709.Blob)))
		return $body
	End if

	return Null:C1517

	// Get the MIME type of the audio content from response headers
Function get mimeType() : Text
	If ((This:C1470.request=Null:C1517) || (This:C1470.headers=Null:C1517))
		return ""
	End if
	return String:C10(This:C1470.headers["content-type"])  // `headers` keys are in lowercase, whatever the server sends

	// Save the audio to disk
	// Returns false if audio data could not be retrieved
Function saveAudioToDisk($file : 4D:C1709.File) : Boolean
	If (Not:C34(Asserted:C1132($file#Null:C1517; "You must provide a non null file")))
		return False:C215
	End if

	var $blob:=This:C1470.asBlob()
	If ($blob#Null:C1517)
		$file.setContent($blob)
		return True:C214
	End if

	return False:C215

