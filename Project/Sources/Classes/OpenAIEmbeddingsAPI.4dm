
Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
	
Function create($input : Variant; $model : Text; $parameters : cs:C1710.OpenAIEmbeddingsParameters) : cs:C1710.OpenAIEmbeddingsResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIEmbeddingsParameters)))
		$parameters:=cs:C1710.OpenAIEmbeddingsParameters.new($parameters)
	End if 
	
	var $body:=$parameters.body()
	$body.input:=$input  // text or array
	$body.model:=$model
	
	return This:C1470._client._post("/embeddings"; $body; $parameters; cs:C1710.OpenAIEmbeddingsResult)