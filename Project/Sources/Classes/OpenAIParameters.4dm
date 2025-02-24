// MARK:- execution params

// Function to call asynchronously when finished. /!\ Be sure your current process not die.
property formula : 4D:C1709.Function

// Optional worker/process to use to execute the HTTP request if a "formula" is defined. If used no result object is returned.
property _worker : Variant/*workerRef=Text, Longint*/

// Optional worker/process to use to execute the "formula" after executing HTTP request. Be sure process remain.
property _formulaWorker : Variant/*workerRef=Text, Longint*/

// Optional window to use to execute the "formula" after executing HTTP request.
property _formulaWindow : Integer/*winRef*/

// replace This object when calling formula
property _formulaThis : Object

// MARK:- request params

// Override the client-level default timeout for this request, in seconds.
property timeout : Real:=0
// Override the client-level default httpAgent for this request.
property httpAgent : 4D:C1709.HTTPAgent:=Null:C1517

property maxRetries:=0

// Send extra headers
property extraHeaders : Object
// Add additional query parameters to the request
// property extraQuery: Object

// MARK:- body params

// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
property user : Text

// MARK:- constructor
Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 
	This:C1470._formulaThis:=$object
	
Function body() : Object
	var $body:={}
	
	If (Length:C16(String:C10(This:C1470.user))>0)
		$body.user:=This:C1470.user
	End if 
	
	return {}