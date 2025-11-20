//%attributes = {"invisible":true}
var $client:=TestGemini()
If ($client=Null:C1517)
	return  // skip test
End if

var $model : Text:="text-embedding-004"

// MARK:- Test basic embedding
var $result:=$client.embeddings.create("A futuristic city skyline at sunset"; $model; {})

If (Asserted:C1132(Bool:C1537($result.success); "Cannot create embedding: "+JSON Stringify:C1217($result)))

	If (Asserted:C1132($result.embedding#Null:C1517; "No embedding returned"))

		If (Asserted:C1132(OB Instance of:C1731($result.embedding.values; 4D:C1709.Vector); "Embedding values must be a Vector"))

			ASSERT:C1129($result.embedding.values.length>0; "Embedding vector must not be empty")

		End if

	End if

	// Check usage metadata
	If (Asserted:C1132($result.usage#Null:C1517; "Usage metadata must be present"))
		ASSERT:C1129($result.usage.totalTokenCount>0; "Total token count should be greater than 0")
	End if

End if

// MARK:- Test with task type
var $params:=cs:C1710.GeminiEmbeddingsParameters.new()
$params.taskType:="RETRIEVAL_QUERY"

$result:=$client.embeddings.create("What is machine learning?"; $model; $params)

If (Asserted:C1132(Bool:C1537($result.success); "Cannot create embedding with task type: "+JSON Stringify:C1217($result)))
	ASSERT:C1129($result.embedding#Null:C1517; "Must have embedding")
	ASSERT:C1129($result.embedding.values.length>0; "Embedding vector must not be empty")
End if

// MARK:- Test error handling
var $errorResult:=$client.embeddings.create(""; $model; {})
ASSERT:C1129(Not:C34(Bool:C1537($errorResult.success)); "Must fail with empty content")
ASSERT:C1129($errorResult.errors.length>0; "Must have error")

