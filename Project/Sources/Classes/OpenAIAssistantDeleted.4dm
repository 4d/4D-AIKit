// Represents the deletion status of an assistant

// The identifier of the deleted assistant
property id : Text

// The object type, which is always "assistant.deleted"
property object : Text

// Whether the assistant was successfully deleted
property deleted : Boolean

Class constructor($object : Object)
	If ($object=Null:C1517)
		return
	End if

	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each

