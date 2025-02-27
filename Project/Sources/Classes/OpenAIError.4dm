property errCode : Integer
property message : Text

property body : Object
property response : Object

// https://platform.openai.com/docs/guides/error-codes
Class constructor($response : Object; $body : Object)
	This:C1470.response:=$response
	This:C1470.body:=$body
	
	If (Value type:C1509($body.error.code)=Is integer:K8:5)
		This:C1470.errCode:=$body.error.code
	Else 
		This:C1470.errCode:=This:C1470.response.status
	End if 
	This:C1470.message:=This:C1470._makeMessage()
	
Function _makeMessage() : Text
	Case of 
		: ((This:C1470.body=Null:C1517) || (This:C1470.body.error=Null:C1517))
			return This:C1470.response.statusText
		: (Value type:C1509(This:C1470.body.error.message)=Is text:K8:3)
			return This:C1470.body.error.message
		Else 
			return JSON Stringify:C1217(This:C1470.body.error.message)
	End case 
	
	// Uncomment if we could throw with computed properties ACI0105458 
	
Function get headers : Object
	return (This:C1470.response=Null:C1517) ? Null:C1517 : This:C1470.response.headers
	
Function get requestID : Text
	return (This:C1470.headers=Null:C1517) ? "" : This:C1470.headers["x-request-id"]
	
Function get type : Text
	return String:C10(This:C1470.body.error.type)
	
Function get param : Text
	return String:C10(This:C1470.body.error.param)
	
Function get code : Variant
	return String:C10(This:C1470.body.error.code)
	
Function get statusText : Text
	return String:C10(This:C1470.response.statusText)
	
Function get status : Integer
	return Num:C11(This:C1470.response.status)
	
Function get isBadRequestError : Boolean
	return This:C1470.status=400
	
Function get isAuthenticationError : Boolean
	return This:C1470.status=401
	
Function get isPermissionDeniedError : Boolean
	return This:C1470.status=403
	
Function get isNotFoundError : Boolean
	return This:C1470.status=404
	
Function get isUnprocessableEntityError : Boolean
	return This:C1470.status=422
	
Function get isRateLimitError : Boolean
	return This:C1470.status=429
	
Function get isInternalServerError : Boolean
	return This:C1470.status>=500
	