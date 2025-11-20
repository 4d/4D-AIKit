Class extends GeminiResult

Function get embedding : cs:C1710.GeminiEmbedding
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if

	return cs:C1710.GeminiEmbedding.new($body.embedding)

// Get the embedding vector directly
Function get vector : 4D:C1709.Vector
	var $emb:=This:C1470.embedding
	return ($emb=Null:C1517) ? Null:C1517 : $emb.values

