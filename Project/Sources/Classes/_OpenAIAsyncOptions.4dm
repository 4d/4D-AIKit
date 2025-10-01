
property method : Text
property headers : Object
property dataType : Text
property body : Variant
property timeout : Integer

property _client : cs:C1710.OpenAI
property _parameters : cs:C1710.OpenAIChatCompletionsParameters
property _result : cs:C1710.OpenAIResult
property _onStreamError : Boolean:=False:C215

property _chunkBuffer : Text:=""

// MARK:- constructor
Class constructor($options : Object; $client : cs:C1710.OpenAI; $parameters : cs:C1710.OpenAIChatCompletionsParameters; $result : cs:C1710.OpenAIResult)
	var $key : Text
	For each ($key; $options)
		This:C1470[$key]:=$options[$key]
	End for each 
	
	If (Bool:C1537(This:C1470._parameters.stream))
		This:C1470.dataType:="text"
	End if 
	
	This:C1470._client:=$client
	This:C1470._parameters:=$parameters
	This:C1470._result:=$result
	
	
	// MARK:- HTTP callback
Function onTerminate($request : 4D:C1709.HTTPRequest; $event : Object)
	If (Bool:C1537(This:C1470._parameters.stream))
		var $result:=cs:C1710.OpenAIChatCompletionsStreamResult.new($request; $request.response.body; True:C214)
		_openAICallbacks(This:C1470._parameters; $result; This:C1470._client)
	Else 
		This:C1470._result._terminated:=True:C214  // force terminated because onTerminate is before onTerminated
		_openAICallbacks(This:C1470._parameters; This:C1470._result; This:C1470._client)
	End if 
	
Function onData($request : 4D:C1709.HTTPRequest; $event : Object)
	// $event: {chunk: true; type: "data"; data: blob}
	
	If ((This:C1470._parameters.onData=Null:C1517) && (This:C1470._parameters.formula=Null:C1517))
		return   // no callback no notify
	End if 
	
	If (Not:C34(Bool:C1537(This:C1470._parameters.stream)) || (This:C1470._onStreamError))
		return   // if no stream, we do not manage it, and stop also if previous packet error
	End if 
	
	// TODO: ignore if not sse_event.object == "chat.completion.chunk" 
	
	var $textData:=BLOB to text:C555($event.data; UTF8 C string:K22:15)
	
	$textData:=This:C1470._chunkBuffer+$textData
	This:C1470._chunkBuffer:=""
	
	If (Position:C15("{"; $textData)=1)
		This:C1470._onStreamError:=True:C214
		// ignore chunk, will be for onTerminate
		return 
	End if 
	
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
		If (($chunkResult._decodingErrors#Null:C1517) && ($chunkResult._decodingErrors.length>0) && (Position:C15("data:"; $line)>0) && ($lineIndex=($lines.length-1)))
			// if we cannot decode last line, we suppose packet not complete, keep in buffer for next line
			// to do better, maybe analyse brackets etc...
			This:C1470._chunkBuffer:=$line
			continue
		End if 
		
		If (This:C1470._parameters.onData#Null:C1517)
			This:C1470._parameters.onData.call(This:C1470._parameters._formulaThis || This:C1470._client; $chunkResult)
		End if 
		If (This:C1470._parameters.formula#Null:C1517)
			This:C1470._parameters.formula.call(This:C1470._parameters._formulaThis || This:C1470._client; $chunkResult)
		End if 
		
		If (($chunkResult._decodingErrors#Null:C1517) && (Position:C15("data: "; $line)<=0))  // XXX: maybe skip before and even do not try to decode invalid SSE packet
			This:C1470._onStreamError:=True:C214
			break  // ignore next 
		End if 
		
	End for 
	
	