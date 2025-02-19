
property method : Text
property headers : Object
property dataType : Text
property body : Variant
property timeout : Integer

property _client : cs:C1710.OpenAI
property _parameters : cs:C1710.OpenAIChatCompletionParameters
property _result : cs:C1710.OpenAIResult

// MARK:- constructor
Class constructor($options : Object; $client : cs:C1710.OpenAI; $parameters : cs:C1710.OpenAIChatCompletionParameters; $result : cs:C1710.OpenAIResult)
	var $key : Text
	For each ($key; $options)
		This:C1470[$key]:=$options[$key]
	End for each 
	
	If (Bool:C1537(This:C1470._parameters.stream))
		This:C1470.dataType:="blob"
	End if 
	
	This:C1470._client:=$client
	This:C1470._parameters:=$parameters
	This:C1470._result:=$result
	
	
	// MARK:- HTTP callback
Function onTerminate($request : 4D:C1709.HTTPRequest; $event : Object)
	If (This:C1470._parameters.formula#Null:C1517)
		If (Bool:C1537(This:C1470._parameters.stream))
			var $result:=cs:C1710.OpenAIChatCompletionsStreamResult.new($request; $request.response.body)
			$result.terminated:=True:C214
			This:C1470._parameters.formula.call(This:C1470._parameters._formulaThis || This:C1470._client; $result)
		Else 
			This:C1470._parameters.formula.call(This:C1470._parameters._formulaThis || This:C1470._client; This:C1470._result)
		End if 
	End if 
	
Function onData($request : 4D:C1709.HTTPRequest; $event : Object)
	// $event: {chunk: true; type: "data"; data: blob}
	If ((This:C1470._parameters.formula#Null:C1517) && (Bool:C1537(This:C1470._parameters.stream)))
		var $result:=cs:C1710.OpenAIChatCompletionsStreamResult.new($request; $event.data)
		This:C1470._parameters.formula.call(This:C1470._parameters._formulaThis || This:C1470._client; $result)
	End if 