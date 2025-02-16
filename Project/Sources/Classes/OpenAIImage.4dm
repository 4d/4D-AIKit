
// The URL of the generated image, if `response_format` is `url` (default)."""
property url : Text

// The base64-encoded JSON of the generated image, if `response_format` is `b64_json`.
property b64_json : Text

// The prompt that was used to generate the image, if there was any revision to the prompt.
property revised_prompt : Variant

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 
	
Function asBlob() : 4D:C1709.Blob
	
	Case of 
		: (Length:C16(String:C10(This:C1470.url))>0)
			
			return cs:C1710._ImageUtils.me.httpURLToBlob(This:C1470.url)
			
		: (Length:C16(String:C10(This:C1470.b64_json))>0)
			
			return cs:C1710._ImageUtils.me.base64ToBlob(This:C1470.url)
			
	End case 
	
	return Null:C1517
	
Function asPicture() : Picture
	var $picture : Picture
	
	var $blob : 4D:C1709.Blob:=This:C1470.asBlob()
	If ($blob#Null:C1517)
		BLOB TO PICTURE:C682($blob; $picture)
	End if 
	
	return $picture
	
Function saveToDisk($file : 4D:C1709.File) : Boolean
	ASSERT:C1129($file#Null:C1517)
	
	var $blob:=This:C1470.asBlob()
	If ($blob#Null:C1517)
		$file.setContent($blob)
		return True:C214
	End if 
	
	return False:C215