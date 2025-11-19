/*
Class: OpenAIVideoListResult
Result wrapper for video list operations with pagination support.

Provides access to collections of videos returned from the list API.

Properties:
  videos - Returns a collection of OpenAIVideo objects
  has_more - Indicates if more results are available
  first_id - ID of the first video in the list
  last_id - ID of the last video in the list
*/

Class extends OpenAIResult

/*
Function: videos
Returns the collection of video objects from the API response.

Returns:
  Collection - Collection of OpenAIVideo objects, or empty collection if none available
*/
Function get videos() : Collection

	var $body : Object:=This:C1470._objectBody()

	// Validate response structure
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.data)=Is collection:K8:32)))
		return []
	End if

	// Map each data item to OpenAIVideo instance
	var $videos : Collection:=[]
	var $video : Object

	For each ($video; $body.data)
		var $videoObj : cs:C1710.OpenAIVideo:=Try(cs:C1710.OpenAIVideo.new($video))
		If ($videoObj#Null:C1517)
			$videos.push($videoObj)
		End if
	End for each

	return $videos

/*
Function: has_more
Indicates if there are more results available for pagination.

Returns:
  Boolean - True if more results exist, False otherwise
*/
Function get has_more() : Boolean

	var $body : Object:=This:C1470._objectBody()

	If ($body=Null:C1517)
		return False:C215
	End if

	return Bool:C1537($body.has_more)

/*
Function: first_id
Returns the ID of the first video in the list.

Returns:
  Text - The first video ID, or empty string if not available
*/
Function get first_id() : Text

	var $body : Object:=This:C1470._objectBody()

	If ($body=Null:C1517)
		return ""
	End if

	return String:C10($body.first_id)

/*
Function: last_id
Returns the ID of the last video in the list for pagination.

Returns:
  Text - The last video ID, or empty string if not available
*/
Function get last_id() : Text

	var $body : Object:=This:C1470._objectBody()

	If ($body=Null:C1517)
		return ""
	End if

	return String:C10($body.last_id)
