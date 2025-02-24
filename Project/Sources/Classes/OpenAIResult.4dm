// The HTTP request used
property request : 4D:C1709.HTTPRequest

// Cache if parsed response
property _parsed : Object

// to force terminated
property _terminated : Boolean

// True if success ie. response receive and no API errors.
Function get success : Boolean
	If (This:C1470.request.response=Null:C1517)
		return False:C215
	End if 
	return (300>This:C1470.request.response.status) && (This:C1470.request.response.status>=200)
	
	// True if the requested is terminated
Function get terminated : Boolean
	return This:C1470.request.terminated || This:C1470._terminated
	
Function _objectBody() : Object
	If (This:C1470._parsed#Null:C1517)
		return This:C1470._parsed
	End if 
	Case of 
		: (This:C1470.request.response.body=Null:C1517)
			return Null:C1517
		: (Value type:C1509(This:C1470.request.response.body)=Is object:K8:27)
			return This:C1470.request.response.body
		: (Value type:C1509(This:C1470.request.response.body)=Is text:K8:3)  // sometime not decoded, maybe some errors do not return content type
			var $parsed:=Try(JSON Parse:C1218(This:C1470.request.response.body))
			If (Value type:C1509($parsed)=Is object:K8:27)
				This:C1470._parsed:=$parsed
				return $parsed
			End if 
	End case 
	
	// List of errors if any
Function get errors : Collection
	
	If ((This:C1470.request.errors#Null:C1517) && (This:C1470.request.errors.length>0))
		return This:C1470.request.errors
	End if 
	
	If ((This:C1470.request.response#Null:C1517) && (Value type:C1509(This:C1470.request.response.body)=Is object:K8:27))
		var $body:=This:C1470._objectBody()
		If ($body.error#Null:C1517)
			return [$body.error]
		End if 
	End if 
	
	If ((This:C1470.request.response#Null:C1517) && (This:C1470.request.response.status>=300))
		return [{code: This:C1470.request.response.status; message: This:C1470.request.response.statusText}]
	End if 
	
	return []
	
	// The response headers
Function get headers : Object
	If (This:C1470.request.response=Null:C1517)
		return Null:C1517
	End if 
	return This:C1470.request.response.headers
	
	// RateLimit information
	// https://platform.openai.com/docs/guides/rate-limits
Function get rateLimit : Object
	If (This:C1470.headers=Null:C1517)
		return Null:C1517
	End if 
	// https://platform.openai.com/docs/guides/rate-limits#rate-limits-in-headers
	return {limit: {request: (This:C1470.headers["x-ratelimit-limit-requests"]#Null:C1517) ? Num:C11(This:C1470.headers["x-ratelimit-limit-requests"]) : Null:C1517; \
		tokens: (This:C1470.headers["x-ratelimit-limit-tokens"]#Null:C1517) ? Num:C11(This:C1470.headers["x-ratelimit-limit-tokens"]) : Null:C1517}; \
		remaining: {request: (This:C1470.headers["x-ratelimit-remaining-requests"]#Null:C1517) ? Num:C11(This:C1470.headers["x-ratelimit-remaining-requests"]) : Null:C1517; \
		tokens: (This:C1470.headers["x-ratelimit-remaining-tokens"]#Null:C1517) ? Num:C11(This:C1470.headers["x-ratelimit-remaining-tokens"]) : Null:C1517}; \
		reset: {request: This:C1470.headers["x-ratelimit-reset-requests"]; tokens: This:C1470.headers["x-ratelimit-reset-tokens"]}}
	
Function get usage : Object
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if 
	return $body.usage
	
Function _shouldRetry() : Boolean
	If (This:C1470.request.response=Null:C1517)
		return False:C215
	End if 
	
	If ((This:C1470.headers#Null:C1517) && This:C1470.headers["x-should-retry"])
		return This:C1470.headers["x-should-retry"]="true"  // XXX could check if false
	End if 
	
	return ((This:C1470.request.response.status=408) || (This:C1470.request.response.status=409) || (This:C1470.request.response.status=429) || (This:C1470.request.response.status>=500))
	
Function _retryAfterValue : Integer
	If (This:C1470.headers=Null:C1517)
		return 0
	End if 
	
	If (This:C1470.headers["retry-after-ms"]#Null:C1517)
		return Num:C11(This:C1470.headers["retry-after-ms"])/1000
	End if 
	
	If (This:C1470.headers["retry-after"]=Null:C1517)
		return 0
	End if 
	
	If (Match regex:C1019("^[0-9]+$"; This:C1470.headers["retry-after"]))
		return Num:C11(This:C1470.headers["retry-after"])
	End if 
	
	var $date:=Date:C102(This:C1470.headers["retry-after"])
	var $time:=Time:C179(This:C1470.headers["retry-after"])
	
	return ($date-Current date:C33)*86400+($time-Current time:C178)
	
	// MARK:- utils
	
	// http request seems to not be sharable
Function _requestSharable()
	This:C1470.request:={agent: Null:C1517; \
		dataType: This:C1470.request.dataType; \
		encoding: This:C1470.request.encoding; \
		errors: This:C1470.request.errors; \
		headers: This:C1470.request.headers; \
		method: This:C1470.request.method; \
		protocol: This:C1470.request.protocol; \
		response: This:C1470.request.response; \
		returnResponseBody: This:C1470.request.returnResponseBody; \
		terminate: Formula:C1597(1); \
		terminated: This:C1470.request.terminated; \
		timeout: This:C1470.request.timeout; \
		url: This:C1470.request.url; \
		wait: Formula:C1597(1)}
	
	
	