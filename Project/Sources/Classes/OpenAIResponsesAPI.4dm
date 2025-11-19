Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)

/*
* Creates a response for the given input using OpenAI's Responses API.
* This unified API combines capabilities from Chat Completions and Assistants APIs.
*/
Function create($input : Variant; $parameters : cs:C1710.OpenAIResponsesParameters) : cs:C1710.OpenAIResponsesResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIResponsesParameters)))
		$parameters:=cs:C1710.OpenAIResponsesParameters.new($parameters)
	End if

	If ($parameters.stream)
		ASSERT:C1129($parameters.formula#Null:C1517 || $parameters.onData#Null:C1517; "When streaming you must provide a formula: onData")
	End if

	var $body:=$parameters.body()

	// Add input - can be string or array of message objects
	If ($input#Null:C1517)
		If (Value type:C1509($input)=Is collection:K8:32)
			// Input is an array of messages
			$body.input:=[]
			var $message : Object
			For each ($message; $input)
				If (Not:C34(OB Instance of:C1731($message; cs:C1710.OpenAIMessage)))
					$message:=cs:C1710.OpenAIMessage.new($message)
				End if
				$body.input.push($message._toBody())
			End for each
		Else
			// Input is a simple string
			$body.input:=String:C10($input)
		End if
	End if

	return This:C1470._client._post("/responses"; $body; $parameters; cs:C1710.OpenAIResponsesResult)

/*
* Get a stored response.
*/
Function retrieve($responseID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResponsesResult
	return This:C1470._client._get("/responses/"+$responseID; $parameters; cs:C1710.OpenAIResponsesResult)

/*
* List stored responses.
*/
Function list($parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIParameters)))
		$parameters:=cs:C1710.OpenAIParameters.new($parameters)
	End if

	var $query:=$parameters.body()
	return This:C1470._client._getApiList("/responses"; $query; $parameters; cs:C1710.OpenAIResult)

/*
* Delete a stored response.
*/
Function delete($responseID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._client._delete("/responses/"+$responseID; $parameters; cs:C1710.OpenAIResult)
