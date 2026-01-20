
property method : Text
property headers : Object
property dataType : Text
property body : Variant
property timeout : Integer
property decodeData : Boolean

property _parameters : cs:C1710.OpenAIChatCompletionsParameters
property _result : cs:C1710.OpenAIResult
property _onStreamError : Boolean:=False:C215
property _eventStreamBuffer : 4D:C1709.Blob

// MARK:- constructor
Class constructor($options : Object; $client : cs:C1710.OpenAI; $parameters : cs:C1710.OpenAIChatCompletionsParameters; $result : cs:C1710.OpenAIResult)
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
		var $result:=cs:C1710.OpenAIChatCompletionsStreamResult.new($request; $request.response.body; True:C214)
		_openAICallbacks(This:C1470._parameters; $result)
	Else 
		This:C1470._result._terminated:=True:C214  // force terminated because onTerminate is before onTerminated
		_openAICallbacks(This:C1470._parameters; This:C1470._result)
	End if 
	
Function onData($request : 4D:C1709.HTTPRequest; $event : Object)
	// $event: {chunk: true; type: "data"; data: blob}
	
	If (This:C1470._eventStreamBuffer=Null:C1517)
		This:C1470._eventStreamBuffer:=4D:C1709.Blob.new($event.data)
	Else 
		var $eventStreamBuffer : Blob
		$eventStreamBuffer:=This:C1470._eventStreamBuffer
		COPY BLOB:C558($event.data; $eventStreamBuffer; 0; BLOB size:C605($eventStreamBuffer); $event.data.size)
		This:C1470._eventStreamBuffer:=$eventStreamBuffer
	End if 
	
	If ((This:C1470._parameters.onData=Null:C1517) && (This:C1470._parameters.formula=Null:C1517))
		return   // no callback no notify
	End if 
	
	If (Not:C34(Bool:C1537(This:C1470._parameters.stream)) || (This:C1470._onStreamError))
		return   // if no stream, we do not manage it, and stop also if previous packet error
	End if 
	
	// TODO: ignore if not sse_event.object == "chat.completion.chunk" 
	
	var $textData:=Convert to text:C1012(This:C1470._eventStreamBuffer; "utf-8")
	var $lines:=Split string:C1554($textData; "\n")
	
	var $lineIndex : Integer
	For ($lineIndex; 0; $lines.length-1)
		
		var $line : Text:=$lines[$lineIndex]
		If ((Length:C16($line)=0))
			continue
		End if 
		If ($line="data: [DONE]")
			break
		End if 
		
		var $chunkResult:=cs:C1710.OpenAIChatCompletionsStreamResult.new($request; $line; False:C215)
		If ($chunkResult._decodingErrors=Null:C1517)
			This:C1470._eventStreamBuffer:=4D:C1709.Blob.new()
		Else 
			continue
		End if 
		
		If (This:C1470._parameters.onData#Null:C1517)
			This:C1470._parameters.onData.call(This:C1470._parameters._formulaThis; $chunkResult)
		End if 
		If (This:C1470._parameters.formula#Null:C1517)
			This:C1470._parameters.formula.call(This:C1470._parameters._formulaThis; $chunkResult)
		End if 
		
	End for 
	
	