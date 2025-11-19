// Parameters for listing fine-tuning jobs

// A cursor for use in pagination. after is an object ID that defines your place in the list
property after : Text

// A limit on the number of objects to be returned (1-10,000, default 20)
property limit : Integer

// Filter by custom metadata key-value pairs
property metadata : Object

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
	If (This:C1470.metadata#Null:C1517)
		$body.metadata:=This:C1470.metadata
	End if

	return $body
