/*
Class: OpenAIVideosAPI
API for OpenAI Videos endpoint.

Allows video generation and manipulation through the OpenAI API.

API Reference: https://platform.openai.com/docs/api-reference/videos
*/

Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)

/*
Function: create
Create a video based on a text prompt.

Parameters:
  $prompt - Text describing the video to generate (required)
  $parameters - OpenAIVideoParameters object with optional settings

Returns:
  OpenAIVideoResult - The result containing the video job

Example:
  var $result := $client.videos.create("A cat playing piano"; cs.OpenAIVideoParameters.new())
*/
Function create($prompt : Text; $parameters : cs:C1710.OpenAIVideoParameters) : cs:C1710.OpenAIVideoResult

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIVideoParameters)))
		$parameters:=cs:C1710.OpenAIVideoParameters.new($parameters)
	End if

	var $body : Object:=$parameters.body()
	$body.prompt:=$prompt

	// Handle input_reference if provided
	If ($parameters.input_reference#Null:C1517)
		var $files : Object:={input_reference: $parameters.input_reference}
		return This:C1470._client._postFiles("/videos"; $body; $files; $parameters; cs:C1710.OpenAIVideoResult)
	Else
		return This:C1470._client._post("/videos"; $body; $parameters; cs:C1710.OpenAIVideoResult)
	End if

/*
Function: remix
Create a remixed version of an existing video.

Parameters:
  $videoId - The ID of the video to remix (required)
  $prompt - Text describing the remix modifications (required)
  $parameters - OpenAIVideoParameters object with optional settings

Returns:
  OpenAIVideoResult - The result containing the new video job

Example:
  var $result := $client.videos.remix("video_abc123"; "Make it black and white"; cs.OpenAIVideoParameters.new())
*/
Function remix($videoId : Text; $prompt : Text; $parameters : cs:C1710.OpenAIVideoParameters) : cs:C1710.OpenAIVideoResult

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIVideoParameters)))
		$parameters:=cs:C1710.OpenAIVideoParameters.new($parameters)
	End if

	var $body : Object:=$parameters.body()
	$body.prompt:=$prompt

	return This:C1470._client._post("/videos/"+$videoId+"/remix"; $body; $parameters; cs:C1710.OpenAIVideoResult)

/*
Function: list
List all videos for the organization with optional pagination.

Parameters:
  $parameters - OpenAIVideoListParameters object with pagination settings

Returns:
  OpenAIVideoListResult - The result containing a collection of videos

Example:
  var $params := cs.OpenAIVideoListParameters.new({limit: 10; order: "desc"})
  var $result := $client.videos.list($params)
*/
Function list($parameters : cs:C1710.OpenAIVideoListParameters) : cs:C1710.OpenAIVideoListResult

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIVideoListParameters)))
		$parameters:=cs:C1710.OpenAIVideoListParameters.new($parameters)
	End if

	var $query : Object:=$parameters.body()

	return This:C1470._client._getApiList("/videos"; $query; $parameters; cs:C1710.OpenAIVideoListResult)

/*
Function: retrieve
Retrieve details of a specific video by ID.

Parameters:
  $videoId - The ID of the video to retrieve (required)
  $parameters - OpenAIParameters object (optional)

Returns:
  OpenAIVideoResult - The result containing the video details

Example:
  var $result := $client.videos.retrieve("video_abc123")
*/
Function retrieve($videoId : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIVideoResult

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIParameters)))
		$parameters:=cs:C1710.OpenAIParameters.new($parameters)
	End if

	return This:C1470._client._get("/videos/"+$videoId; $parameters; cs:C1710.OpenAIVideoResult)
