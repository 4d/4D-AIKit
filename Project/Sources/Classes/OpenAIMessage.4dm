// role ex: "developer", "system", "user", "assistant", "tool", "function"
property role : Text
// a Text (ex: "Say this is a test") or a Collection of object {type: ...}
property content : Variant

// optionnal user
property user : Text

// Tool calls request
property tool_calls : Collection
// ID if tool call when responding
property tool_call_id : Text

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 
	
	// shortcut to get text data
Function get text : Text
	Case of 
		: (Value type:C1509(This:C1470.content)=Is text:K8:3)
			return This:C1470.content
		: (Value type:C1509(This:C1470.content)=Is collection:K8:32)
			var $textElement : Variant:=This:C1470.content.find(Formula:C1597(String:C10($1.value.type)="text"))
			If ($textElement#Null:C1517)
				return $textElement.text
			End if 
	End case 
	
	return ""
	
	// allow to set text data to this message
Function set text($text : Text)
	Case of 
		: ((This:C1470.content=Null:C1517) || (Value type:C1509(This:C1470.content)=Is text:K8:3))
			
			This:C1470.content:=$text
			
		: (Value type:C1509(This:C1470.content)=Is collection:K8:32)
			// only one text
			var $textElement : Variant:=This:C1470.content.find(Formula:C1597(String:C10($1.value.type)="text"))
			If ($textElement=Null:C1517)
				This:C1470.content.unshift({type: "text"; text: This:C1470.content})
			Else 
				$textElement.text:=$text
			End if 
			
		Else   // unknown we overwritte
			This:C1470.content:=$text
	End case 
	
Function addImageURL($imageURL : Text; $detail : Text)
	If (Value type:C1509(This:C1470.content)=Is text:K8:3)
		This:C1470.content:=[{type: "text"; text: This:C1470.content}]
	End if 
	var $imageObject:={url: $imageURL}
	If ((Length:C16($detail)>0) && ["auto"; "low"; "high"].includes($detail))
		$imageObject.detail:=$detail
	End if 
	This:C1470.content.push({type: "image_url"; image_url: $imageObject})
	
/*
* Adds a file to the message content. Only files with purpose "user_data" are allowed.
* 
* @param $file {cs.OpenAIFile} The file object to add to the message (must have purpose "user_data")
* @throws Error if file is null, not an OpenAIFile instance, or doesn't have purpose "user_data"
*/
Function addFile($file : cs:C1710.OpenAIFile)
	
	// Validate file parameter
	If ($file=Null:C1517)
		throw:C1805(1; "Expected a non-empty value for `file`")
	End if 
	
	If (Not:C34(OB Instance of:C1731($file; cs:C1710.OpenAIFile)))
		throw:C1805(1; "Expected an OpenAIFile instance")
	End if 
	
	// Verify the file has purpose "user_data"
	If ($file.purpose#"user_data")
		throw:C1805(1; "File must have purpose 'user_data' (current purpose: '"+$file.purpose+"')")
	End if 
	
	// Ensure content is a collection
	If (Value type:C1509(This:C1470.content)=Is text:K8:3)
		This:C1470.content:=[{type: "text"; text: This:C1470.content}]
	End if 
	
	// Add file reference to content
	This:C1470.content.push({type: "file"; file_id: $file.id})
	
	// utility function to find first JSON in message that could be returned by 
Function _extractJSONObject() : Object
	
	var $message : Text:=This:C1470.text
	
	If (Length:C16($message)=0)
		return Null:C1517
	End if 
	
	var $pos:=Position:C15("{"; $message)
	
	If ($pos<=0)
		return Null:C1517
	End if 
	
	$message:=Substring:C12($message; $pos)
	
	ARRAY LONGINT:C221($a_pos; 0)
	ARRAY LONGINT:C221($a_len; 0)
	If (Not:C34(Match regex:C1019(".+(\\}.+)$"; $message; 1; $a_pos; $a_len)))
		return Null:C1517
	End if 
	$pos:=$a_pos{1}
	If ($pos<=0)
		return Null:C1517
	End if 
	
	$message:=Substring:C12($message; 1; $pos)
	
	return Try(JSON Parse:C1218($message))