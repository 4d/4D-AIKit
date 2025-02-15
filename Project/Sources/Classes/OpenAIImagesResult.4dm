Class extends OpenAIResult

Function get images : Collection
	If (Not:C34(Value type:C1509(This:C1470.request.response.body.data)=Is collection:K8:32))
		return []
	End if 
	
	return This:C1470.request.response.body.data.map(Formula:C1597(cs:C1710.Image.new($1.value)))
	
Function get image : cs:C1710.Image
	If (Not:C34(Value type:C1509(This:C1470.request.response.body.data)=Is collection:K8:32))
		return Null:C1517
	End if 
	If (This:C1470.request.response.body.data.length=0)
		return Null:C1517
	End if 
	
	return cs:C1710.Image.new(This:C1470.request.response.body.data.first())
	
Function saveImagesToDisk($folder : 4D:C1709.Folder) : Boolean
	ASSERT:C1129($folder#Null:C1517)
	
	var $index:=0
	var $image : cs:C1710.Image
	For each ($image; This:C1470.images || [])
		var $blob:=$image.asBlob()
		If ($blob#Null:C1517)
			$folder.file("image"+String:C10($index)+".png").setContent($blob)
		End if 
		$index+=1  // let increment even if failed
	End for each 
	
	return True:C214