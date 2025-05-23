//%attributes = {}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.embeddings.create("A futuristic city skyline at sunset"; "text-embedding-ada-002"; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))

cs:C1710._TestSignal.me.wait(10*1000)

var $result : cs:C1710.OpenAIEmbeddingsResult:=cs:C1710._TestSignal.me.result

If (Asserted:C1132(Bool:C1537($result.success); "Cannot complete embedding : "+JSON Stringify:C1217($result)))
	
	ASSERT:C1129(Position:C15("text-embedding-ada-002"; $result.model)>0; $result.model)
	
	If (Asserted:C1132($result.embeddings#Null:C1517; "no embedding"))
		
		If (Asserted:C1132($result.embeddings.length>0; "must have one embedding"))
			
			If (Asserted:C1132(OB Instance of:C1731($result.embeddings[0].embedding; 4D:C1709.Vector); "ai embedding must contains a Vector"))
				
				ASSERT:C1129($result.embeddings[0].embedding.length>0; "empty embedding")
				
			End if 
		End if 
	End if 
End if 