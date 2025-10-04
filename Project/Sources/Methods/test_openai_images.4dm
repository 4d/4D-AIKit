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



//MARK:- Artistic Style (DALL-E-3 only)
$result:=$client.images.generate("a nature picture"; {model: "dall-e-3"; style: "natural"})

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

If (True:C214)
	return   // after are private methods not validated yet
End if 

// MARK:- Create variation (DALL-E-2 only)
If ($picture#Null:C1517)
	
	var $variationResult:=$client.images._createVariation($picture; {model: "dall-e-2"; size: "512x512"})
	
	If (Asserted:C1132(Bool:C1537($variationResult.success); "Cannot create variation: "+JSON Stringify:C1217($variationResult)))
		
		If (Asserted:C1132($variationResult.images#Null:C1517 && $variationResult.image#Null:C1517; "variation images or image must not be null"))
			
			ASSERT:C1129((Length:C16(String:C10($variationResult.image.url))>0) | (Length:C16(String:C10($variationResult.image.b64_json))>0); "Must return an image url or b64_json")
			
			var $variationBlob:=$variationResult.image.asBlob()
			
			If (Asserted:C1132($variationBlob#Null:C1517; "must have variation image blob"))
				
				ASSERT:C1129($variationBlob.size>0; "variation image blob must not be empty")
				
			End if 
			
			var $variationPicture:=$variationResult.image.asPicture()
			
			If (Asserted:C1132($variationPicture#Null:C1517; "must have variation picture"))
				
				ASSERT:C1129(Picture size:C356($variationPicture)>0; "variation image must not be empty")
				
			End if 
			
		End if 
		
	End if 
	
End if 

// MARK:- Edit image (DALL-E-2 only)
If ($picture#Null:C1517)
	
	var $editResult:=$client.images._edit($picture; Null:C1517; "could you add more yellow"; {model: "dall-e-2"; size: "512x512"})
	
	If (Asserted:C1132(Bool:C1537($editResult.success); "Cannot edit image: "+JSON Stringify:C1217($editResult)))
		
		If (Asserted:C1132($editResult.images#Null:C1517 && $editResult.image#Null:C1517; "edited images or image must not be null"))
			
			ASSERT:C1129((Length:C16(String:C10($editResult.image.url))>0) | (Length:C16(String:C10($editResult.image.b64_json))>0); "Must return an image url or b64_json")
			
			var $editBlob:=$editResult.image.asBlob()
			
			If (Asserted:C1132($editBlob#Null:C1517; "must have edited image blob"))
				
				ASSERT:C1129($editBlob.size>0; "edited image blob must not be empty")
				
			End if 
			
			var $editPicture:=$editResult.image.asPicture()
			
			If (Asserted:C1132($editPicture#Null:C1517; "must have edited picture"))
				
				ASSERT:C1129(Picture size:C356($editPicture)>0; "edited image must not be empty")
				
			End if 
			
		End if 
		
	End if 
	
End if 