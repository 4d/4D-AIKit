Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)

/*
* List input items for a response.
 */
Function list($responseID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._client._get("/responses/"+$responseID+"/input_items"; $parameters)
