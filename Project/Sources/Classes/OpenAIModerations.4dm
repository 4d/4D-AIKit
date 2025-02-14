Class extends OpenAIAPIResource

/*
* Classifies if text and/or image inputs are potentially harmful.
* - $input: Input (or inputs) to classify. Can be a single text, a collection of texts
* - $model: he content moderation model you would like to use
 */
Function create($input : Variant; $model : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	var $body : Object:={input: $input; model: $model}
	return This:C1470._client._post("/moderations"; $body; $parameters)
	