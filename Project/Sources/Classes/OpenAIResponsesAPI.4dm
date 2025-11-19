Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)

/*
* Creates a model response supporting text and image inputs with text or JSON outputs.
* @param $input - Text string, image, or file inputs
* @param $parameters - OpenAIResponsesParameters object containing configuration
* @return OpenAIResponsesResult object containing the response
 */
Function create($input : Variant; $parameters : cs:C1710.OpenAIResponsesParameters) : cs:C1710.OpenAIResponsesResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIResponsesParameters)))
		$parameters:=cs:C1710.OpenAIResponsesParameters.new($parameters)
	End if

	If ($parameters.stream)
		ASSERT:C1129($parameters.formula#Null:C1517 || $parameters.onData#Null:C1517; "When streaming you must provide a formula: onData")
	End if

	var $body:=$parameters.body()

	// Handle input parameter
	If ($input#Null:C1517)
		Case of
			: (Value type:C1509($input)=Is text:K8:3)
				$body.input:=$input
			: (Value type:C1509($input)=Is collection:K8:32)
				$body.input:=$input
			Else
				$body.input:=$input
		End case
	End if

	return This:C1470._client._post("/responses"; $body; $parameters; cs:C1710.OpenAIResponsesResult)

/*
* Get a stored response.
* @param $responseID - The ID of the response to retrieve
* @param $parameters - Optional parameters
* @return OpenAIResult object
 */
Function retrieve($responseID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._client._get("/responses/"+$responseID; $parameters)

/*
* Modify a stored response.
* @param $responseID - The ID of the response to modify
* @param $metadata - Metadata to update
* @param $parameters - Optional parameters
* @return OpenAIResult object
 */
Function update($responseID : Text; $metadata : Object; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._client._post("/responses/"+$responseID; {metadata: $metadata}; $parameters)

/*
* Delete a stored response.
* @param $responseID - The ID of the response to delete
* @param $parameters - Optional parameters
* @return OpenAIResult object
 */
Function delete($responseID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._client._delete("/responses/"+$responseID; $parameters)

