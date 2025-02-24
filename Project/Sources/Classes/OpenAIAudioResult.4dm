Class extends OpenAIResult

// Function to get the transcription or translation of the audio
Function get text : Text
    var $body:=This:C1470._objectBody()
    If ($body=Null:C1517)
        return ""
    End if 
	return $body.text
	