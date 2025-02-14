
// timeout: Override the client-level default timeout for this request, in seconds
// extraHeaders: Send extra headers
// extraQuery: Add additional query parameters to the request
// user: A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.

Class constructor($object : Object)
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 
	
Function body() : Object
	var $body:={}
	
	return $body