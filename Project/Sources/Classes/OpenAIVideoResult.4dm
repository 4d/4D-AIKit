/*
Class: OpenAIVideoResult
Result wrapper for single video operations.

Provides access to video data returned from the API.

Properties:
  video - Returns the video object as OpenAIVideo
*/

Class extends OpenAIResult

/*
Function: video
Returns the video object from the API response.

Returns:
  OpenAIVideo - The video data object, or Null if not available
*/
Function get video() : cs:C1710.OpenAIVideo

	var $body : Object:=This:C1470._objectBody()

	// Validate response structure
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.id)=Is text:K8:3)))
		return Null:C1517
	End if

	// Create OpenAIVideo instance from response
	var $video : cs:C1710.OpenAIVideo:=Try(cs:C1710.OpenAIVideo.new($body))

	If ($video=Null:C1517)
		This:C1470._errors:=Last errors:C1799  // Capture decoding error
	End if

	return $video
