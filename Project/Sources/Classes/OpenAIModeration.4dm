property id : Text
// moderation model
property model : Text
// results of moderations, see item to get first one
property results : Collection

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 
	
Function get item : cs:C1710.OpenAIModerationItem
	If ((This:C1470.results=Null:C1517) || (This:C1470.results.length=0))
		return Null:C1517
	End if 
	return cs:C1710.OpenAIModerationItem.new(This:C1470.results.first())
	