Class extends GeminiAPIResource

Class constructor($client : cs:C1710.Gemini)
	Super:C1705($client)

/*
* Retrieves information about a specific model.
* @param $model Text - The model name (e.g., "gemini-2.0-flash")
* @param $parameters GeminiParameters - Optional parameters
* @return GeminiModelResult - The model information
 */
Function retrieve($model : Text; $parameters : cs:C1710.GeminiParameters) : cs:C1710.GeminiModelResult
	If (Length:C16($model)=0)
		throw:C1805(1; "Expected a non-empty value for `model`")
	End if

	return This:C1470._client._get("/models/"+$model; $parameters; cs:C1710.GeminiModelResult)

/*
* Lists all available models.
* @param $parameters GeminiParameters - Optional parameters
* @return GeminiModelListResult - The list of models
 */
Function list($parameters : cs:C1710.GeminiParameters) : cs:C1710.GeminiModelListResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.GeminiParameters)))
		$parameters:=cs:C1710.GeminiParameters.new($parameters)
	End if

	return This:C1470._client._get("/models"; $parameters; cs:C1710.GeminiModelListResult)

