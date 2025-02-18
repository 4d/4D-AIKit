
property method : Text
property headers : Object
property dataType : Text
property body : Variant
property timeout : Integer

property client : cs:C1710.OpenAI
property parameters : cs:C1710.OpenAIChatCompletionParameters
property result : cs:C1710.OpenAIResult

// MARK:- constructor
Class constructor($options : Object; $client : cs:C1710.OpenAI; $parameters : cs:C1710.OpenAIChatCompletionParameters; $result : cs:C1710.OpenAIResult)
	
	var $key : Text
	For each ($key; $options)
		This:C1470[$key]:=$options[$key]
	End for each 
	
	This:C1470.client:=$client
	This:C1470.parameters:=$parameters
	This:C1470.result:=$result
	
	// MARK:- HTTP callback
Function onTerminate($request : 4D:C1709.HTTPRequest; $event : Object)
	If (This:C1470.parameters.formula#Null:C1517)
		This:C1470.parameters.formula.call(This:C1470.parameters._formulaThis || This:C1470.client; This:C1470.result)
	End if 
	
Function onData($request : 4D:C1709.HTTPRequest; $event : Object)
	// $event: {chunk: true; type: "data"; data: blob}
	If ((This:C1470.parameters.formula#Null:C1517) && (Bool:C1537(This:C1470.parameters.stream)))
		var $chunkResult:=cs:C1710.OpenAIChatCompletionsStreamResult.new($request; $event.data)
		This:C1470.parameters.formula.call(This:C1470.parameters._formulaThis || This:C1470.client; $chunkResult)
	End if 