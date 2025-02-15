property request : 4D:C1709.HTTPRequest

Function get success : Boolean
	If (This:C1470.request.response=Null:C1517)
		return False:C215
	End if 
	return (300>This:C1470.request.response.status) && (This:C1470.request.response.status>=200)
	
/*Function get terminated : Boolean
return This.request.terminated */
	
Function objectBody : Object
	Case of 
		: (This:C1470.request.response.body=Null:C1517)
			return Null:C1517
		: (Value type:C1509(This:C1470.request.response.body)=Is object:K8:27)
			return This:C1470.request.response.body
		: (Value type:C1509(This:C1470.request.response.body)=Is text:K8:3)  // sometime not decoded, maybe some errors do not return content type
			return Try(JSON Parse:C1218(This:C1470.request.response.body))
	End case 
	
Function get errors : Collection
	
	If ((This:C1470.request.errors#Null:C1517) && (This:C1470.request.errors.length>0))
		return This:C1470.request.errors
	End if 
	
	If ((This:C1470.request.response#Null:C1517) && (Value type:C1509(This:C1470.request.response.body)=Is object:K8:27))
		var $body:=This:C1470.objectBody()
		If ($body.error#Null:C1517)
			return [$body.error]
		End if 
	End if 
	
	If ((This:C1470.request.response#Null:C1517) && (This:C1470.request.response.status>=300))
		return [{code: This:C1470.request.response.status; message: This:C1470.request.response.statusText}]
	End if 
	
	return []
	
	
	