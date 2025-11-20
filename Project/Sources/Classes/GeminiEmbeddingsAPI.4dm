
Class extends GeminiAPIResource

Class constructor($client : cs:C1710.Gemini)
	Super:C1705($client)

/*
* Creates an embedding vector from the input content.
* @param $content Text or Object - The content to embed
* @param $model Text - The model to use (e.g., "text-embedding-004")
* @param $parameters GeminiEmbeddingsParameters - Optional parameters
* @return GeminiEmbeddingsResult - The embedding result
 */
Function create($content : Variant; $model : Text; $parameters : cs:C1710.GeminiEmbeddingsParameters) : cs:C1710.GeminiEmbeddingsResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.GeminiEmbeddingsParameters)))
		$parameters:=cs:C1710.GeminiEmbeddingsParameters.new($parameters)
	End if

	var $body:=$parameters.body()

	// Build content based on input type
	If (Value type:C1509($content)=Is text:K8:3)
		// Simple text input - convert to content structure
		$body.content:={parts: [{text: $content}]}
	Else if (Value type:C1509($content)=Is object:K8:27)
		// Already a content object
		$body.content:=$content
	End if

	// Gemini uses the model in the path, not in the body
	var $path:="/models/"+$model+":embedContent"

	return This:C1470._client._post($path; $body; $parameters; cs:C1710.GeminiEmbeddingsResult)

