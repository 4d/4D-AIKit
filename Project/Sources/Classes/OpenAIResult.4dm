property request : 4D:C1709.HTTPRequest

Function get success : Boolean
	If (This:C1470.request.response=Null:C1517)
		return False:C215
	End if 
	return (300>This:C1470.request.response.status) && (This:C1470.request.response.status>=200)
	
/*Function get terminated : Boolean
return This.request.terminated */
	