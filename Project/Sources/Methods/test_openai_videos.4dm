//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if

// MARK:- Test video creation
var $params:=cs:C1710.OpenAIVideoParameters.new({model: "sora-2"; seconds: 4; size: "720x1280"})
var $result:=$client.videos.create("A cat playing piano in a cozy living room"; $params)

If (Asserted:C1132(Bool:C1537($result.success); "Cannot create video: "+JSON Stringify:C1217($result)))

	If (Asserted:C1132($result.video#Null:C1517; "video must not be null"))

		ASSERT:C1129(Length:C16(String:C10($result.video.id))>0; "Must return a video id")
		ASSERT:C1129(Length:C16(String:C10($result.video.status))>0; "Must have a status")
		ASSERT:C1129($result.video.status="queued" || $result.video.status="processing" || $result.video.status="completed"; "Status must be queued, processing, or completed")
		ASSERT:C1129(Length:C16(String:C10($result.video.prompt))>0; "Must have a prompt")
		ASSERT:C1129($result.video.created_at>0; "Must have a creation timestamp")

	End if

End if

// MARK:- Test video retrieval
If ($result.success && $result.video#Null:C1517)

	var $videoId:=$result.video.id
	var $retrieveResult:=$client.videos.retrieve($videoId)

	If (Asserted:C1132(Bool:C1537($retrieveResult.success); "Cannot retrieve video: "+JSON Stringify:C1217($retrieveResult)))

		If (Asserted:C1132($retrieveResult.video#Null:C1517; "retrieved video must not be null"))

			ASSERT:C1129($retrieveResult.video.id=$videoId; "Retrieved video ID must match requested ID")
			ASSERT:C1129(Length:C16(String:C10($retrieveResult.video.status))>0; "Retrieved video must have a status")

		End if

	End if

End if

// MARK:- Test video list
var $listParams:=cs:C1710.OpenAIVideoListParameters.new({limit: 5; order: "desc"})
var $listResult:=$client.videos.list($listParams)

If (Asserted:C1132(Bool:C1537($listResult.success); "Cannot list videos: "+JSON Stringify:C1217($listResult)))

	If (Asserted:C1132($listResult.videos#Null:C1517; "videos list must not be null"))

		ASSERT:C1129(Value type:C1509($listResult.videos)=Is collection:K8:32; "videos must be a collection")

		// If we have videos, check the first one
		If ($listResult.videos.length>0)

			var $firstVideo:=$listResult.videos[0]
			ASSERT:C1129(Length:C16(String:C10($firstVideo.id))>0; "Video must have an id")
			ASSERT:C1129(Length:C16(String:C10($firstVideo.status))>0; "Video must have a status")

		End if

	End if

End if

// MARK:- Test video remix (only if we have a completed video)
// Note: This test might be skipped if no completed videos are available
If ($result.success && $result.video#Null:C1517)

	// Try to find a completed video from the list
	var $completedVideo:=Null:C1517

	If ($listResult.success && $listResult.videos#Null:C1517)

		For each ($video; $listResult.videos)
			If ($video.status="completed")
				$completedVideo:=$video
				break
			End if
		End for each

	End if

	// If we found a completed video, test remix
	If ($completedVideo#Null:C1517)

		var $remixResult:=$client.videos.remix($completedVideo.id; "Make it black and white with a vintage film effect"; cs:C1710.OpenAIVideoParameters.new())

		If (Asserted:C1132(Bool:C1537($remixResult.success); "Cannot remix video: "+JSON Stringify:C1217($remixResult)))

			If (Asserted:C1132($remixResult.video#Null:C1517; "remixed video must not be null"))

				ASSERT:C1129(Length:C16(String:C10($remixResult.video.id))>0; "Remixed video must have an id")
				ASSERT:C1129($remixResult.video.id#$completedVideo.id; "Remixed video must have a different id")
				ASSERT:C1129(Length:C16(String:C10($remixResult.video.remixed_from_video_id))>0; "Remixed video must have remixed_from_video_id")
				ASSERT:C1129($remixResult.video.remixed_from_video_id=$completedVideo.id; "remixed_from_video_id must match original video id")

			End if

		End if

	End if

End if

// MARK:- Test pagination
var $paginationParams:=cs:C1710.OpenAIVideoListParameters.new({limit: 2; order: "desc"})
var $page1Result:=$client.videos.list($paginationParams)

If (Asserted:C1132(Bool:C1537($page1Result.success); "Cannot list videos for pagination test: "+JSON Stringify:C1217($page1Result)))

	If ($page1Result.has_more && Length:C16($page1Result.last_id)>0)

		// Get the next page
		$paginationParams.after:=$page1Result.last_id
		var $page2Result:=$client.videos.list($paginationParams)

		If (Asserted:C1132(Bool:C1537($page2Result.success); "Cannot get second page: "+JSON Stringify:C1217($page2Result)))

			If (Asserted:C1132($page2Result.videos#Null:C1517; "second page videos must not be null"))

				// Ensure page 2 has different videos than page 1
				If ($page1Result.videos.length>0 && $page2Result.videos.length>0)
					ASSERT:C1129($page1Result.videos[0].id#$page2Result.videos[0].id; "Page 2 should have different videos than page 1")
				End if

			End if

		End if

	End if

End if

// MARK:- Test video content download (only if we have a completed video)
If ($listResult.success && $listResult.videos#Null:C1517)

	// Find a completed video for content download test
	$completedVideo:=Null:C1517

	For each ($video; $listResult.videos)
		If ($video.status="completed")
			$completedVideo:=$video
			break
		End if
	End for each

	// If we found a completed video, test content download
	If ($completedVideo#Null:C1517)

		var $contentResult:=$client.videos.content($completedVideo.id; cs:C1710.OpenAIParameters.new(); "")

		If (Asserted:C1132(Bool:C1537($contentResult.success); "Cannot download video content: "+JSON Stringify:C1217($contentResult)))

			// Check that we received video data
			If (Asserted:C1132($contentResult.request#Null:C1517; "request must not be null"))

				var $videoBlob:=$contentResult.request.response.body

				If (Asserted:C1132($videoBlob#Null:C1517; "video blob must not be null"))

					ASSERT:C1129($videoBlob.size>0; "video blob must have content")

				End if

			End if

		End if

	End if

End if

// MARK:- Test video deletion (only delete test videos, be careful!)
// Note: We'll create a test video specifically for deletion
var $deleteTestParams:=cs:C1710.OpenAIVideoParameters.new({model: "sora-2"; seconds: 4})
var $deleteTestResult:=$client.videos.create("Test video for deletion"; $deleteTestParams)

If ($deleteTestResult.success && $deleteTestResult.video#Null:C1517)

	var $videoToDelete:=$deleteTestResult.video.id

	// Delete the video
	var $deleteResult:=$client.videos.delete($videoToDelete)

	If (Asserted:C1132(Bool:C1537($deleteResult.success); "Cannot delete video: "+JSON Stringify:C1217($deleteResult)))

		If (Asserted:C1132($deleteResult.deleted#Null:C1517; "deleted status must not be null"))

			ASSERT:C1129($deleteResult.deleted.id=$videoToDelete; "Deleted video ID must match")
			ASSERT:C1129($deleteResult.deleted.deleted=True:C214; "deleted flag must be true")
			ASSERT:C1129($deleteResult.deleted.object="video"; "object type must be video")

		End if

	End if

	// Verify the video is actually deleted by trying to retrieve it
	var $verifyResult:=$client.videos.retrieve($videoToDelete)

	// Should fail with 404 or similar error
	ASSERT:C1129(Not:C34($verifyResult.success); "Retrieving deleted video should fail")

End if
