Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
/*
* Creates an image given a prompt.
 */
Function generate($prompt : Text; $parameters : cs:C1710.OpenAIImageParameters) : cs:C1710.OpenAIImagesResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIImageParameters)))
		$parameters:=cs:C1710.OpenAIImageParameters.new($parameters)
	End if 
	
	var $body:=$parameters.body()
	$body.prompt:=$prompt
	
	return This:C1470._client._post("/images/generations"; $body; $parameters; cs:C1710.OpenAIImagesResult)
	
	// Function edit($image: Variant; $prompt : Text; $parameters : cs.OpenAIImageParameters): cs.OpenAIResult
	
	// Function createVariation($image: Variant; $parameters : cs.OpenAIImageParameters) : cs.OpenAIResult