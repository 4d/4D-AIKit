
property id : Text
property created : Integer
property object : Text  // ex: model
property owned_by : Text  // ex: system

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 