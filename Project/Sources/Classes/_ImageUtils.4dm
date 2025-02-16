singleton Class constructor
	
	
Function httpURLToBlob($url : Text) : 4D:C1709.Blob
	var $request:=4D:C1709.HTTPRequest.new($url).wait()
	If (Num:C11($request.response.status)=200)
		return $request.response.body()
	End if 
	return Null:C1517
	
Function base64ToBlob($base64 : Text) : 4D:C1709.Blob
	var $blob : 4D:C1709.Blob
	BASE64 DECODE:C896($base64; $blob)
	return $blob
	
Function toBlob($imageInfo : Variant) : 4D:C1709.Blob
	var $blob : 4D:C1709.Blob
	Case of 
		: ($imageInfo=Null:C1517)
			
			return Null:C1517
			
		: (Value type:C1509($imageInfo)=Is picture:K8:10)
			
			PICTURE TO BLOB:C692($imageInfo; $blob; ".png")
			
		: ((Value type:C1509($imageInfo)=Is object:K8:27) && (OB Instance of:C1731($imageInfo; 4D:C1709.File)))
			
			$blob:=$imageInfo.getContent()
			
		: (Value type:C1509($imageInfo)=Is text:K8:3)
			
			If (Position:C15("http"; String:C10($imageInfo))=1)
				$blob:=This:C1470.httpURLToBlob(String:C10($imageInfo))
			Else 
				$blob:=Try(File:C1566($imageInfo).getContent())
			End if 
			
	End case 
	
	return $blob
	
Function toBase64($imageInfo : Variant) : Text
	var $base64 : Text:=""
	var $blob:=This:C1470.toBlob($imageInfo)
	If ($blob#Null:C1517)
		BASE64 ENCODE:C895($blob; $base64)
	End if 
	return $base64
	
Function toInlinedPng($imageInfo : Variant) : Text
	var $base64:=This:C1470.toBase64($imageInfo)
	If (Length:C16($base64)>0)
		return "data:image/png;base64,"+$base64
	End if 
	return ""
	
Function toFormData($imageInfo : Variant) : Text
	var $blob:=This:C1470.toBlob($imageInfo)
	If ($blob#Null:C1517)
		return BLOB to text:C555($blob; UTF8 text without length:K22:17)
	End if 
	return ""
	
	