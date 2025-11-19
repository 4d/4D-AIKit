/*
Class: OpenAIVideoParameters
Parameters for video creation and remix operations.

Properties:
  model - The model to use (sora-2 or sora-2-pro)
  seconds - Video duration in seconds (4, 8, or 12)
  size - Video resolution (e.g., "720x1280", "1280x720", "1024x1792", "1792x1024")
  input_reference - Optional image file to guide generation (4D.File or 4D.Blob)
*/

// Properties for video generation
property model : Text:="sora-2"  // Default model
property seconds : Integer:=4  // Default duration in seconds
property size : Text:="720x1280"  // Default resolution
property input_reference : Variant  // Optional: 4D.File or 4D.Blob for image reference

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)

/*
Function: body
Converts parameters to API request body format.

Returns:
  Object - The request body with all non-empty parameters
*/
Function body() : Object

	var $body : Object:=Super:C1706.body()

	// Model parameter
	If (Length:C16(String:C10(This:C1470.model))>0)
		$body.model:=This:C1470.model
	End if

	// Seconds parameter (duration)
	If (This:C1470.seconds>0)
		$body.seconds:=This:C1470.seconds
	End if

	// Size parameter (resolution)
	If (Length:C16(String:C10(This:C1470.size))>0)
		$body.size:=This:C1470.size
	End if

	// Note: input_reference is handled separately in the API method
	// as it requires multipart form-data encoding

	return $body
