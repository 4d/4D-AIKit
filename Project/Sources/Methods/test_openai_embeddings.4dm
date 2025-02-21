//%attributes = {}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

var $result:=$client.embeddings.create("A futuristic city skyline at sunset"; "text-embedding-ada-002"; {})
If (Asserted:C1132(Bool:C1537($result.success); "Cannot create embedding : "+JSON Stringify:C1217($result)))
	
	ASSERT:C1129($result.embedding#Null:C1517)
	ASSERT:C1129(($result.embeddings#Null:C1517) && ($result.embeddings.length>0))
	
End if 