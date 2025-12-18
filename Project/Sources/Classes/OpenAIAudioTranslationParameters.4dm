// Optional text to guide the model's style (should be in English)
property prompt : Text

// The format of the translation output. Options: json, text, srt, verbose_json, vtt
property response_format : Text

// Sampling temperature between 0 and 1. Default: 0
property temperature : Real

// Filename to use for blob uploads (optional)
property filename : Text

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)

Function body() : Object
	var $body:=Super:C1706.body()

	// Add prompt if provided
	If (Length:C16(String:C10(This:C1470.prompt))>0)
		$body.prompt:=This:C1470.prompt
	End if

	// Add response format if provided
	If (Length:C16(String:C10(This:C1470.response_format))>0)
		var $validFormats : Collection:=["json"; "text"; "srt"; "verbose_json"; "vtt"]
		If ($validFormats.indexOf(This:C1470.response_format)=-1)
			throw:C1805(1; "Invalid response_format. Must be one of: "+$validFormats.join(", "))
		End if
		$body.response_format:=This:C1470.response_format
	End if

	// Add temperature if provided (0 to 1)
	If (This:C1470.temperature>0) || (This:C1470.temperature=0)
		If (This:C1470.temperature<0) || (This:C1470.temperature>1)
			throw:C1805(1; "Temperature must be between 0 and 1")
		End if
		$body.temperature:=This:C1470.temperature
	End if

	return $body
