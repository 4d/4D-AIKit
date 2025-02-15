// MARK:- execution params

// Function to call asynchronously when finished
property formula : 4D:C1709.Function
// Optional worker name to use if a formula is defined
property worker : Variant/*workerRef=Text, Longint*/

// MARK:- request params

// Override the client-level default timeout for this request, in seconds
property timeout : Real:=0

// Send extra headers
// property extraHeaders: Object
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
	
Function body() : Object
	var $body:={}
	
	If (Length:C16(String:C10(This:C1470.user))>0)
		$body.user:=This:C1470.user
	End if 
	
	return {}