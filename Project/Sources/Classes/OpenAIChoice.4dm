property finish_reason : Text
property index : Integer
property message : cs:C1710.OpenAIMessage

// partial message for stream: true
property delta : cs:C1710.OpenAIMessage

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 
	
	If (This:C1470["message"]#Null:C1517)
		This:C1470["message"]:=cs:C1710.OpenAIMessage.new(This:C1470["message"])
	End if 
	
	If (This:C1470["delta"]#Null:C1517)
		This:C1470["delta"]:=cs:C1710.OpenAIMessage.new(This:C1470["delta"])
	End if 