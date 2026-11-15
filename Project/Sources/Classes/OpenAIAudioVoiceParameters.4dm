// Parameters to create a voice

// The audio sample of the voice, as 4D.File or 4D.Blob. OpenAI: at most 60 seconds and 10 MiB. Requires `consent`.
property audio_sample : Variant

// The ID of the consent recording that authorizes the creation of the voice from `audio_sample`, ie. cons_1234
property consent : Text

// The file name of `audio_sample` when it is a blob, to identify its format
property filename : Text

// A description of the desired voice, to create it without audio sample
property prompt : Text

// "audio_sample" or "prompt". By default deduced from the other parameters.
property type : Text

// The model that creates the voice from the `prompt`. Default: auto
property model : Text

// A text for the voice to speak during its creation from the `prompt`
property script_hint : Text

Class extends OpenAIParameters

Class constructor($object : Object)
	Super($object)
	
Function body() : Object
	var $body:=Super.body()
	
	var $key : Text
	For each ($key; ["consent"; "prompt"; "type"; "model"; "script_hint"])
		If (Length(String(This[$key]))>0)
			$body[$key]:=This[$key]
		End if 
	End for each 
	
	return $body
