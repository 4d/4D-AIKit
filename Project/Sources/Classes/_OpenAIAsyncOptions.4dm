
property method : Text
property headers : Object
property dataType : Text
property body : Variant
property timeout : Integer
property decodeData : Boolean

property _parameters : cs:C1710.OpenAIChatCompletionsParameters
property _result : cs:C1710.OpenAIResult
property _onStreamError : Boolean:=False:C215

// Incomplete trailing SSE line, waiting for the rest of the stream.
property _chunkBuffer : Text:=""
// SSE packets we could not decode. Reported on the terminate result, see `errors`.
property _streamErrors : Collection

// MARK:- constructor
Class constructor($options : Object; $client : cs:C1710.OpenAI; $parameters : cs:C1710.OpenAIChatCompletionsParameters; $result : cs:C1710.OpenAIResult)
	var $key : Text
	For each ($key; $options)
		This:C1470[$key]:=$options[$key]
	End for each 
	
	This:C1470._parameters:=$parameters
	This:C1470._result:=$result
	This:C1470._streamErrors:=[]
	If (Bool:C1537(This:C1470._parameters.stream))
		This:C1470.dataType:="text"
		This:C1470.decodeData:=True:C214
	End if 
	
	
	// MARK:- HTTP callback
Function onTerminate($request : 4D:C1709.HTTPRequest; $event : Object)
	If (Bool:C1537(This:C1470._parameters.stream))
		
		// the last packet could arrive without its terminating line feed, do not lose it
		If (Length:C16(This:C1470._chunkBuffer)>0)
			var $pending : Text:=This:C1470._chunkBuffer
			This:C1470._chunkBuffer:=""
			This:C1470._handleSSELine($request; $pending)
		End if 
		
		var $result:=cs:C1710.OpenAIChatCompletionsStreamResult.new($request; $request.response.body; True:C214)
		If (This:C1470._streamErrors.length>0)
			$result._streamErrors:=This:C1470._streamErrors  // some packets were skipped, data could be incomplete
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
	
	// TODO: ignore if not sse_event.object == "chat.completion.chunk" 
	
	var $textData:=BLOB to text:C555($event.data; UTF8 C string:K22:15)
	
	$textData:=This:C1470._chunkBuffer+$textData
	This:C1470._chunkBuffer:=""
	
	If (Position:C15("{"; $textData)=1)
		This:C1470._onStreamError:=True:C214
		// not an event stream but a json error body, ignore chunk, will be for onTerminate
		return 
	End if 
	
	// SSE allows CRLF, LF and bare CR as line separator, normalize before framing.
	// A raw CR or LF cannot appear inside a json string, it must be escaped, so this is safe.
	$textData:=Replace string:C233($textData; Char:C90(Carriage return:K15:38)+Char:C90(Line feed:K15:40); Char:C90(Line feed:K15:40))
	$textData:=Replace string:C233($textData; Char:C90(Carriage return:K15:38); Char:C90(Line feed:K15:40))
	
	var $lines:=Split string:C1554($textData; "\n")
	
	// only a line feed terminates a line: the trailing segment is always incomplete, keep it for the next read.
	// (it is an empty text when the read did end on a line feed)
	This:C1470._chunkBuffer:=$lines.pop()
	
	var $line : Text
	For each ($line; $lines)
		If (Not:C34(This:C1470._handleSSELine($request; $line)))
			This:C1470._chunkBuffer:=""  // stream is done, nothing to keep
			break 
		End if 
	End for each 
	
	// MARK:- SSE
	// Handle one complete SSE line, notifying the callbacks if it holds a decodable data packet.
	// Return False if the stream is terminated by a [DONE] packet.
Function _handleSSELine($request : 4D:C1709.HTTPRequest; $line : Text) : Boolean
	
	If (Length:C16($line)=0)
		return True:C214  // event boundary
	End if 
	If (Position:C15(":"; $line)=1)
		return True:C214  // comment line, used as keep alive by some providers
	End if 
	If (Position:C15("data:"; $line)#1)
		return True:C214  // other field: event, id, retry, or unknown
	End if 
	
	var $payload : Text:=Substring:C12($line; 6)
	If (Position:C15(" "; $payload)=1)
		$payload:=Substring:C12($payload; 2)  // one optional space after the field name
	End if 
	
	If (Length:C16($payload)=0)
		return True:C214  // empty data field
	End if 
	If ($payload="[DONE]")
		return False:C215
	End if 
	
	var $chunkResult:=cs:C1710.OpenAIChatCompletionsStreamResult.new($request; $payload; False:C215)
	If (($chunkResult._decodingErrors#Null:C1517) && ($chunkResult._decodingErrors.length>0))
		// a complete data packet we cannot decode: keep the stream alive but remember it
		This:C1470._streamErrors.combine($chunkResult._decodingErrors)
		return True:C214
	End if 
	
	If (This:C1470._parameters.onData#Null:C1517)
		This:C1470._parameters.onData.call(This:C1470._parameters._formulaThis; $chunkResult)
	End if 
	If (This:C1470._parameters.formula#Null:C1517)
		This:C1470._parameters.formula.call(This:C1470._parameters._formulaThis; $chunkResult)
	End if 
	
	return True:C214
