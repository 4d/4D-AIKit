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
		If ($key="text")  // computed properties
			continue
		End if 
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
	
	// delta accumulation
Function _accumulateDeltaBetween($acc : Object; $delta : Object) : Object
	If ($acc=Null:C1517)
		$acc:={}
	End if 
	
	If ($delta=Null:C1517)
		return $acc
	End if 
	
	var $key : Text
	For each ($key; $delta)
		var $delta_value : Variant:=$delta[$key]
		
		// If delta value is null, skip it (don't overwrite accumulated value)
		If ($delta_value=Null:C1517)
			//continue
		End if 
		
		// If key doesn't exist in accumulator, just set it
		If (Undefined:C82($acc[$key]))
			$acc[$key]:=$delta_value
			continue
		End if 
		
		var $acc_value : Variant:=$acc[$key]
		
		// If accumulated value is null, replace with delta value
		If ($acc_value=Null:C1517)
			$acc[$key]:=$delta_value
			continue
		End if 
		
		
		// Special handling for index and type properties
		If (($key="index") || ($key="type"))
			$acc[$key]:=$delta_value
			continue
		End if 
		
		// Handle different value types
		Case of 
				// String concatenation
			: ((Value type:C1509($acc_value)=Is text:K8:3) && (Value type:C1509($delta_value)=Is text:K8:3))
				$acc[$key]:=$acc_value+$delta_value
				
				// Numeric addition
			: (((Value type:C1509($acc_value)=Is real:K8:4) || (Value type:C1509($acc_value)=Is longint:K8:6)) && ((Value type:C1509($delta_value)=Is real:K8:4) || (Value type:C1509($delta_value)=Is longint:K8:6)))
				$acc[$key]:=$acc_value+$delta_value
				
				// Recursive object merging
			: ((Value type:C1509($acc_value)=Is object:K8:27) && (Value type:C1509($delta_value)=Is object:K8:27))
				$acc[$key]:=This:C1470._accumulateDeltaBetween($acc_value; $delta_value)
				
				// Collection/array handling
			: ((Value type:C1509($acc_value)=Is collection:K8:32) && (Value type:C1509($delta_value)=Is collection:K8:32))
				
				// For collections of primitive values, just extend
				var $all_primitives : Boolean:=True:C214
				var $item : Variant
				
				// Check accumulated collection for primitives
				For each ($item; $acc_value)
					If (Not:C34((Value type:C1509($item)=Is text:K8:3) || (Value type:C1509($item)=Is longint:K8:6) || (Value type:C1509($item)=Is real:K8:4)))
						$all_primitives:=False:C215
						break
					End if 
				End for each 
				
				// Also check delta collection for primitives (especially important when acc is empty)
				If ($all_primitives)
					For each ($item; $delta_value)
						If (Not:C34((Value type:C1509($item)=Is text:K8:3) || (Value type:C1509($item)=Is longint:K8:6) || (Value type:C1509($item)=Is real:K8:4)))
							$all_primitives:=False:C215
							break
						End if 
					End for each 
				End if 
				
				If ($all_primitives)
					For each ($item; $delta_value)
						$acc_value.push($item)
					End for each 
					continue
				End if 
				
				// For collections of objects, handle by index
				var $delta_entry : Variant
				For each ($delta_entry; $delta_value)
					If (Not:C34((Value type:C1509($delta_entry)=Is object:K8:27)))
						// Unexpected list delta entry is not a dictionary
						continue
					End if 
					
					If (Undefined:C82($delta_entry.index))
						// Expected list delta entry to have an index key
						continue
					End if 
					
					var $index : Integer:=$delta_entry.index
					If (Not:C34((Value type:C1509($index)=Is longint:K8:6) || (Value type:C1509($index)=Is real:K8:4)))
						// Unexpected, list delta entry index value is not an integer
						continue
					End if 
					
					// Ensure collection is large enough
					While ($acc_value.length<=$index)
						$acc_value.push(Null:C1517)
					End while 
					
					// Create a copy of delta entry without the index property
					var $cleanDeltaEntry : Object:={}
					var $deltaKey : Text
					For each ($deltaKey; $delta_entry)
						If ($deltaKey#"index")
							$cleanDeltaEntry[$deltaKey]:=$delta_entry[$deltaKey]
						End if 
					End for each 
					
					If ($acc_value[$index]=Null:C1517)
						$acc_value[$index]:=$cleanDeltaEntry
					Else 
						If (Not:C34((Value type:C1509($acc_value[$index])=Is object:K8:27)))
							// Handle case where existing entry is not a dictionary
							$acc_value[$index]:=$cleanDeltaEntry
						Else 
							$acc_value[$index]:=This:C1470._accumulateDeltaBetween($acc_value[$index]; $cleanDeltaEntry)
						End if 
					End if 
				End for each 
				
			Else 
				// Default case: replace with delta value
				$acc[$key]:=$delta_value
		End case 
	End for each 
	
	return $acc
	
	
	// because ob copy seems to keep shared stuff
Function _asObjectNotShared($object : Object) : Object
	var $result:={}
	
	var $key : Text
	For each ($key; $object)
		
		Case of 
			: (Value type:C1509($object[$key])=Is object:K8:27)
				$result[$key]:=This:C1470._asObjectNotShared($object[$key])
			: (Value type:C1509($object[$key])=Is collection:K8:32)
				$result[$key]:=This:C1470._asCollectionNotShared($object[$key])
			Else 
				$result[$key]:=$object[$key]
		End case 
		
	End for each 
	
	return $result
	
	
Function _asCollectionNotShared($collection : Collection) : Collection
	var $result:=[]
	
	var $element : Variant
	For each ($element; $collection)
		
		Case of 
			: (Value type:C1509($element)=Is object:K8:27)
				$result.push(This:C1470._asObjectNotShared($element))
			: (Value type:C1509($element)=Is collection:K8:32)
				$result.push(This:C1470._asCollectionNotShared($element))
			Else 
				$result.push($element)
		End case 
		
	End for each 
	
	
	return $result
	
Function _toObject() : Object
	var $key : Text
	var $acc:={}
	var $this:=This:C1470  // if possible have a not shared copy...so less code
	
	For each ($key; $this)
		If ($key="text")  // skip computed properties
			continue
		End if 
		
		If (OB Is shared:C1759(This:C1470))
			
			Case of 
				: (Value type:C1509(This:C1470[$key])=Is object:K8:27)
					$acc[$key]:=This:C1470._asObjectNotShared(This:C1470[$key])
				: (Value type:C1509(This:C1470[$key])=Is collection:K8:32)
					$acc[$key]:=This:C1470._asCollectionNotShared(This:C1470[$key])
				Else 
					$acc[$key]:=This:C1470[$key]
			End case 
			
		Else 
			
			$acc[$key]:=This:C1470[$key]
			
		End if 
		
	End for each 
	
	return $acc
	
Function _accumulateDelta($delta : cs:C1710.OpenAIMessage)
	
	var $result : Object:=This:C1470._accumulateDeltaBetween(This:C1470._toObject(); $delta._toObject())
	
	// Apply results back to this message
	If (OB Is shared:C1759(This:C1470))
		Use (This:C1470)
			var $key : Text
			For each ($key; $result)
				Case of 
					: (Value type:C1509($result[$key])=Is object:K8:27)
						This:C1470[$key]:=OB Copy:C1225($result[$key]; ck shared:K85:29; This:C1470)
					: (Value type:C1509($result[$key])=Is collection:K8:32)
						This:C1470[$key]:=$result[$key].copy(ck shared:K85:29; This:C1470)
					Else 
						This:C1470[$key]:=$result[$key]
				End case 
			End for each 
			
		End use 
	Else 
		For each ($key; $result)
			This:C1470[$key]:=$result[$key]
		End for each 
	End if 