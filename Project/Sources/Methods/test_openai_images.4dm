//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// MARK:- as url
var $result:=$client.images.generate("A futuristic city skyline at sunset"; {size: "512x512"})
If (Asserted:C1132(Bool:C1537($result.success); "Cannot generate images : "+JSON Stringify:C1217($result)))
	
	If (Asserted:C1132($result.images#Null:C1517 && $result.image#Null:C1517; "images or image must not be null"))
		
		ASSERT:C1129(Length:C16(String:C10($result.image.url))>0; "Must return an image url")
		
		var $blob:=$result.image.asBlob()
		
		If (Asserted:C1132($blob#Null:C1517; "must have image blob"))
			
			ASSERT:C1129($blob.size>0; "image blob must not be empty")
			
		End if 
		
		var $picture:=$result.image.asPicture()
		
		If (Asserted:C1132($picture#Null:C1517; "must have $picture"))
			
			ASSERT:C1129(Picture size:C356($picture)>0; "image must not be empty")
			
		End if 
		
	End if 
	
End if 

// MARK:- as b64
$result:=$client.images.generate("A futuristic city skyline at sunset"; {size: "512x512"; response_format: "b64_json"})
If (Asserted:C1132(Bool:C1537($result.success); "Cannot generate images : "+JSON Stringify:C1217($result)))
	
	If (Asserted:C1132($result.images#Null:C1517 && $result.image#Null:C1517; "images or image must not be null"))
		
		ASSERT:C1129(Length:C16(String:C10($result.image.b64_json))>0; "Must return a base 64 encoded image")
		
		$blob:=$result.image.asBlob()
		
		If (Asserted:C1132($blob#Null:C1517; "must have image blob"))
			
			ASSERT:C1129($blob.size>0; "image blob must not be empty")
			
		End if 
		
		$picture:=$result.image.asPicture()
		
		If (Asserted:C1132($picture#Null:C1517; "must have $picture"))
			
			ASSERT:C1129(Picture size:C356($picture)>0; "image must not be empty")
			
		End if 
		
	End if 
	
End if 



//MARK:- Artistic Style
$result:=$client.images.generate("a nature picture"; {style: "natural"})

If (Asserted:C1132(Bool:C1537($result.success); "Cannot generate images : "+JSON Stringify:C1217($result)))
	
	If (Asserted:C1132($result.images#Null:C1517 && $result.image#Null:C1517; "images or image must not be null"))
		
		$blob:=$result.image.asBlob()
		
		If (Asserted:C1132($blob#Null:C1517; "must have image blob"))
			
			ASSERT:C1129($blob.size>0; "image blob must not be empty")
			
		End if 
		
		$picture:=$result.image.asPicture()
		
		If (Asserted:C1132($picture#Null:C1517; "must have $picture"))
			
			ASSERT:C1129(Picture size:C356($picture)>0; "image must not be empty")
			
		End if 
		
	End if 
	
End if 

// MARK:- not implemented

// $imagesResult:=$client.images._createVariation(Folder(fk desktop folder).file("mycity.png"))

// $imagesResult:=$client.images._edit(Folder(fk desktop folder).file("mycity.png"); "could you add more yellow")