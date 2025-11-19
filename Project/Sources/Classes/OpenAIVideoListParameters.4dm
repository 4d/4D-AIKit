/*
Class: OpenAIVideoListParameters
Parameters for listing videos with pagination support.

Properties:
  after - Cursor for pagination (ID of last video from previous request)
  limit - Number of videos to retrieve (default: 20)
  order - Sort order: "asc" or "desc" (default: "desc")
*/

// Properties for video listing
property after : Text:=""  // Pagination cursor
property limit : Integer:=20  // Number of items to retrieve
property order : Text:="desc"  // Sort order (asc or desc)

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)

/*
Function: body
Converts parameters to API query parameters format.

Returns:
  Object - The query parameters with all non-empty values
*/
Function body() : Object

	var $body : Object:=Super:C1706.body()

	// After cursor for pagination
	If (Length:C16(String:C10(This:C1470.after))>0)
		$body.after:=This:C1470.after
	End if

	// Limit parameter
	If (This:C1470.limit>0)
		$body.limit:=This:C1470.limit
	End if

	// Order parameter
	If (Length:C16(String:C10(This:C1470.order))>0)
		$body.order:=This:C1470.order
	End if

	return $body
