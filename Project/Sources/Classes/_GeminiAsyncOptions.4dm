
property method : Text
property headers : Object
property dataType : Text
property body : Variant
property timeout : Integer

property _parameters : cs:C1710.GeminiParameters
property _result : cs:C1710.GeminiResult

// MARK:- constructor
Class constructor($options : Object; $client : cs:C1710.Gemini; $parameters : cs:C1710.GeminiParameters; $result : cs:C1710.GeminiResult)
	var $key : Text
	For each ($key; $options)
		This:C1470[$key]:=$options[$key]
	End for each

	This:C1470._parameters:=$parameters
	This:C1470._result:=$result


	// MARK:- HTTP callback
Function onTerminate($request : 4D:C1709.HTTPRequest; $event : Object)
	This:C1470._result._terminated:=True:C214  // force terminated because onTerminate is before onTerminated
	_geminiCallbacks(This:C1470._parameters; This:C1470._result)

