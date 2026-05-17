// The ID of the deleted response
property id : Text

// Whether the response was successfully deleted
property deleted : Boolean

// The object type, which is always "response.deleted"
property object : Text

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 
