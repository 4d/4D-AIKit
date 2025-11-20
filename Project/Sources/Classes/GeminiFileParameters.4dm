// Display name for the file
property displayName : Text

// MIME type of the file
property mimeType : Text

// Filename override
property filename : Text

Class extends GeminiParameters

Class constructor($object : Object)
	Super:C1705($object)

Function body() : Object
	var $body : Object:=Super:C1706.body()

	If (Length:C16(String:C10(This:C1470.displayName))>0)
		$body.displayName:=This:C1470.displayName
	End if

	If (Length:C16(String:C10(This:C1470.mimeType))>0)
		$body.mimeType:=This:C1470.mimeType
	End if

	return $body

