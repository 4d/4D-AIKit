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