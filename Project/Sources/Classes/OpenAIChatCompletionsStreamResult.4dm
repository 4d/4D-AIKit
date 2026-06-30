// Contain the stream data send by server
property data : Object

// Loop-level stop reason set by the agent loop (OpenAIChatHelper), e.g. "max_iterations"
// or "cancelled". Empty means: derive stopReason from the response itself.
property _stopReason : Text

property _body : Object

property _decodingErrors : Collection

// property _chunks : Collection

Class extends OpenAIResult

// Why the response stopped. An explicit reason set by the agent loop wins; otherwise it is
// derived from the response: the choice finish_reason verbatim ("stop", "length", "tool_calls",
// "content_filter", ...), "error" if the request failed, or "" if not terminated yet.
Function get stopReason : Text
	If (Length:C16(String:C10(This:C1470._stopReason))>0)
		return This:C1470._stopReason
	End if
	If (Not:C34(This:C1470.success))
		return "error"
	End if
	var $choice : cs:C1710.OpenAIChoice:=This:C1470.choice
	If (($choice#Null:C1517) && (Length:C16(String:C10($choice.finish_reason))>0))
		return String:C10($choice.finish_reason)
	End if
	return ""

Function set stopReason($value : Text)
	This:C1470._stopReason:=$value

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
				var $lines:=Split string:C1554($textData; "data: ")
				var $done : Text:=$lines.pop()
				If ($done="[DONE]")
					This:C1470.data:=This:C1470._parseDataLine($lines.last())  // send last chunk with finish reason
					
					// This._chunks:=$lines.filter(Formula(Length($1.value)>0)).map(Formula(Try($2._parseDataLine($1.value))); This)
					
				Else 
					This:C1470.data:=This:C1470._parseDataLine($done)  // could have have errors
				End if 
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
	If ((This:C1470.request.errors#Null:C1517) && (This:C1470.request.errors.length>0))
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
	
Function _parseDataLine($textData : Text) : Object
	var $pos:=Position:C15("{"; $textData)
	If ($pos>0)
		$textData:=Substring:C12($textData; $pos)  // ie. remove "data: before json line", XXX: maybe just check data: 
	End if 
	
	var $data:=Try(JSON Parse:C1218($textData))
	If ($data=Null:C1517)
		If (This:C1470._decodingErrors=Null:C1517)
			This:C1470._decodingErrors:=Last errors:C1799
		Else 
			This:C1470._decodingErrors.combine(Last errors:C1799)
		End if 
	End if 
	return $data