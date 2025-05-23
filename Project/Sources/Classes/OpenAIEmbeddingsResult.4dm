property model : Text

Class extends OpenAIResult

Function get embeddings : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.data)=Is collection:K8:32)))
		return []
	End if 
	
	return $body.data.map(Formula:C1597(cs:C1710.OpenAIEmbedding.new($1.value)))
	
Function get embedding : cs:C1710.OpenAIEmbedding
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.data)=Is collection:K8:32)))
		return Null:C1517
	End if 
	If ($body.data.length=0)
		return Null:C1517
	End if 
	
	return cs:C1710.OpenAIEmbedding.new($body.data.first())
	
Function get vectors : Collection
	return This:C1470.embeddings.extract("embedding")
	
Function get vector : 4D:C1709.Vector
	var $embedding:=This:C1470.embedding
	return ($embedding=Null:C1517) ? Null:C1517 : $embedding.embedding
	
Function get model : Text
	var $body:=This:C1470._objectBody()
	return ($body=Null:C1517) ? "" : String:C10($body.model)