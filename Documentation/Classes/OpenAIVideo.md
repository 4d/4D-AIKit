# OpenAIVideo

The `OpenAIVideo` class represents a video job from the OpenAI Videos API. It contains all information about a video generation or remix operation.

## Properties

| Property | Type | Description |
|----------|------|-------------|
| id | Text | Unique identifier for the video job (e.g., "video-abc123") |
| object | Text | Object type (always "video") |
| status | Text | Current status: `"queued"`, `"processing"`, `"completed"`, or `"failed"` |
| prompt | Text | The text prompt used to generate the video |
| model | Text | The model used for generation (e.g., "sora-2", "sora-2-pro") |
| seconds | Integer | Duration of the video in seconds (4, 8, or 12) |
| size | Text | Resolution of the video (e.g., "720x1280", "1280x720") |
| created_at | Integer | Unix timestamp when the video job was created |
| completed_at | Integer | Unix timestamp when the video completed (if completed) |
| expires_at | Integer | Unix timestamp when the video will expire |
| output_url | Text | URL to download the generated video (available when status is "completed") |
| error | Object | Error information if the job failed (contains message, code, etc.) |
| remixed_from_video_id | Text | ID of the original video if this is a remix |

## Constructor

**OpenAIVideo**(*object* : Object)

Creates a new OpenAIVideo instance from an API response object.

| Parameter | Type | Description |
|-----------|------|-------------|
| object | Object | The video object from the API response |

## Examples

### Check Video Status

```4d
var $result:=$client.videos.retrieve("video-abc123")

If ($result.success)
    var $video:=$result.video

    Case of
        : ($video.status="queued")
            ALERT("Video is waiting in queue")

        : ($video.status="processing")
            ALERT("Video is being generated...")

        : ($video.status="completed")
            ALERT("Video is ready!")
            var $url:=$video.output_url

        : ($video.status="failed")
            ALERT("Generation failed: "+$video.error.message)
    End case
End if
```

### Download Completed Video

```4d
var $result:=$client.videos.retrieve("video-abc123")

If ($result.success && ($result.video.status="completed"))
    var $video:=$result.video
    var $url:=$video.output_url

    // Download the video
    var $http:=4D.HTTPRequest.new($url)
    var $response:=$http.wait()

    If ($response.success)
        var $file:=File("/VIDEOS/"+$video.id+".mp4")
        $file.setContent($response.body)
        ALERT("Video downloaded to: "+$file.platformPath)
    End if
End if
```

### Monitor Generation Progress

```4d
var $videoId:="video-abc123"
var $completed:=False

While (Not($completed))
    var $result:=$client.videos.retrieve($videoId)

    If ($result.success)
        var $video:=$result.video

        Case of
            : ($video.status="completed")
                $completed:=True
                ALERT("Video ready: "+$video.output_url)

            : ($video.status="failed")
                $completed:=True
                ALERT("Error: "+$video.error.message)

            Else
                // Still processing
                ALERT("Status: "+$video.status)
                DELAY PROCESS(Current process; 60*5)  // Wait 5 seconds
        End case
    Else
        $completed:=True
    End if
End while
```

### Check Expiration

```4d
var $result:=$client.videos.retrieve("video-abc123")

If ($result.success)
    var $video:=$result.video

    If ($video.status="completed")
        var $now:=Timestamp
        var $timeRemaining:=$video.expires_at-$now

        If ($timeRemaining>0)
            var $hoursRemaining:=$timeRemaining\3600
            ALERT("Video expires in "+String($hoursRemaining)+" hours")
        Else
            ALERT("Video has expired")
        End if
    End if
End if
```

### Check Remix Relationship

```4d
var $result:=$client.videos.retrieve("video-xyz789")

If ($result.success)
    var $video:=$result.video

    If (Length($video.remixed_from_video_id)>0)
        ALERT("This is a remix of: "+$video.remixed_from_video_id)

        // Retrieve original video
        var $originalResult:=$client.videos.retrieve($video.remixed_from_video_id)
        If ($originalResult.success)
            ALERT("Original prompt: "+$originalResult.video.prompt)
        End if
    Else
        ALERT("This is an original video")
    End if
End if
```

### List Videos by Status

```4d
var $result:=$client.videos.list(cs.OpenAIVideoListParameters.new())

If ($result.success)
    var $completed:=$result.videos.query("status = :1"; "completed")
    var $processing:=$result.videos.query("status = :1"; "processing")
    var $failed:=$result.videos.query("status = :1"; "failed")

    ALERT("Completed: "+String($completed.length))
    ALERT("Processing: "+String($processing.length))
    ALERT("Failed: "+String($failed.length))
End if
```

### Video Metadata

```4d
var $result:=$client.videos.retrieve("video-abc123")

If ($result.success)
    var $video:=$result.video

    // Display all metadata
    ALERT("Video ID: "+$video.id)
    ALERT("Model: "+$video.model)
    ALERT("Duration: "+String($video.seconds)+" seconds")
    ALERT("Resolution: "+$video.size)
    ALERT("Prompt: "+$video.prompt)

    var $createdDate:=Timestamp to date($video.created_at)
    ALERT("Created: "+String($createdDate))
End if
```

## Status Lifecycle

1. **queued** - Video job is waiting in the generation queue
2. **processing** - Video is actively being generated
3. **completed** - Video generation finished successfully (output_url available)
4. **failed** - Video generation failed (error property contains details)

## See Also

- [OpenAIVideosAPI](OpenAIVideosAPI.md) - Videos API methods
- [OpenAIVideoResult](OpenAIVideoResult.md) - Single video result
- [OpenAIVideoListResult](OpenAIVideoListResult.md) - List result
- [OpenAIVideoParameters](OpenAIVideoParameters.md) - Video parameters
