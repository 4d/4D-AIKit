Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.Reranker)
	Super:C1705($client)
	
	
Function create($query : cs:C1710.RerankerQuery; $parameters : cs:C1710.RerankerParameters) : cs:C1710.RerankerResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.RerankerParameters)))
		$parameters:=cs:C1710.OpenAIEmbeddingsParameters.new($parameters)
	End if 
	
	var $body:=$parameters.body()
	$body.query:=$query.query
	$body.documents:=$query.documents
	
	return This:C1470._client._post("/rerank"; $body; $parameters; cs:C1710.RerankerResult)