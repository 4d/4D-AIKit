// The file identifier, which can be referenced in the API endpoints
property id : Text

// The size of the file, in bytes
property bytes : Integer

// The Unix timestamp (in seconds) for when the file was created
property created_at : Integer

// The name of the file
property filename : Text

// The object type, which is always "file"
property object : Text

// The intended purpose of the file (assistants, batch, fine-tune, vision, user_data, etc.)
property purpose : Text

// Deprecated. The current status of the file (uploaded, processed, or error)
property status : Text

// The Unix timestamp (in seconds) for when the file will expire
property expires_at : Integer

// Deprecated. Additional details about the file status
property status_details : Text

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 
