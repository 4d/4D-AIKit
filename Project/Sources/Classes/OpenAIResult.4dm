property request : 4D:C1709.HTTPRequest

Function get success : Boolean
	If (This:C1470.request.response=Null:C1517)
		return False:C215
	End if 
	return (300>This:C1470.request.response.status) && (This:C1470.request.response.status>=200)
	
/*Function get terminated : Boolean
return This.request.terminated */
	
Function saveImageToDisk($folder : 4D:C1709.Folder) : Boolean
	ASSERT:C1129($folder#Null:C1517)
	
	If (Not:C34(Value type:C1509(This:C1470.request.response.body.data)=Is collection:K8:32))
		return False:C215
	End if 
	
	var $image : Object
	var $index:=0
	For each ($image; This:C1470.request.response.body.data)
		If ($image.url#Null:C1517)
			var $request:=4D:C1709.HTTPRequest.new($image.url).wait()
			If (Num:C11($request.response.status)=200)
				$folder.file("image"+String:C10($index)+".png").setContent($request.response.body())
			End if 
		End if 
		$index+=1
	End for each 
	
	return True:C214