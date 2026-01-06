property name : Text
property apiKey : Text
property baseURL : Text
property organization : Text
property project : Text

Class constructor($object : Object)
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 