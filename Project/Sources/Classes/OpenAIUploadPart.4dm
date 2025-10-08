// The upload Part represents a chunk of bytes added to an Upload object

// The upload Part unique identifier, which can be referenced in API endpoints
property id : Text

// The object type, which is always "upload.part"
property object : Text

// The Unix timestamp (in seconds) for when the Part was created
property created_at : Integer

// The ID of the Upload object that this Part was added to
property upload_id : Text

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 
