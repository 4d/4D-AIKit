property categories : Object
property category_score : Object
property flagged : Boolean

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 