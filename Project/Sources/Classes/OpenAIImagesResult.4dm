Class extends OpenAIResult

Function get images : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.data)=Is collection:K8:32)))
		return []
	End if 
	
	return $body.data.map(Formula:C1597(cs:C1710.OpenAIImage.new($1.value)))
	
Function get image : cs:C1710.OpenAIImage
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.data)=Is collection:K8:32)))
		return Null:C1517
	End if 
	If ($body.data.length=0)
		return Null:C1517
	End if 
	
	return cs:C1710.OpenAIImage.new($body.data.first())
	
Function saveImagesToDisk($folder : 4D:C1709.Folder; $prefix : Text) : Boolean
	ASSERT:C1129($folder#Null:C1517)
	
	If (Length:C16(String:C10($prefix))=0)
		$prefix:="image"
	End if 
	
	var $index:=0
	var $image : cs:C1710.OpenAIImage
	For each ($image; This:C1470.images || [])
		var $blob:=$image.asBlob()
		If ($blob#Null:C1517)
			$folder.file($prefix+String:C10($index)+".png").setContent($blob)
		End if 
		$index+=1  // let increment even if failed
	End for each 
	
	return True:C214