// A consent recording, which authorizes the creation of a voice from an audio sample

// The consent recording identifier, ie. cons_1234
property id : Text

// The object type, which is always "audio.voice_consent"
property object : Text

// The label of the consent recording
property name : Text

// The BCP 47 language tag of the consent phrase, ie. en-US
property language : Text

// The Unix timestamp (in seconds) for when the consent recording was created
property created_at : Integer

Class constructor($object : Object)
	If ($object=Null)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This[$key]:=$object[$key]
	End for each 
