shared singleton Class constructor
	
	// MARK:- Public API
	
	// encode - Convert 4D value to TOON format string
Function encode($input : Variant; $options : Object) : Text
	var $normalizedValue : Variant
	$normalizedValue:=This:C1470._normalizeValue($input)
	
	var $resolvedOptions : Object
	$resolvedOptions:=This:C1470._resolveOptions($options)
	
	var $lines : Collection
	$lines:=This:C1470._encodeValue($normalizedValue; 0; $resolvedOptions)
	
	return $lines.join("\n")
	
	// encodeLines - Convert 4D value to Collection of TOON lines
Function encodeLines($input : Variant; $options : Object) : Collection
	var $normalizedValue : Variant
	$normalizedValue:=This:C1470._normalizeValue($input)
	
	var $resolvedOptions : Object
	$resolvedOptions:=This:C1470._resolveOptions($options)
	
	return This:C1470._encodeValue($normalizedValue; 0; $resolvedOptions)
	
	// MARK:- Foundation
	
	// _normalizeValue - Convert 4D types to JSON-compatible values
Function _normalizeValue($value : Variant) : Variant
	If ($value=Null:C1517)
		return Null:C1517
	End if 
	
	var $type : Integer
	$type:=Value type:C1509($value)
	
	Case of 
		: ($type=Is object:K8:27)
			// Recursively normalize object properties
			var $result : Object
			$result:={}
			var $key : Text
			For each ($key; $value)
				$result[$key]:=This:C1470._normalizeValue($value[$key])
			End for each 
			return $result
			
		: ($type=Is collection:K8:32)
			// Recursively normalize collection items
			var $resultColl : Collection
			$resultColl:=[]
			var $item : Variant
			For each ($item; $value)
				$resultColl.push(This:C1470._normalizeValue($item))
			End for each 
			return $resultColl
			
		: ($type=Is text:K8:3)
			return $value
			
		: ($type=Is real:K8:4)
			// Handle special number cases
			If ($value=-0)
				return 0
			End if 
			If (String:C10($value)="INF") || (String:C10($value)="NAN")
				return Null:C1517
			End if 
			return $value
			
		: ($type=Is longint:K8:6)
			return $value
			
		: ($type=Is boolean:K8:9)
			return $value
			
		: ($type=Is pointer:K8:14)
			return $value
			
		: ($type=Is date:K8:7)
			// Convert to ISO 8601 string
			return String:C10($value; ISO date GMT:K1:10; Date RFC 1123:K1:11)
			
		: ($type=Is time:K8:8)
			// TODO: Convert time to null (or could be ISO duration in future)
			return Null:C1517
			
		: ($type=Is picture:K8:10)
			// Pictures not supported, return null
			return Null:C1517
			
		Else 
			// Unknown type, return null
			return Null:C1517
	End case 
	
	// _resolveOptions - Resolve encoding options with defaults
Function _resolveOptions($options : Object) : Object
	var $resolved : Object
	$resolved:={}
	
	// Default indent: 2 spaces
	If ($options#Null:C1517) && (OB Is defined:C1231($options; "indent"))
		$resolved.indent:=$options.indent
	Else 
		$resolved.indent:=2
	End if 
	
	return $resolved
	
	// MARK:- Main Routing
	
	// _encodeValue - Route value to appropriate encoder
Function _encodeValue($value : Variant; $depth : Integer; $options : Object) : Collection
	var $lines : Collection
	$lines:=[]
	
	If ($value=Null:C1517)
		$lines.push(This:C1470._encodePrimitive($value))
		return $lines
	End if 
	
	var $type : Integer
	$type:=Value type:C1509($value)
	
	Case of 
		: ($type=Is text:K8:3) || ($type=Is real:K8:4) || ($type=Is longint:K8:6) || ($type=Is boolean:K8:9)
			// Primitive at root - return single line
			var $encoded : Text
			$encoded:=This:C1470._encodePrimitive($value)
			If (Length:C16($encoded)>0)
				$lines.push($encoded)
			End if 
			
		: ($type=Is collection:K8:32)
			// Array at root - no key
			$lines:=This:C1470._encodeCollection($value; ""; $depth; $options)
			
		: ($type=Is object:K8:27)
			$lines:=This:C1470._encodeObject($value; $depth; $options)
			
	End case 
	
	return $lines
	
	// _encodeObject - Encode object as indented key-value pairs
Function _encodeObject($obj : Object; $depth : Integer; $options : Object) : Collection
	var $lines : Collection
	$lines:=[]
	
	var $key : Text
	For each ($key; $obj)
		var $value : Variant
		$value:=$obj[$key]
		
		var $encodedKey : Text
		$encodedKey:=This:C1470._encodeKey($key)
		
		If ($value=Null:C1517)
			// null value
			var $line : Text
			$line:=$encodedKey+": "+This:C1470._encodePrimitive($value)
			$lines.push(This:C1470._indentLine($depth; $line; $options.indent))
			continue
		End if 
		
		var $valueType : Integer
		$valueType:=Value type:C1509($value)
		
		Case of 
			: ($valueType=Is text:K8:3) || ($valueType=Is real:K8:4) || ($valueType=Is longint:K8:6) || ($valueType=Is boolean:K8:9)
				// key: value
				$line:=$encodedKey+": "+This:C1470._encodePrimitive($value)
				$lines.push(This:C1470._indentLine($depth; $line; $options.indent))
				
			: ($valueType=Is collection:K8:32)
				// Array - delegate to collection encoder
				var $collectionLines : Collection
				$collectionLines:=This:C1470._encodeCollection($value; $key; $depth; $options)
				var $collLine : Text
				For each ($collLine; $collectionLines)
					$lines.push($collLine)
				End for each 
				
			: ($valueType=Is object:K8:27)
				// Nested object: key:
				$lines.push(This:C1470._indentLine($depth; $encodedKey+":"; $options.indent))
				
				var $keys : Collection
				$keys:=OB Keys:C1719($value)
				If ($keys.length>0)
					var $nestedLines : Collection
					$nestedLines:=This:C1470._encodeObject($value; $depth+1; $options)
					var $nestedLine : Text
					For each ($nestedLine; $nestedLines)
						$lines.push($nestedLine)
					End for each 
				End if 
				
		End case 
	End for each 
	
	return $lines
	
	// _encodeCollection - Detect array type and route to specialized encoder
Function _encodeCollection($coll : Collection; $key : Text; $depth : Integer; $options : Object) : Collection
	var $lines : Collection
	$lines:=[]
	
	// Empty array
	If ($coll.length=0)
		var $header : Text
		$header:=This:C1470._formatHeader(0; $key; Null:C1517)
		$lines.push(This:C1470._indentLine($depth; $header; $options.indent))
		return $lines
	End if 
	
	// Check if all primitives
	If (This:C1470._isArrayOfPrimitives($coll))
		var $inlineLine : Text
		$inlineLine:=This:C1470._encodeArrayOfPrimitives($coll; $key)
		$lines.push(This:C1470._indentLine($depth; $inlineLine; $options.indent))
		return $lines
	End if 
	
	// Check if all objects
	If (This:C1470._isArrayOfObjects($coll))
		var $headerColl : Collection
		$headerColl:=This:C1470._extractTabularHeader($coll)
		
		If ($headerColl#Null:C1517)
			// Tabular format
			$lines:=This:C1470._encodeArrayOfObjects($coll; $key; $headerColl; $depth; $options)
		Else 
			// List format (non-uniform objects)
			$lines:=This:C1470._encodeMixedArrayAsListItems($coll; $key; $depth; $options)
		End if 
		
		return $lines
	End if 
	
	// Mixed array - list format
	$lines:=This:C1470._encodeMixedArrayAsListItems($coll; $key; $depth; $options)
	return $lines
	
	// MARK:- Primitive Encoding
	
	// _encodePrimitive - Convert primitive value to string
Function _encodePrimitive($value : Variant) : Text
	If ($value=Null:C1517)
		return "null"
	End if 
	
	var $type : Integer
	$type:=Value type:C1509($value)
	
	Case of 
		: ($type=Is boolean:K8:9)
			If ($value)
				return "true"
			Else 
				return "false"
			End if 
			
		: ($type=Is real:K8:4) || ($type=Is longint:K8:6)
			return String:C10($value)
			
		: ($type=Is text:K8:3)
			return This:C1470._encodeStringLiteral($value)
			
		Else 
			return "null"
	End case 
	
	// MARK:- String Utilities
	
	// _encodeStringLiteral - Apply minimal quoting rules
Function _encodeStringLiteral($value : Text) : Text
	If (This:C1470._isSafeUnquoted($value))
		return $value
	End if 
	
	// Needs quoting
	return "\""+This:C1470._escapeString($value)+"\""
	
	// _isSafeUnquoted - Determine if string needs quotes
Function _isSafeUnquoted($value : Text) : Boolean
	// Empty string needs quotes
	If (Length:C16($value)=0)
		return False:C215
	End if 
	
	// Leading/trailing whitespace needs quotes
	If ($value#Trim:C1853($value))
		return False:C215
	End if 
	
	// Boolean/null literals need quotes
	If ($value="true") || ($value="false") || ($value="null")
		return False:C215
	End if 
	
	// Number-like strings need quotes
	If (This:C1470._isNumericLike($value))
		return False:C215
	End if 
	
	// Structural characters need quotes
	If (Position:C15(":"; $value)>0)
		return False:C215
	End if 
	
	If (Position:C15("\""; $value)>0) || (Position:C15("\\"; $value)>0)
		return False:C215
	End if 
	
	If (Match regex:C1019("[\\[\\]{}]"; $value))
		return False:C215
	End if 
	
	// Control characters need quotes
	If (Position:C15(Char:C90(Line feed:K15:40); $value)>0) || (Position:C15(Char:C90(Carriage return:K15:38); $value)>0) || (Position:C15(Char:C90(Tab:K15:37); $value)>0)
		return False:C215
	End if 
	
	// Comma (delimiter) needs quotes
	If (Position:C15(","; $value)>0)
		return False:C215
	End if 
	
	// Starts with hyphen (list marker) needs quotes
	If (Position:C15("-"; $value)=1)
		return False:C215
	End if 
	
	return True:C214
	
	// _isNumericLike - Check if string looks like a number
Function _isNumericLike($value : Text) : Boolean
	// Try to match common number patterns
	// Integers: 42, -42
	// Decimals: 3.14, -3.14
	// Scientific: 1e-6, 1E+6
	// Leading zero: 05 (should be quoted)
	
	// Match decimal number pattern
	If (Match regex:C1019("^-?\\d+(\\.\\d+)?$"; $value))
		return True:C214
	End if 
	
	// Match scientific notation
	If (Match regex:C1019("^-?\\d+(\\.\\d+)?[eE][+-]?\\d+$"; $value))
		return True:C214
	End if 
	
	// Leading zero (except "0" itself)
	If (Length:C16($value)>1) && (Position:C15("0"; $value)=1) && (Position:C15("."; $value)#2)
		If (Match regex:C1019("^0\\d"; $value))
			return True:C214
		End if 
	End if 
	
	return False:C215
	
	// _escapeString - Escape special characters for quoted strings
Function _escapeString($value : Text) : Text
	var $result : Text
	$result:=$value
	
	// Order matters: backslash first
	$result:=Replace string:C233($result; "\\"; "\\\\")
	$result:=Replace string:C233($result; "\""; "\\\"")
	$result:=Replace string:C233($result; Char:C90(Line feed:K15:40); "\\n")
	$result:=Replace string:C233($result; Char:C90(Carriage return:K15:38); "\\r")
	$result:=Replace string:C233($result; Char:C90(Tab:K15:37); "\\t")
	
	return $result
	
	// _encodeKey - Encode object key (quote if necessary)
Function _encodeKey($key : Text) : Text
	If (This:C1470._isValidUnquotedKey($key))
		return $key
	End if 
	
	return "\""+This:C1470._escapeString($key)+"\""
	
	// _isValidUnquotedKey - Check if key can be unquoted
Function _isValidUnquotedKey($key : Text) : Boolean
	If (Length:C16($key)=0)
		return False:C215
	End if 
	
	// First character must be letter or underscore
	var $firstChar : Text
	$firstChar:=Substring:C12($key; 1; 1)
	
	If (Not:C34(Match regex:C1019("[A-Za-z_]"; $firstChar)))
		return False:C215
	End if 
	
	// Rest must be letters, digits, underscores, or dots
	return Match regex:C1019("^[A-Za-z_][A-Za-z0-9_.]*$"; $key)
	
	// MARK:- Array Detection
	
	// _isPrimitive - Check if value is a primitive type
Function _isPrimitive($value : Variant) : Boolean
	If ($value=Null:C1517)
		return True:C214
	End if 
	
	var $type : Integer
	$type:=Value type:C1509($value)
	
	return ($type=Is text:K8:3) || ($type=Is real:K8:4) || ($type=Is longint:K8:6) || ($type=Is boolean:K8:9)
	
	// _isArrayOfPrimitives - Check if collection contains only primitives
Function _isArrayOfPrimitives($coll : Collection) : Boolean
	var $item : Variant
	For each ($item; $coll)
		If (Not:C34(This:C1470._isPrimitive($item)))
			return False:C215
		End if 
	End for each 
	return True:C214
	
	// _isArrayOfObjects - Check if collection contains only objects
Function _isArrayOfObjects($coll : Collection) : Boolean
	var $item : Variant
	For each ($item; $coll)
		If (Value type:C1509($item)#Is object:K8:27)
			return False:C215
		End if 
	End for each 
	return True:C214
	
	// MARK:- Array Encoding - Primitives
	
	// _encodeArrayOfPrimitives - Encode array of primitives as inline comma-separated
Function _encodeArrayOfPrimitives($coll : Collection; $key : Text) : Text
	var $header : Text
	$header:=This:C1470._formatHeader($coll.length; $key; Null:C1517)
	
	If ($coll.length=0)
		return $header
	End if 
	
	var $values : Collection
	$values:=[]
	
	var $item : Variant
	For each ($item; $coll)
		$values.push(This:C1470._encodePrimitive($item))
	End for each 
	
	return $header+" "+$values.join(",")
	
	// MARK:- Array Encoding - Tabular
	
	// _extractTabularHeader - Get field names if array can use tabular format
Function _extractTabularHeader($objects : Collection) : Collection
	If ($objects.length=0)
		return Null:C1517
	End if 
	
	var $firstRow : Object
	$firstRow:=$objects[0]
	
	var $firstKeys : Collection
	$firstKeys:=OB Keys:C1719($firstRow)
	
	If ($firstKeys.length=0)
		return Null:C1517
	End if 
	
	// Check if all rows have same structure
	If (This:C1470._isTabularArray($objects; $firstKeys))
		return $firstKeys
	End if 
	
	return Null:C1517
	
	// _isTabularArray - Validate that all objects have identical keys and primitive values
Function _isTabularArray($objects : Collection; $header : Collection) : Boolean
	var $row : Object
	For each ($row; $objects)
		var $keys : Collection
		$keys:=OB Keys:C1719($row)
		
		// Must have same number of keys
		If ($keys.length#$header.length)
			return False:C215
		End if 
		
		// All header keys must exist with primitive values
		var $key : Text
		For each ($key; $header)
			If (Not:C34(OB Is defined:C1231($row; $key)))
				return False:C215
			End if 
			
			var $value : Variant
			$value:=$row[$key]
			
			// Must be primitive
			If (Not:C34(This:C1470._isPrimitive($value)))
				return False:C215
			End if 
		End for each 
	End for each 
	
	return True:C214
	
	// _encodeArrayOfObjects - Encode uniform object array in tabular format
Function _encodeArrayOfObjects($coll : Collection; $key : Text; $header : Collection; $depth : Integer; $options : Object) : Collection
	var $lines : Collection
	$lines:=[]
	
	// Header line: key[N]{field1,field2,field3}:
	var $headerLine : Text
	$headerLine:=This:C1470._formatHeader($coll.length; $key; $header)
	$lines.push(This:C1470._indentLine($depth; $headerLine; $options.indent))
	
	// Data rows
	var $row : Object
	For each ($row; $coll)
		var $rowValues : Collection
		$rowValues:=[]
		
		var $fieldName : Text
		For each ($fieldName; $header)
			var $fieldValue : Variant
			$fieldValue:=$row[$fieldName]
			$rowValues.push(This:C1470._encodePrimitive($fieldValue))
		End for each 
		
		var $rowLine : Text
		$rowLine:=$rowValues.join(",")
		$lines.push(This:C1470._indentLine($depth+1; $rowLine; $options.indent))
	End for each 
	
	return $lines
	
	// MARK:- Array Encoding - List Format
	
	// _encodeMixedArrayAsListItems - Encode mixed/non-uniform array with list markers
Function _encodeMixedArrayAsListItems($coll : Collection; $key : Text; $depth : Integer; $options : Object) : Collection
	var $lines : Collection
	$lines:=[]
	
	// Header: key[N]:
	var $header : Text
	$header:=This:C1470._formatHeader($coll.length; $key; Null:C1517)
	$lines.push(This:C1470._indentLine($depth; $header; $options.indent))
	
	// Each item with "- " marker
	var $item : Variant
	For each ($item; $coll)
		var $itemType : Integer
		$itemType:=Value type:C1509($item)
		
		Case of 
			: (This:C1470._isPrimitive($item))
				// Primitive item: "- value"
				var $line : Text
				$line:="- "+This:C1470._encodePrimitive($item)
				$lines.push(This:C1470._indentLine($depth+1; $line; $options.indent))
				
			: ($itemType=Is object:K8:27)
				// Object item: "- " followed by indented object properties
				$lines.push(This:C1470._indentLine($depth+1; "- "; $options.indent))
				
				var $objKey : Text
				For each ($objKey; $item)
					var $objValue : Variant
					$objValue:=$item[$objKey]
					
					var $encodedKey : Text
					$encodedKey:=This:C1470._encodeKey($objKey)
					
					If (This:C1470._isPrimitive($objValue))
						// Simple property under list item
						$line:=$encodedKey+": "+This:C1470._encodePrimitive($objValue)
						$lines.push(This:C1470._indentLine($depth+2; $line; $options.indent))
					Else 
						// Nested complex value - recursively encode
						$lines.push(This:C1470._indentLine($depth+2; $encodedKey+":"; $options.indent))
						
						If (Value type:C1509($objValue)=Is object:K8:27)
							var $nestedLines : Collection
							$nestedLines:=This:C1470._encodeObject($objValue; $depth+3; $options)
							var $nestedLine : Text
							For each ($nestedLine; $nestedLines)
								$lines.push($nestedLine)
							End for each 
							Else if(Value type:C1509($objValue)=Is collection:K8:32)
							$nestedLines:=This:C1470._encodeCollection($objValue; ""; $depth+3; $options)
							For each ($nestedLine; $nestedLines)
								$lines.push($nestedLine)
							End for each 
						End if 
					End if 
				End for each 
				
			: ($itemType=Is collection:K8:32)
				// Collection item: "- " followed by collection encoding
				$lines.push(This:C1470._indentLine($depth+1; "- "; $options.indent))
				var $collLines : Collection
				$collLines:=This:C1470._encodeCollection($item; ""; $depth+2; $options)
				var $collLine : Text
				For each ($collLine; $collLines)
					$lines.push($collLine)
				End for each 
				
		End case 
	End for each 
	
	return $lines
	
	// MARK:- Formatting Utilities
	
	// _formatHeader - Build array header: key[N]{fields}:
Function _formatHeader($length : Integer; $key : Text; $fields : Collection) : Text
	var $header : Text
	$header:=""
	
	// Key prefix (if present)
	If (Length:C16($key)>0)
		$header:=This:C1470._encodeKey($key)
	End if 
	
	// Length: [N]
	$header:=$header+"["+String:C10($length)+"]"
	
	// Fields: {field1,field2,field3}
	If ($fields#Null:C1517) && ($fields.length>0)
		var $quotedFields : Collection
		$quotedFields:=[]
		
		var $field : Text
		For each ($field; $fields)
			$quotedFields.push(This:C1470._encodeKey($field))
		End for each 
		
		$header:=$header+"{"+$quotedFields.join(",")+"}"
	End if 
	
	$header:=$header+":"
	
	return $header
	
	// _indentLine - Add indentation prefix to line
Function _indentLine($depth : Integer; $content : Text; $indentSize : Integer) : Text
	var $spaces : Integer
	$spaces:=$depth*$indentSize
	
	If ($spaces=0)
		return $content
	End if 
	
	var $indent : Text
	$indent:=""
	
	var $i : Integer
	For ($i; 1; $spaces)
		$indent:=$indent+" "
	End for 
	
	return $indent+$content
	