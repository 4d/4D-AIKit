property messages : cs:C1710.OpenAIChatCompletionsMessages

Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
	This:C1470.messages:=cs:C1710.OpenAIChatCompletionsMessages.new($client)
	
/*
* Creates a model response for the given chat conversation.
 */
Function create($messages : Collection; $parameters : cs:C1710.OpenAIChatCompletionParameters) : cs:C1710.OpenAIResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIChatCompletionParameters)))
		$parameters:=cs:C1710.OpenAIChatCompletionParameters.new($parameters)
	End if 
	
	var $body:=$parameters.body()
	$body.messages:=$messages
	return This:C1470._client._post("/chat/completions"; $body; $parameters)
	
/*
* Get a stored chat completion.
 */
Function retrieve($completionID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	
	If (Length:C16($completionID)=0)
		throw:C1805(1; "Expected a non-empty value for `completionID`")
	End if 
	
	return This:C1470._client._get("/chat/completions/"+$completionID; $parameters)
	
	
/*
* Modify a stored chat completion.
 */
Function update($completionID : Text; $metadata : Object; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	
	If (Length:C16($completionID)=0)
		throw:C1805(1; "Expected a non-empty value for `completionID`")
	End if 
	
	return This:C1470._client._post("/chat/completions/"+$completionID; {metadata: $metadata}; $parameters)
	
/*
* Delete a stored chat completion.
 */
Function delete($completionID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	
	If (Length:C16($completionID)=0)
		throw:C1805(1; "Expected a non-empty value for `completionID`")
	End if 
	
	return This:C1470._client._delete("/chat/completions/"+$completionID; $parameters)
	
/*
* List stored chat completions.
 */
Function list($parameters : cs:C1710.OpenAIChatCompletionsListParameters) : cs:C1710.OpenAIResult
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIChatCompletionsListParameters)))
		$parameters:=cs:C1710.OpenAIChatCompletionsListParameters.new($parameters)
	End if 
	
	var $query:=$parameters.body()
	return This:C1470._client._getApiList("/chat/completions"; $query; $parameters)
	