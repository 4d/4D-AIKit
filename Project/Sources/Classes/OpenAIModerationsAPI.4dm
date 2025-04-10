Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
/*
* Classifies if text and/or image inputs are potentially harmful.
* - $input: Input (or inputs) to classify. Could be a single Text or a collection of OpenAIMessage
* - $model: he content moderation model you would like to use
 */
Function create($input : Variant; $model : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIModerationResult
	var $body : Object:={input: $input; model: $model}
	return This:C1470._client._post("/moderations"; $body; $parameters; cs:C1710.OpenAIModerationResult)
	