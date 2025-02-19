Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
/*
* Retrieves a model instance to provide basic information.
 */
Function retrieve($model : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIModelResult
	If (Length:C16($model)=0)
		throw:C1805(1; "Expected a non-empty value for `model`")
	End if 
	
	return This:C1470._client._get("/models/"+$model; $parameters; cs:C1710.OpenAIModelResult)
	
/*
* Lists the currently available models
 */
Function list($parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIModelListResult
	return This:C1470._client._get("/models"; $parameters; cs:C1710.OpenAIModelListResult)
	
/*
* Delete a fine-tuned model.
 */
/*Function delete($model : Text; $parameters : Object)
If (Length($model)=0)
throw(1; "Expected a non-empty value for `model`")
End if 
return This._client._delete("/models/"+$model; $parameters)*/