// Identifier for the last message from the previous pagination request.
property after : Text:=""

// Number of messages to retrieve.
property limit : Integer:=0

//  order: Sort order for messages by timestamp. Use `asc` for ascending order or `desc` for descending order. Defaults to `asc`.
property order : Text:="asc"

//  A list of metadata keys to filter the chat completions by. Example: `metadata[key1]=value1&metadata[key2]=value2`
property metadata : Text

// The model used to generate the chat completions.
property model : Text:=""

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
	If (Length:C16(This:C1470.model)>0)
		$body.model:=This:C1470.model
	End if 
	If (Length:C16(This:C1470.metadata)>0)
		$body.metadata:=This:C1470.metadata
	End if 
	
	return $body
	
	
	