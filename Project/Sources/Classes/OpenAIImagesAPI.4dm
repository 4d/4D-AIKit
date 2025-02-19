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
	
/*
* Edit an image. Only dall-e-2
* $image: The image to use as the basis for the variation(s). Must be a valid PNG file, less than 4MB, and square.
$ $mask: An additional image whose fully transparent areas (e.g. where alpha is zero) indicate where image should be edited. Must be a valid PNG file, less than 4MB, and have the same dimensions as
 */
Function _edit($image : Variant; $mask : Variant; $prompt : Text; $parameters : cs:C1710.OpenAIImageParameters) : cs:C1710.OpenAIImagesResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIImageParameters)))
		$parameters:=cs:C1710.OpenAIImageParameters.new($parameters)
	End if 
	
	var $body:=$parameters.body()
	$body.prompt:=$prompt
	
	return This:C1470._client._postFiles("/images/edits"; $body; {image: $image; mask: $mask}; $parameters; cs:C1710.OpenAIImagesResult)
	
/*
* Create a variation image. Only dall-e-2
* $image: The image to use as the basis for the variation(s). Must be a valid PNG file, less than 4MB, and square.
 */
Function _createVariation($image : Variant; $parameters : cs:C1710.OpenAIImageParameters) : cs:C1710.OpenAIImagesResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIImageParameters)))
		$parameters:=cs:C1710.OpenAIImageParameters.new($parameters)
	End if 
	
	var $body:=$parameters.body()
	
	return This:C1470._client._postFiles("/images/variations"; $body; {image: $image}; $parameters; cs:C1710.OpenAIImagesResult)
	
	