// The ID of the deleted file
property id : Text

// Whether the file was successfully deleted
property deleted : Boolean

// The object type, which is always "file"
property object : Text

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 
