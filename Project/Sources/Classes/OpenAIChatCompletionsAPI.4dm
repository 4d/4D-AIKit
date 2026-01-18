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
	
	Case of 
		: (This:C1470._client.baseURL="@.openai.azure.com/openai/v1") && \
			["@Llama-3.1@"; "Phi-4@"].some(Formula:C1597($2=$1.value); String:C10($parameters.model))
			If (OB Is defined:C1231($body; "response_format"))
				If ($body.response_format.type="json_schema")
					If (OB Is defined:C1231($body.response_format; "json_schema"))
						var $message : Object
						$message:=$messages.query("role == :1"; "system").first()
						If ($message#Null:C1517)
							If (Value type:C1509($message.text)=Is text:K8:3)
								$message.text+=["You must output valid JSON only."; \
									"You must not add any extra properties not defined in the schema."; \
									"You must not change any property name defined in the schema."; \
									"you must not omit any required property defined in the schema."; \
									"You must strictly adhere to this JSON schema: "; \
									JSON Stringify:C1217($body.response_format.json_schema.schema)].join("\n")
							End if 
						End if 
					End if 
					$body.response_format:={type: "json_object"}
				End if 
			End if 
	End case 
	
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
	