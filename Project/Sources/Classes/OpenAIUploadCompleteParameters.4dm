// Parameters for completing an Upload
// Note: Mandatory parameter (part_ids) is passed as an explicit function parameter

// Internal property (set by API function, do not set manually)
property part_ids : Collection

// Optional: The md5 checksum for the file contents to verify if the bytes uploaded matches what you expect
property md5 : Text

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)

Function body() : Object
	var $body : Object:=Super:C1706.body()
	
	// Required parameter (set by API function)
	If (This:C1470.part_ids#Null:C1517)
		$body.part_ids:=This:C1470.part_ids
	End if 
	
	// Optional: MD5 checksum
	If (Length:C16(This:C1470.md5)>0)
		$body.md5:=This:C1470.md5
	End if 
	
	return $body
