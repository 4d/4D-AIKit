property role : Text  // ex: "user"
property content : Variant  // ex: "Say this is a test" or Collection of {test: , type}
property user : Text  // optionnal user

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 