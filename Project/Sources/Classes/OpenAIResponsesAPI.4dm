Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)

/*
* Creates a model response supporting text and image inputs with text or JSON outputs.
* @param $input - Text string, image, or file inputs
* @param $parameters - OpenAIResponsesParameters object containing configuration
* @return OpenAIResponsesResult object containing the response
 */
Function create($input : Variant; $parameters : cs:C1710.OpenAIResponsesParameters) : cs:C1710.OpenAIResponsesResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIResponsesParameters)))
		$parameters:=cs:C1710.OpenAIResponsesParameters.new($parameters)
	End if

	If ($parameters.stream)
		ASSERT:C1129($parameters.formula#Null:C1517 || $parameters.onData#Null:C1517; "When streaming you must provide a formula: onData")
	End if

	var $body:=$parameters.body()

	// Handle input parameter
	If ($input#Null:C1517)
		Case of
			: (Value type:C1509($input)=Is text:K8:3)
				$body.input:=$input
			: (Value type:C1509($input)=Is collection:K8:32)
				$body.input:=$input
			Else
				$body.input:=$input
		End case
	End if

	return This:C1470._client._post("/responses"; $body; $parameters; cs:C1710.OpenAIResponsesResult)

/*
* Count the number of input tokens for a response request before generating output.
* @param $input - Text string, image, or file inputs
* @param $parameters - OpenAIResponsesParameters object containing configuration
* @return OpenAIResponsesInputTokensResult object containing the token count
 */
Function countInputTokens($input : Variant; $parameters : cs:C1710.OpenAIResponsesParameters) : cs:C1710.OpenAIResponsesInputTokensResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIResponsesParameters)))
		$parameters:=cs:C1710.OpenAIResponsesParameters.new($parameters)
	End if

	var $body:=This:C1470._inputTokensBody($parameters)
	If ($input#Null:C1517)
		$body.input:=$input
	End if

	return This:C1470._client._post("/responses/input_tokens"; $body; $parameters; cs:C1710.OpenAIResponsesInputTokensResult)

/*
* Get a stored response.
* @param $responseID - The ID of the response to retrieve
* @param $parameters - Optional parameters
 * @return OpenAIResponsesResult object
 */
Function retrieve($responseID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResponsesResult
	If (Length:C16($responseID)=0)
		throw:C1805(1; "Expected a non-empty value for `responseID`")
	End if
	return This:C1470._client._get("/responses/"+$responseID; $parameters; cs:C1710.OpenAIResponsesResult)

/*
* List the input items that were used to create a stored response.
* @param $responseID - The ID of the response to inspect
* @param $parameters - Optional pagination and include parameters
* @return OpenAIResponsesInputItemsResult object containing the input items
 */
Function listInputItems($responseID : Text; $parameters : cs:C1710.OpenAIResponsesInputItemsParameters) : cs:C1710.OpenAIResponsesInputItemsResult
	If (Length:C16($responseID)=0)
		throw:C1805(1; "Expected a non-empty value for `responseID`")
	End if
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIResponsesInputItemsParameters)))
		$parameters:=cs:C1710.OpenAIResponsesInputItemsParameters.new($parameters)
	End if
	
	return This:C1470._client._getApiList("/responses/"+$responseID+"/input_items"; $parameters.body(); $parameters; cs:C1710.OpenAIResponsesInputItemsResult)

/*
* Modify a stored response.
* @param $responseID - The ID of the response to modify
* @param $metadata - Metadata to update
* @param $parameters - Optional parameters
 * @return OpenAIResponsesResult object
 */
Function update($responseID : Text; $metadata : Object; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResponsesResult
	If (Length:C16($responseID)=0)
		throw:C1805(1; "Expected a non-empty value for `responseID`")
	End if
	return This:C1470._client._post("/responses/"+$responseID; {metadata: $metadata}; $parameters; cs:C1710.OpenAIResponsesResult)

/*
* Cancel an in-progress background response.
* @param $responseID - The ID of the response to cancel
* @param $parameters - Optional parameters
* @return OpenAIResponsesResult object containing the cancelled response
 */
Function cancel($responseID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResponsesResult
	If (Length:C16($responseID)=0)
		throw:C1805(1; "Expected a non-empty value for `responseID`")
	End if
	return This:C1470._client._post("/responses/"+$responseID+"/cancel"; Null:C1517; $parameters; cs:C1710.OpenAIResponsesResult)

/*
* Compact an existing response into a new compacted response.
* @param $responseID - The ID of the response to compact
* @param $parameters - OpenAIResponsesCompactParameters object containing compaction options
* @return OpenAIResponsesResult object containing the compacted response
 */
Function compact($responseID : Text; $parameters : cs:C1710.OpenAIResponsesCompactParameters) : cs:C1710.OpenAIResponsesResult
	If (Length:C16($responseID)=0)
		throw:C1805(1; "Expected a non-empty value for `responseID`")
	End if
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIResponsesCompactParameters)))
		$parameters:=cs:C1710.OpenAIResponsesCompactParameters.new($parameters)
	End if
	
	var $body:=$parameters.body()
	$body.previous_response_id:=$responseID
	return This:C1470._client._post("/responses/compact"; $body; $parameters; cs:C1710.OpenAIResponsesResult)

/*
* Delete a stored response.
* @param $responseID - The ID of the response to delete
* @param $parameters - Optional parameters
* @return OpenAIResponseDeletedResult object
 */
Function delete($responseID : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResponseDeletedResult
	If (Length:C16($responseID)=0)
		throw:C1805(1; "Expected a non-empty value for `responseID`")
	End if
	return This:C1470._client._delete("/responses/"+$responseID; $parameters; cs:C1710.OpenAIResponseDeletedResult)

Function _inputTokensBody($parameters : cs:C1710.OpenAIResponsesParameters) : Object
	var $body : Object:={}
	
	If (Length:C16(String:C10($parameters.model))>0)
		$body.model:=$parameters.model
	End if 
	If (Length:C16(String:C10($parameters.instructions))>0)
		$body.instructions:=$parameters.instructions
	End if 
	If ($parameters.conversation#Null:C1517)
		$body.conversation:=$parameters.conversation
	End if 
	If ($parameters.include#Null:C1517)
		$body.include:=$parameters.include
	End if 
	If (Length:C16(String:C10($parameters.previous_response_id))>0)
		$body.previous_response_id:=$parameters.previous_response_id
	End if 
	If ($parameters.text#Null:C1517)
		$body.text:=$parameters.text
	End if 
	If ($parameters.reasoning#Null:C1517)
		$body.reasoning:=$parameters.reasoning
	End if 
	If (Length:C16(String:C10($parameters.truncation))>0)
		$body.truncation:=$parameters.truncation
	End if 
	
	$parameters._mapTools()
	If ($parameters.tools#Null:C1517)
		$body.tools:=$parameters.tools.map(Formula:C1597($1.value.body()))
	End if 
	If ($parameters.tool_choice#Null:C1517)
		$body.tool_choice:=$parameters.tool_choice
	End if 
	
	return $body
