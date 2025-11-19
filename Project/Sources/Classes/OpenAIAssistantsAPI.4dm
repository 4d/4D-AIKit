// API resource for managing assistants in OpenAI
// Assistants can call models and use tools to perform tasks
Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)

/*
* Create an assistant with a model and instructions.
*
* @param $parameters {cs.OpenAIAssistantsParameters} Parameters for creating the assistant (required)
* @return {cs.OpenAIAssistantsResult} Result containing the created assistant information
* @throws Error if model is not specified in parameters
*/
Function create($parameters : cs:C1710.OpenAIAssistantsParameters) : cs:C1710.OpenAIAssistantsResult

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIAssistantsParameters)))
		$parameters:=cs:C1710.OpenAIAssistantsParameters.new($parameters)
	End if

	var $body:=$parameters.body()

	// Validate required field
	If (Length:C16(String:C10($body.model))=0)
		throw:C1805(1; "Expected a non-empty value for `model`")
	End if

	return This:C1470._client._post("/assistants"; $body; $parameters; cs:C1710.OpenAIAssistantsResult)

/*
* Returns a list of assistants.
*
* @param $parameters {cs.OpenAIAssistantListParameters} Optional parameters for filtering and pagination
* @return {cs.OpenAIAssistantListResult} Result containing a collection of assistant objects
*/
Function list($parameters : cs:C1710.OpenAIAssistantListParameters) : cs:C1710.OpenAIAssistantListResult

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIAssistantListParameters)))
		$parameters:=cs:C1710.OpenAIAssistantListParameters.new($parameters)
	End if

	var $query:=$parameters.body()
	return This:C1470._client._getApiList("/assistants"; $query; $parameters; cs:C1710.OpenAIAssistantListResult)

/*
* Retrieves an assistant.
*
* @param $assistantId {Text} The ID of the assistant to retrieve (required)
* @param $parameters {cs.OpenAIParameters} Optional parameters for the request
* @return {cs.OpenAIAssistantsResult} Result containing the assistant information
* @throws Error if assistantId is empty
*/
Function retrieve($assistantId : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIAssistantsResult
	If (Length:C16($assistantId)=0)
		throw:C1805(1; "Expected a non-empty value for `assistantId`")
	End if

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIParameters)))
		$parameters:=cs:C1710.OpenAIParameters.new($parameters)
	End if

	return This:C1470._client._get("/assistants/"+$assistantId; $parameters; cs:C1710.OpenAIAssistantsResult)

/*
* Modifies an assistant.
*
* @param $assistantId {Text} The ID of the assistant to modify (required)
* @param $parameters {cs.OpenAIAssistantsParameters} Parameters for modifying the assistant
* @return {cs.OpenAIAssistantsResult} Result containing the modified assistant information
* @throws Error if assistantId is empty
*/
Function modify($assistantId : Text; $parameters : cs:C1710.OpenAIAssistantsParameters) : cs:C1710.OpenAIAssistantsResult
	If (Length:C16($assistantId)=0)
		throw:C1805(1; "Expected a non-empty value for `assistantId`")
	End if

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIAssistantsParameters)))
		$parameters:=cs:C1710.OpenAIAssistantsParameters.new($parameters)
	End if

	var $body:=$parameters.body()
	return This:C1470._client._post("/assistants/"+$assistantId; $body; $parameters; cs:C1710.OpenAIAssistantsResult)

/*
* Delete an assistant.
*
* @param $assistantId {Text} The ID of the assistant to delete (required)
* @param $parameters {cs.OpenAIParameters} Optional parameters for the request
* @return {cs.OpenAIAssistantDeletedResult} Result containing the deletion status
* @throws Error if assistantId is empty
*/
Function delete($assistantId : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIAssistantDeletedResult
	If (Length:C16($assistantId)=0)
		throw:C1805(1; "Expected a non-empty value for `assistantId`")
	End if

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIParameters)))
		$parameters:=cs:C1710.OpenAIParameters.new($parameters)
	End if

	return This:C1470._client._delete("/assistants/"+$assistantId; $parameters; cs:C1710.OpenAIAssistantDeletedResult)

