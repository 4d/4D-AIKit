// Maximum number of files to return
property pageSize : Integer

// Page token for pagination
property pageToken : Text

Class extends GeminiParameters

Class constructor($object : Object)
	Super:C1705($object)

Function body() : Object
	var $body : Object:=Super:C1706.body()

	If (This:C1470.pageSize>0)
		$body.pageSize:=This:C1470.pageSize
	End if

	If (Length:C16(String:C10(This:C1470.pageToken))>0)
		$body.pageToken:=This:C1470.pageToken
	End if

	return $body

