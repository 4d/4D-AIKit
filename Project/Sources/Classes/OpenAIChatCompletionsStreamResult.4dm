// Contain the stream data send by server
property data : Object

property _body : Object

property _decodingErrors : Collection

// Errors on SSE packets skipped during the stream, set on the terminate result.
property _streamErrors : Collection

// property _chunks : Collection

Class extends OpenAIResult

// Build stream result with event blob data.
Class constructor($request : 4D:C1709.HTTPRequest; $body : Variant; $terminated : Boolean)
	This:C1470.request:=$request
	This:C1470._terminated:=$terminated
	
	Case of 
		: (Value type:C1509($body)=Is text:K8:3)
			var $textData:=$body
			
			// trim blank lines at the end
			//%W-533.1
			While ((Length:C16($textData)>0) && $textData[[Length:C16($textData)]]="\n")
				//%W+533.1
				$textData:=Substring:C12($textData; 1; Length:C16($textData)-1)
			End while 
			
			If ($terminated)
				This:C1470.data:=This:C1470._parseLastDataLine($textData)  // the last chunk, with the finish reason
			Else 
				This:C1470.data:=This:C1470._parseDataLine($textData)
			End if 
			
		: (Value type:C1509($body)=Is object:K8:27)
			
			// This._terminated:=True
			This:C1470._body:=$body
			
	End case 
	
Function get terminated : Boolean
	return This:C1470._terminated
	
	// Return True if we success to decode the streaming data as object.
Function get success : Boolean
	If (This:C1470.data=Null:C1517)
		return False:C215
	End if 
	If ((This:C1470.request=Null:C1517) || (This:C1470.request.response=Null:C1517))
		return True:C214  // we do not have final state
	End if 
	return (300>This:C1470.request.response.status) && (This:C1470.request.response.status>=200)
	
	// Return errors if we manage to find some. 
Function get errors : Collection
	If ((This:C1470.request#Null:C1517) && (This:C1470.request.errors#Null:C1517) && (This:C1470.request.errors.length>0))
		return This:C1470.request.errors
	End if 
	
	If ((This:C1470.data#Null:C1517) && (This:C1470.data.error#Null:C1517))
		return [This:C1470.data.error]
	End if 
	
	If ((This:C1470.data=Null:C1517) && (This:C1470._decodingErrors#Null:C1517))
		return This:C1470._decodingErrors
	End if 
	
	If ((This:C1470._body#Null:C1517) && (This:C1470._body.error#Null:C1517))
		return [This:C1470._body.error]
	End if 
	
	If ((This:C1470._streamErrors#Null:C1517) && (This:C1470._streamErrors.length>0))
		return This:C1470._streamErrors  // success could be True: data is there but incomplete
	End if 
	
	return []
	
	// Return a choice data, with a delta message.
Function get choice : cs:C1710.OpenAIChoice
	var $body:=This:C1470.data
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.choices)=Is collection:K8:32)))
		return Null:C1517
	End if 
	If ($body.choices.length=0)
		return Null:C1517
	End if 
	
	return cs:C1710.OpenAIChoice.new($body.choices.first())
	
	// Return choices data, with delta messages.
Function get choices : Collection
	var $body:=This:C1470.data
	
	Case of 
		: ($body=Null:C1517)
			return []
		: (Value type:C1509($body.choices)=Is collection:K8:32)
			return $body.choices.map(Formula:C1597(cs:C1710.OpenAIChoice.new($1.value)))
		Else 
			return []
	End case 
	
	// Return the usage data for the second-to-last Stream result. For other it will be null.
Function get usage : Object
	return (This:C1470.data=Null:C1517) ? Null:C1517 : This:C1470.data.usage
	
	// Return the last data packet of a complete event stream body.
Function _parseLastDataLine($textData : Text) : Object
	
	// SSE allows CRLF, LF and bare CR as line separator, normalize before framing.
	// Framing on the "data: " text instead would cut a chunk whose content holds it.
	$textData:=Replace string:C233($textData; Char:C90(Carriage return:K15:38)+Char:C90(Line feed:K15:40); Char:C90(Line feed:K15:40))
	$textData:=Replace string:C233($textData; Char:C90(Carriage return:K15:38); Char:C90(Line feed:K15:40))
	
	var $lines : Collection:=Split string:C1554($textData; Char:C90(Line feed:K15:40))
	var $index : Integer
	For ($index; $lines.length-1; 0; -1)
		
		// the last data field holding a json object: this skips the blank lines, the other
		// fields, the "[DONE]" marker, the ": ping" comments and the "data: : ping" of some
		// local servers (Qwen, MLX), whatever the optional space after the field name.
		If ((Position:C15("data:"; $lines[$index])=1) && (Position:C15("{"; $lines[$index])>0))
			return This:C1470._parseDataLine($lines[$index])  // could have errors
		End if 
	End for 
	
	return This:C1470._parseDataLine($textData)  // not an event stream: a json body, ie. an error
	
Function _parseDataLine($textData : Text) : Object
	var $pos:=Position:C15("{"; $textData)
	If ($pos>0)
		$textData:=Substring:C12($textData; $pos)  // ie. remove "data: before json line", XXX: maybe just check data: 
	End if 
	
	var $parsed : Variant:=Try(JSON Parse:C1218($textData))
	var $errors : Collection:=Last errors:C1799
	
	// JSON Parse accepts a trailing garbage, "1}" is parsed as the number 1,
	// so a truncated packet can be decoded without any error. A chunk is always an object.
	If ((Value type:C1509($parsed)#Is object:K8:27) && ($errors=Null:C1517))
		$errors:=[{message: "Unexpected stream data, an object was expected: "+$textData}]
	End if 
	
	If ($errors#Null:C1517)
		If (This:C1470._decodingErrors=Null:C1517)
			This:C1470._decodingErrors:=$errors
		Else 
			This:C1470._decodingErrors.combine($errors)
		End if 
		return Null:C1517
	End if 
	
	return $parsed