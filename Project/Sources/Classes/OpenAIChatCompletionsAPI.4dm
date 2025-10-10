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
	$body.messages:=[]
	If ($messages#Null:C1517)
		var $message : Object
		For each ($message; $messages)
			If (Not:C34(OB Instance of:C1731($message; cs:C1710.OpenAIMessage)))
				$message:=cs:C1710.OpenAIMessage.new($message)
			End if 
			$body.messages.push($message._toBody())
		End for each 
	End if 
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
	