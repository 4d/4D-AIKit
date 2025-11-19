/*
Class: OpenAIVideo
Data model representing a video job from the OpenAI Videos API.

Properties:
  id - Unique identifier for the video
  object - Object type (always "video")
  status - Current status of the video job (queued, processing, completed, failed)
  prompt - The text prompt used to generate the video
  model - The model used for generation (e.g., sora-2, sora-2-pro)
  seconds - Duration of the video in seconds
  size - Resolution of the video (e.g., "720x1280")
  created_at - Unix timestamp of creation
  completed_at - Unix timestamp of completion (if completed)
  expires_at - Unix timestamp when the video expires
  output_url - URL to download the generated video (if completed)
  error - Error information if the job failed
  remixed_from_video_id - ID of the original video if this is a remix
*/

// Core properties
property id : Text
property object : Text
property status : Text  // queued, processing, completed, failed
property prompt : Text
property model : Text
property seconds : Integer
property size : Text

// Timestamps
property created_at : Integer
property completed_at : Integer
property expires_at : Integer

// Output
property output_url : Text

// Error information
property error : Object

// Remix information
property remixed_from_video_id : Text

/*
Constructor: new
Creates a new OpenAIVideo instance from an API response object.

Parameters:
  $object - The video object from the API response

Returns:
  OpenAIVideo - A new video instance
*/
Class constructor($object : Object)

	If ($object=Null:C1517)
		return
	End if

	// Copy all properties from the response object
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each
