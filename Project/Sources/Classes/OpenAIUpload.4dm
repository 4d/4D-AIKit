// The Upload object represents a multipart file upload

// The Upload unique identifier, which can be referenced in API endpoints
property id : Text

// The object type, which is always "upload"
property object : Text

// The intended number of bytes to be uploaded
property bytes : Integer

// The Unix timestamp (in seconds) for when the Upload was created
property created_at : Integer

// The name of the file to be uploaded
property filename : Text

// The intended purpose of the file (assistants, batch, fine-tune, vision, user_data, etc.)
property purpose : Text

// The status of the Upload (pending, completed, cancelled, or expired)
property status : Text

// The Unix timestamp (in seconds) for when the Upload will expire
property expires_at : Integer

// The ready File object after the Upload is completed
property file : cs:C1710.OpenAIFile

// The MIME type of the file
property mime_type : Text

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	
	var $key : Text
	For each ($key; $object)
		Case of 
			: ($key="file") && ($object[$key]#Null:C1517)
				// Create nested File object
				This:C1470.file:=cs:C1710.OpenAIFile.new($object[$key])
			Else 
				This:C1470[$key]:=$object[$key]
		End case 
	End for each 
