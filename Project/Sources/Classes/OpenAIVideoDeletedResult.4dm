/*
Class: OpenAIVideoDeletedResult
Result wrapper for video deletion operations.

Provides access to video deletion status returned from the API.

Properties:
  deleted - Returns the video deletion status object as OpenAIVideoDeleted
*/

// Result class for video deletion operations
Class extends OpenAIResult

/*
Function: deleted
Returns the video deletion status from the API response.

Returns:
  OpenAIVideoDeleted - The deletion status object, or Null if invalid response
*/
Function get deleted() : cs:C1710.OpenAIVideoDeleted

	var $body : Object:=This:C1470._objectBody()

	// Validate response structure
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.id)=Is text:K8:3)))
		return Null:C1517
	End if

	return cs:C1710.OpenAIVideoDeleted.new($body)
