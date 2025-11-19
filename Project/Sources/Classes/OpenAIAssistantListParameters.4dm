// Parameters for listing assistants

// A limit on the number of objects to be returned (between 1 and 100, default 20)
property limit : Integer

// Sort order by the created_at timestamp (asc or desc, default desc)
property order : Text

// A cursor for use in pagination (defines place in list for next page)
property after : Text

// A cursor for use in pagination (defines place in list for previous page)
property before : Text

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)

Function body() : Object
	var $body:=Super:C1706.body()

	If (This:C1470.limit>0)
		$body.limit:=This:C1470.limit
	End if

	If (Length:C16(String:C10(This:C1470.order))>0)
		$body.order:=This:C1470.order
	End if

	If (Length:C16(String:C10(This:C1470.after))>0)
		$body.after:=This:C1470.after
	End if

	If (Length:C16(String:C10(This:C1470.before))>0)
		$body.before:=This:C1470.before
	End if

	return $body

