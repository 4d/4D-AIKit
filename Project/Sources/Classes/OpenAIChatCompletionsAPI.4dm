property messages : cs:C1710.OpenAIChatCompletionsMessagesAPI

Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
	This:C1470.messages:=cs:C1710.OpenAIChatCompletionsMessagesAPI.new($client)
	
/*
* Creates a model response for the given chat conversation.
 */
Function create($messages : Collection; $parameters : cs:C1710.OpenAIChatCompletionsParameters) : cs:C1710.OpenAIChatCompletionsResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIChatCompletionsParameters)))
		$parameters:=cs:C1710.OpenAIChatCompletionsParameters.new($parameters)
	End if 
	
	If ($parameters.stream)
		ASSERT:C1129($parameters.formula#Null:C1517 || $parameters.onData#Null:C1517; "When streaming you must provide a formula: onData")
	End if 
	
	var $body:=$parameters.body()
	
	If (String:C10(This:C1470._client.baseURL)="https://api.anthropic.com/v1")
		If (OB Is defined:C1231($body; "response_format"))
			$body.output_format:=$body.response_format
			If (OB Is defined:C1231($body.output_format; "json_schema"))
				If (OB Is defined:C1231($body.output_format.json_schema; "schema"))
					$body.output_format.schema:=$body.output_format.json_schema.schema
					OB REMOVE:C1226($body.output_format; "json_schema")
				End if 
			End if 
			OB REMOVE:C1226($body; "response_format")
		End if 
	End if 
	
	$body.messages:=$messages
	return This:C1470._client._post("/chat/completions"; $body; $parameters; cs:C1710.OpenAIChatCompletionsResult)
	
/*
* Get a stored chat completion.
 */
Function retrieve($completionID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._client._get("/chat/completions/"+$completionID; $parameters)
	
	
/*
* Modify a stored chat completion.
 */
Function update($completionID : Text; $metadata : Object; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._client._post("/chat/completions/"+$completionID; {metadata: $metadata}; $parameters)
	
/*
* Delete a stored chat completion.
 */
Function delete($completionID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
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
	