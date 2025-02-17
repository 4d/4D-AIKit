property request : 4D:C1709.HTTPRequest

Function get success : Boolean
	If (This:C1470.request.response=Null:C1517)
		return False:C215
	End if 
	return (300>This:C1470.request.response.status) && (This:C1470.request.response.status>=200)
	
/*Function get terminated : Boolean
return This.request.terminated */
	
Function _objectBody : Object
	Case of 
		: (This:C1470.request.response.body=Null:C1517)
			return Null:C1517
		: (Value type:C1509(This:C1470.request.response.body)=Is object:K8:27)
			return This:C1470.request.response.body
		: (Value type:C1509(This:C1470.request.response.body)=Is text:K8:3)  // sometime not decoded, maybe some errors do not return content type
			var $parsed:=Try(JSON Parse:C1218(This:C1470.request.response.body))
			If (Value type:C1509($parsed)=Is object:K8:27)
				return $parsed
			End if 
	End case 
	
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
	
	// MARK:- utils
	
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
	
	
	