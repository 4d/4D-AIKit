property input_items : cs:C1710.OpenAIResponseInputItemsAPI

Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
	This:C1470.input_items:=cs:C1710.OpenAIResponseInputItemsAPI.new($client)

/*
* Creates a model response for the given input.
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
		$body.input:=$input
	End if 
	
	return This:C1470._client._post("/responses"; $body; $parameters; cs:C1710.OpenAIResponsesResult)

/*
* Get a stored response.
 */
Function retrieve($responseID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResponsesResult
	return This:C1470._client._get("/responses/"+$responseID; $parameters; cs:C1710.OpenAIResponsesResult)

/*
* Delete a stored response.
 */
Function delete($responseID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._client._delete("/responses/"+$responseID; $parameters)

/*
* Cancel a response that is currently being generated.
 */
Function cancel($responseID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._client._post("/responses/"+$responseID+"/cancel"; {}; $parameters)

// MARK:- Lazy-friendly helper class

Function helper($instructions : Text; $parameters : cs:C1710.OpenAIResponsesParameters) : cs:C1710.OpenAIResponsesHelper
	return cs:C1710.OpenAIResponsesHelper.new(This:C1470; $instructions; $parameters)
