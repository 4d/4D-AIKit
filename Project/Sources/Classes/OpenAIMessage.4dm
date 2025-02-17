property role : Text  // ex: "developer", "system", "user", "assistant", "tool", "function"
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
	
	
	// utility function to find first JSON in message that could be returned by 
Function _extractJSONObject() : Object
	
	var $message : Text:=""
	If (Value type:C1509(This:C1470.content)=Is text:K8:3)
		$message:=This:C1470.content
	End if 
	
	If (Length:C16($message)=0)
		return Null:C1517
	End if 
	
	var $pos:=Position:C15("{"; $message)
	
	If ($pos<=0)
		return Null:C1517
	End if 
	
	$message:=Substring:C12($message; $pos)
	
	ARRAY LONGINT:C221($a_pos; 0)
	ARRAY LONGINT:C221($a_len; 0)
	If (Not:C34(Match regex:C1019(".+(\\}.+)$"; $message; 1; $a_pos; $a_len)))
		return Null:C1517
	End if 
	$pos:=$a_pos{1}
	If ($pos<=0)
		return Null:C1517
	End if 
	
	$message:=Substring:C12($message; 1; $pos)
	
	return Try(JSON Parse:C1218($message))