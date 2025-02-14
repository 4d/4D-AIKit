// Identifier for the last message from the previous pagination request.
property after : Text:=""

// Number of messages to retrieve.
property limit : Integer:=0

//  order: Sort order for messages by timestamp. Use `asc` for ascending order or `desc` for descending order. Defaults to `asc`.
property order : Text:="asc"

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)
	
Function body() : Object
	var $body:=Super:C1706.body()
	
	If (Length:C16(This:C1470.after)>0)
		$body.after:=This:C1470.after
	End if 
	If (This:C1470.limit>0)
		$body.limit:=This:C1470.limit
	End if 
	$body.order:=This:C1470.order
	
	return $body