// Parameters for listing files

// A cursor for use in pagination. after is an object ID that defines your place in the list
property after : Text

// A limit on the number of objects to be returned (1-10,000, default 10,000)
property limit : Integer

// Sort order by the created_at timestamp ("asc" for ascending, "desc" for descending)
property order : Text

// Only return files with the given purpose
property purpose : Text

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
	If (Length:C16(This:C1470.purpose)>0)
		$body.purpose:=This:C1470.purpose
	End if 
	
	return $body
	