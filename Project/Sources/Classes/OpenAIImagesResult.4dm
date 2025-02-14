Class extends OpenAIResult

Function get images : Collection
	If (Not:C34(Value type:C1509(This:C1470.request.response.body.data)=Is collection:K8:32))
		return []
	End if 
	
	return This:C1470.request.response.body.data.extract("url")
	
Function saveImageToDisk($folder : 4D:C1709.Folder) : Boolean
	ASSERT:C1129($folder#Null:C1517)
	
	var $image : Object
	var $index:=0
	For each ($image; This:C1470.images)
		If ($image.url#Null:C1517)
			var $request:=4D:C1709.HTTPRequest.new($image.url).wait()
			If (Num:C11($request.response.status)=200)
				$folder.file("image"+String:C10($index)+".png").setContent($request.response.body())
			End if 
		End if 
		$index+=1
	End for each 
	
	return True:C214