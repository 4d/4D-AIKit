/*
Class: OpenAIVideoDeleted
Data model representing a deleted video from the OpenAI Videos API.

Properties:
  id - Unique identifier for the deleted video
  deleted - Boolean indicating if the video was successfully deleted
  object - Object type (always "video")
*/

// The ID of the deleted video
property id : Text

// Whether the video was successfully deleted
property deleted : Boolean

// The object type, which is always "video"
property object : Text

/*
Constructor: new
Creates a new OpenAIVideoDeleted instance from an API response object.

Parameters:
  $object - The deleted video object from the API response

Returns:
  OpenAIVideoDeleted - A new deleted video instance
*/
Class constructor($object : Object)

	If ($object=Null:C1517)
		return
	End if

	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each
