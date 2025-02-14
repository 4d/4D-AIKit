Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
/*
* Creates a completion for the provided prompt and parameters.
 */
Function create($prompt : Text; $parameters : cs:C1710.OpenAICompletionParameters) : cs:C1710.OpenAIResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAICompletionParameters)))
		$parameters:=cs:C1710.OpenAICompletionParameters.new($parameters)
	End if 
	
	var $body:=$parameters.body()
	$body.prompt:=$prompt
	return This:C1470._client._post("/completions"; $body; $parameters)