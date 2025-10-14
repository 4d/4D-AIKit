// Parameters for file operations

// The expiration policy for a file. By default, files with purpose=batch expire after 30 days and all other files are persisted until they are manually deleted.
property expires_after : Object

// Chosen filename (mandatory for the blob to be correctly recognized by OpenAI)
property filename : Text

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)
	
Function body() : Object
	var $body:=Super:C1706.body()
	
	If (This:C1470.expires_after#Null:C1517)
		$body.expires_after:={}
		
		// Anchor timestamp after which the expiration policy applies. Supported anchors: created_at.
		If (Length:C16(String:C10(This:C1470.expires_after.anchor))>0)
			$body.expires_after.anchor:=This:C1470.expires_after.anchor
		End if 
		
		// The number of seconds after the anchor time that the file will expire. Must be between 3600 (1 hour) and 2592000 (30 days).
		If (This:C1470.expires_after.seconds>0)
			$body.expires_after.seconds:=This:C1470.expires_after.seconds
		End if 
	End if 
	
	return $body
	