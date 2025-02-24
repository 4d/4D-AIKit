// The model to use for audio processing.
property model : Text:="whisper-1"

// The language of the audio input.
property language : Text

// The prompt to guide the audio processing.
property prompt : Text

// The format in which the response is returned.
property response_format : Text  // "text" || "json"

// The temperature to use for the audio processing. between 0 and 1. (Defaults to 0)
property temperature : Integer:=-1

Class extends OpenAIParameters

Class constructor($object : Object)
    Super:C1705($object)

Function body() : Object
    var $body:=Super:C1706.body()
    
    If (Length:C16(This:C1470.model)>0)
        $body.model:=This:C1470.model
    End if 
    If (Length:C16(String(This:C1470.language))>0)
        $body.language:=This:C1470.language
    End if 
    If (Length:C16(String(This:C1470.prompt))>0)
        $body.prompt:=This:C1470.prompt
    End if 
    If (Length:C16(String(This:C1470.response_format))>0)
        $body.response_format:=This:C1470.response_format
    End if 
    If (This:C1470.temperature>=0)
        $body.temperature:=This:C1470.temperature
    End if 
    
    return $body