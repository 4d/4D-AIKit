// Identifier for the last item from the previous pagination request
property after : Text:=""

// Additional fields to include in each returned input item
property include : Collection

// Number of input items to retrieve
property limit : Integer:=0

// Sort order for items by timestamp: "asc" or "desc"
property order : Text:="asc"

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)
	
Function body() : Object
	var $body:=Super:C1706.body()
	
	If (Length:C16(This:C1470.after)>0)
		$body.after:=This:C1470.after
	End if 
	If (This:C1470.include#Null:C1517)
		$body.include:=This:C1470.include
	End if 
	If (This:C1470.limit>0)
		$body.limit:=This:C1470.limit
	End if 
	If (Length:C16(This:C1470.order)>0)
		$body.order:=This:C1470.order
	End if 
	
	return $body
