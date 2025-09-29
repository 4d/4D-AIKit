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
				For each ($item; $acc_value)
					If (Not:C34((Value type:C1509($item)=Is text:K8:3) || (Value type:C1509($item)=Is longint:K8:6) || (Value type:C1509($item)=Is real:K8:4)))
						$all_primitives:=False:C215
						break
					End if 
				End for each 
				
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
					
					If ($acc_value[$index]=Null:C1517)
						$acc_value[$index]:=$delta_entry
					Else 
						If (Not:C34((Value type:C1509($acc_value[$index])=Is object:K8:27)))
							// Handle case where existing entry is not a dictionary
							$acc_value[$index]:=$delta_entry
						Else 
							$acc_value[$index]:=This:C1470._accumulateDeltaBetween($acc_value[$index]; $delta_entry)
						End if 
					End if 
				End for each 
				
			Else 
				// Default case: replace with delta value
				$acc[$key]:=$delta_value
		End case 
	End for each 
	
	return $acc
	
Function _accumulateDelta($delta : cs:C1710.OpenAIMessage)
	
	var $result : Object:=This:C1470._accumulateDeltaBetween(OB Copy:C1225(This:C1470); $delta)
	
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