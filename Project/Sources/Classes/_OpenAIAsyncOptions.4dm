
property method : Text
property headers : Object
property dataType : Text
property body : Variant
property timeout : Integer
property decodeData : Boolean

property _parameters : Object
property _result : cs:C1710.OpenAIResult
property _onStreamError : Boolean:=False:C215

property _chunkBuffer : Text:=""
property _sseEvent : Object

// MARK:- constructor
Class constructor($options : Object; $client : cs:C1710.OpenAI; $parameters : Object; $result : cs:C1710.OpenAIResult)
	var $key : Text
	For each ($key; $options)
		This:C1470[$key]:=$options[$key]
	End for each 
	
	This:C1470._parameters:=$parameters
	This:C1470._result:=$result
	If (Bool:C1537(This:C1470._parameters.stream))
		This:C1470.dataType:="text"
		This:C1470.decodeData:=True:C214
	End if 
	
	
	// MARK:- HTTP callback
Function onTerminate($request : 4D:C1709.HTTPRequest; $event : Object)
	If (Bool:C1537(This:C1470._parameters.stream))
		var $result : Object
		If (This:C1470._isResponsesStream())
			Case of 
				: (Value type:C1509($request.response.body)=Is text:K8:3)
					var $lastEvent:=This:C1470._parseLastSSEEvent($request.response.body)
					$result:=This:C1470._buildStreamResult($request; $lastEvent.event; $lastEvent.data; True:C214)
				: (Value type:C1509($request.response.body)=Is object:K8:27)
					$result:=This:C1470._buildStreamResult($request; ""; $request.response.body; True:C214)
				Else 
					$result:=This:C1470._buildStreamResult($request; ""; $request.response.body; True:C214)
			End case 
		Else 
			$result:=cs:C1710.OpenAIChatCompletionsStreamResult.new($request; $request.response.body; True:C214)
		End if 
		_openAICallbacks(This:C1470._parameters; $result)
	Else 
		This:C1470._result._terminated:=True:C214  // force terminated because onTerminate is before onTerminated
		_openAICallbacks(This:C1470._parameters; This:C1470._result)
	End if 
	
Function onData($request : 4D:C1709.HTTPRequest; $event : Object)
	// $event: {chunk: true; type: "data"; data: blob}
	
	If ((This:C1470._parameters.onData=Null:C1517) && (This:C1470._parameters.formula=Null:C1517))
		return   // no callback no notify
	End if 
	
	If (Not:C34(Bool:C1537(This:C1470._parameters.stream)) || (This:C1470._onStreamError))
		return   // if no stream, we do not manage it, and stop also if previous packet error
	End if 
	
	var $textData:=BLOB to text:C555($event.data; UTF8 C string:K22:15)
	
	$textData:=This:C1470._chunkBuffer+$textData
	This:C1470._chunkBuffer:=""
	
	var $lines:=Split string:C1554($textData; "\n")
	If (($lines.length>0) && ($textData#"\n"))
		This:C1470._chunkBuffer:=$lines.pop()
	End if 
	
	If (This:C1470._sseEvent=Null:C1517)
		This:C1470._sseEvent:={event: ""; data: ""}
	End if 
	
	var $lineIndex : Integer
	For ($lineIndex; 0; $lines.length-1)
		
		var $line : Text:=$lines[$lineIndex]
		If ((Length:C16($line)>0) && ($line[[Length:C16($line)]]="\r"))
			$line:=Substring:C12($line; 1; Length:C16($line)-1)
		End if 
		If (Length:C16($line)=0)
			// End of one SSE event
			If (Length:C16(This:C1470._sseEvent.data)>0)
				If (This:C1470._sseEvent.data#"[DONE]")
					var $chunkResult:=This:C1470._buildStreamResult($request; This:C1470._sseEvent.event; This:C1470._sseEvent.data; False:C215)
					If (This:C1470._parameters.onData#Null:C1517)
						This:C1470._parameters.onData.call(This:C1470._parameters._formulaThis; $chunkResult)
					End if 
					If (This:C1470._parameters.formula#Null:C1517)
						This:C1470._parameters.formula.call(This:C1470._parameters._formulaThis; $chunkResult)
					End if 
				End if 
			End if 
			
			This:C1470._sseEvent:={event: ""; data: ""}
			continue
		End if 
		
		If (Position:C15("event: "; $line)=1)
			This:C1470._sseEvent.event:=Substring:C12($line; Length:C16("event: ")+1)
			continue
		End if 
		If (Position:C15("data: "; $line)=1)
			var $dataLine:=Substring:C12($line; Length:C16("data: ")+1)
			If (Length:C16(This:C1470._sseEvent.data)>0)
				This:C1470._sseEvent.data:=This:C1470._sseEvent.data+"\n"+$dataLine
			Else 
				This:C1470._sseEvent.data:=$dataLine
			End if 
			continue
		End if 
		
	End for 

Function _isResponsesStream : Boolean
	return (OB Instance of:C1731(This:C1470._parameters; cs:C1710.OpenAIResponsesParameters))

Function _buildStreamResult($request : 4D:C1709.HTTPRequest; $eventName : Text; $dataText : Text; $terminated : Boolean) : Object
	If (This:C1470._isResponsesStream())
		return cs:C1710.OpenAIResponsesStreamResult.new($request; $eventName; $dataText; $terminated)
	End if 
	return cs:C1710.OpenAIChatCompletionsStreamResult.new($request; "data: "+$dataText; $terminated)

Function _parseLastSSEEvent($textData : Text) : Object
	var $last:={event: ""; data: ""}
	var $current:={event: ""; data: ""}
	
	var $lines:=Split string:C1554($textData; "\n")
	var $lineIndex : Integer
	For ($lineIndex; 0; $lines.length-1)
		var $line : Text:=$lines[$lineIndex]
		If ((Length:C16($line)>0) && ($line[[Length:C16($line)]]="\r"))
			$line:=Substring:C12($line; 1; Length:C16($line)-1)
		End if 
		If (Length:C16($line)=0)
			If ((Length:C16($current.data)>0) && ($current.data#"[DONE]"))
				$last:=$current
			End if 
			$current:={event: ""; data: ""}
			continue
		End if 
		
		If (Position:C15("event: "; $line)=1)
			$current.event:=Substring:C12($line; Length:C16("event: ")+1)
			continue
		End if 
		If (Position:C15("data: "; $line)=1)
			var $dataLine:=Substring:C12($line; Length:C16("data: ")+1)
			If (Length:C16($current.data)>0)
				$current.data:=$current.data+"\n"+$dataLine
			Else 
				$current.data:=$dataLine
			End if 
			continue
		End if 
	End for 
	
	If ((Length:C16($current.data)>0) && ($current.data#"[DONE]"))
		$last:=$current
	End if 
	
	return $last
	
	
