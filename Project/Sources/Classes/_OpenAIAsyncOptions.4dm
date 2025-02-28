
property method : Text
property headers : Object
property dataType : Text
property body : Variant
property timeout : Integer

property _client : cs:C1710.OpenAI
property _parameters : cs:C1710.OpenAIChatCompletionsParameters
property _result : cs:C1710.OpenAIResult

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
		var $result:=cs:C1710.OpenAIChatCompletionsStreamResult.new($request; $request.response.body)
		$result._terminated:=True:C214
		_openAICallbacks(This:C1470._parameters; $result; This:C1470._client)
	Else 
		This:C1470._result._terminated:=True:C214  // force terminated because onTerminate is before onTerminated
		_openAICallbacks(This:C1470._parameters; This:C1470._result; This:C1470._client)
	End if 
	
Function onData($request : 4D:C1709.HTTPRequest; $event : Object)
	// $event: {chunk: true; type: "data"; data: blob}
	If (((This:C1470._parameters.onData#Null:C1517) || (This:C1470._parameters.formula#Null:C1517)) && (Bool:C1537(This:C1470._parameters.stream)))
		
		var $textData:=BLOB to text:C555($event.data; UTF8 C string:K22:15)
		var $line : Text
		For each ($line; Split string:C1554($textData; "\n"))
			If ((Length:C16($line)=0))
				continue
			End if 
			If ($line="data: [DONE]")
				continue  // XXX: maybe use that to replace terminated event?
			End if 
			
			var $chunkResult:=cs:C1710.OpenAIChatCompletionsStreamResult.new($request; $line)
			
			var $formula:=(This:C1470._parameters.onData=Null:C1517) ? This:C1470._parameters.onData : This:C1470._parameters.formula
			$formula.call(This:C1470._parameters._formulaThis || This:C1470._client; $chunkResult)
			
		End for each 
		
	End if 
	