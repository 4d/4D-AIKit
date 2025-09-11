// MARK:- execution params

// Function to call asynchronously when finished. /!\ Be sure your current process not die.
property onTerminate : 4D:C1709.Function

// Function to call asynchronously when finished with success. /!\ Be sure your current process not die.
property onResponse : 4D:C1709.Function

// Function to call asynchronously when finished with errors. /!\ Be sure your current process not die.
property onError : 4D:C1709.Function

// replace This object when calling formula
property _formulaThis : Object

// If error occurs, throw it.
property throw : Boolean:=False:C215

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
	
Function get formula : 4D:C1709.Function
	return This:C1470.onTerminate
	
Function set formula($new : 4D:C1709.Function) : 4D:C1709.Function
	This:C1470.onTerminate:=$new
	
Function _isAsync() : Boolean
	return ((This:C1470.formula#Null:C1517) && (OB Instance of:C1731(This:C1470.formula; 4D:C1709.Function)))\
		 || ((This:C1470.onResponse#Null:C1517) && (OB Instance of:C1731(This:C1470.onResponse; 4D:C1709.Function)))\
		 || ((This:C1470.onError#Null:C1517) && (OB Instance of:C1731(This:C1470.onError; 4D:C1709.Function)))