//%attributes = {}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

var $model:="text-embedding-ada-002"
var $result:=$client.embeddings.create("A futuristic city skyline at sunset"; $model; {})

If (Asserted:C1132(Bool:C1537($result.success); "Cannot create embedding : "+JSON Stringify:C1217($result)))
	
	ASSERT:C1129(Position:C15($model; $result.model)>0; $result.model)
	
	If (Asserted:C1132($result.embeddings#Null:C1517; "no embedding"))
		
		If (Asserted:C1132($result.embeddings.length>0; "must have one embedding"))
			
			If (Asserted:C1132(OB Instance of:C1731($result.embeddings[0].embedding; 4D:C1709.Vector); "ai embedding must contains a Vector"))
				
				ASSERT:C1129($result.embeddings[0].embedding.length>0; "empty embedding")
				
			End if 
			
		End if 
		
	End if 
	
End if 

$result:=$client.embeddings.create(["A futuristic city skyline at sunset"; "An astronaut riding a rainbow unicorn"]; $model; {})

If (Asserted:C1132(Bool:C1537($result.success); "Cannot create embedding : "+JSON Stringify:C1217($result)))
	
	ASSERT:C1129(Position:C15($model; $result.model)>0; $result.model)
	
	If (Asserted:C1132($result.embeddings#Null:C1517; "no embedding"))
		
		If (Asserted:C1132($result.embeddings.length>1; "must have more than one embedding"))
			
			If (Asserted:C1132(OB Instance of:C1731($result.embeddings[0].embedding; 4D:C1709.Vector); "ai embedding must contains a Vector"))
				
				ASSERT:C1129($result.embeddings[0].embedding.length>0; "empty embedding")
				ASSERT:C1129($result.embeddings[1].embedding.length>0; "empty embedding")
				
			End if 
			
		End if 
		
	End if 
	
End if 

// MARK: - errors
$result:=$client.embeddings.create([]; $model; {})
ASSERT:C1129(Not:C34(Bool:C1537($result.success)); "Must not create embedding for empty : "+JSON Stringify:C1217($result))
ASSERT:C1129($result.errors.length>0; "Must have error :"+JSON Stringify:C1217($result))

$result:=$client.embeddings.create([Null:C1517]; $model; {})
ASSERT:C1129(Not:C34(Bool:C1537($result.success)); "Must not create embedding for null : "+JSON Stringify:C1217($result))
ASSERT:C1129($result.errors.length>0; "Must have error :"+JSON Stringify:C1217($result))

$result:=$client.embeddings.create("A futuristic city skyline at sunset"; ""; {})
ASSERT:C1129(Not:C34(Bool:C1537($result.success)); "Must not create embedding for null : "+JSON Stringify:C1217($result))
ASSERT:C1129($result.errors.length>0; "Must have error you must provide a model parameter:"+JSON Stringify:C1217($result))
