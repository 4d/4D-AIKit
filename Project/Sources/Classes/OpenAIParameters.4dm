
// timeout: Override the client-level default timeout for this request, in seconds
// extraHeaders: Send extra headers
// extraQuery: Add additional query parameters to the request
property user : Text  // A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.

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