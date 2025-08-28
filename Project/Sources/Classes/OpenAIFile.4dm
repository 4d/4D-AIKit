property id : Text
property bytes : Integer
property created_at : Integer
property filename : Text
property object : Text
property purpose : Text
property status : Text
property expires_at : Integer
property status_details : Text

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 
