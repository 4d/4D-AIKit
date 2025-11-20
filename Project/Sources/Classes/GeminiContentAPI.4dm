
Class extends GeminiAPIResource

Class constructor($client : cs:C1710.Gemini)
	Super:C1705($client)

/*
* Generates content using the specified model.
* The first parameter can be a simple text prompt or a Collection of content objects.
* The model parameter is the model name (e.g., "gemini-2.0-flash").
 */
Function generate($prompt : Variant; $model : Text; $parameters : cs:C1710.GeminiContentParameters) : cs:C1710.GeminiContentResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.GeminiContentParameters)))
		$parameters:=cs:C1710.GeminiContentParameters.new($parameters)
	End if

	var $body:=$parameters.body()

	// Build contents array based on input type
	If (Value type:C1509($prompt)=Is text:K8:3)
		// Simple text prompt - convert to contents structure
		$body.contents:=[{parts: [{text: $prompt}]}]
	Else if (Value type:C1509($prompt)=Is collection:K8:32)
		// Already a collection of content objects
		$body.contents:=$prompt
	End if

	// Gemini uses the model in the path, not in the body
	var $path:="/models/"+$model+":generateContent"

	return This:C1470._client._post($path; $body; $parameters; cs:C1710.GeminiContentResult)

/*
* Creates a simple text generation with a single prompt (convenience method).
 */
Function generateText($prompt : Text; $model : Text; $parameters : cs:C1710.GeminiContentParameters) : Text
	var $result:=This:C1470.generate($prompt; $model; $parameters)
	If ($result.success && ($result.candidates.length>0))
		var $candidate:=$result.candidates[0]
		If (($candidate.content#Null:C1517) && ($candidate.content.parts.length>0))
			return $candidate.content.parts[0].text
		End if
	End if
	return ""

