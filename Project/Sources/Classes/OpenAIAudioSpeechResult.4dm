// Result class for audio speech generation (text-to-speech)

Class extends OpenAIResult

// Convert the audio response to a blob
Function asBlob() : 4D:C1709.Blob
	var $blob : 4D:C1709.Blob
	
	If (This:C1470.request#Null:C1517) && (This:C1470.request.response#Null:C1517)
		$blob:=This:C1470.request.response.body
	End if 
	
	return $blob
	
	// Get the MIME type of the audio content from response headers
Function get mimeType() : Text
	var $mimeType : Text
	
	If (This:C1470.request#Null:C1517) && (This:C1470.request.response#Null:C1517)
		If (This:C1470.request.response.headers#Null:C1517)
			$mimeType:=This:C1470.request.response.rawHeaders["Content-Type"]
		End if 
	End if 
	
	return $mimeType
	
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
	