// Deletion status of a voice or of a voice consent

// The ID of the deleted object
property id : Text

// Whether the object was successfully deleted
property deleted : Boolean

// The object type, ie. "audio.voice.deleted" or "audio.voice_consent"
property object : Text

Class constructor($object : Object)
	If ($object=Null)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This[$key]:=$object[$key]
	End for each 
