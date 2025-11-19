# OpenAIVideoResult

The `OpenAIVideoResult` class extends [OpenAIResult](OpenAIResult.md) and provides access to a single video operation result.

## Properties

### video

**video** : [OpenAIVideo](OpenAIVideo.md) (read-only)

Returns the video object from the API response, or `Null` if the operation failed or the response is invalid.

## Inherited Properties

Inherits all properties from [OpenAIResult](OpenAIResult.md):
- `request` - The underlying 4D.HTTPRequest object
- `success` - Boolean indicating if the request succeeded
- `terminated` - Boolean indicating if the request completed
- `errors` - Collection of error objects if any occurred
- `headers` - HTTP response headers
- `rateLimit` - Rate limit information
- `usage` - Token usage information (if applicable)

## Functions

Inherits all functions from [OpenAIResult](OpenAIResult.md):
- `throw()` - Throws an error if the operation failed

## Examples

### Create Video and Check Result

```4d
var $result:=$client.videos.create("A cat playing piano"; cs.OpenAIVideoParameters.new())

If ($result.success)
    var $video:=$result.video

    // Access video properties
    ALERT("Video ID: "+$video.id)
    ALERT("Status: "+$video.status)
    ALERT("Created: "+String($video.created_at))

    // Check if completed
    If ($video.status="completed")
        // Download video from $video.output_url
        var $downloadURL:=$video.output_url
    End if
Else
    // Handle errors
    var $error:=$result.errors.first()
    ALERT("Error: "+$error.message)
End if
```

### Retrieve Video and Handle States

```4d
var $result:=$client.videos.retrieve("video-abc123")

If ($result.success)
    var $video:=$result.video

    Case of
        : ($video.status="queued")
            ALERT("Video is queued for processing")

        : ($video.status="processing")
            ALERT("Video is being generated...")

        : ($video.status="completed")
            ALERT("Video is ready!")
            // Download from $video.output_url

        : ($video.status="failed")
            ALERT("Video generation failed: "+$video.error.message)
    End case
Else
    ALERT("Failed to retrieve video")
End if
```

### Remix Video

```4d
var $result:=$client.videos.remix("video-abc123"; "Make it sepia-toned")

If ($result.success)
    var $remixedVideo:=$result.video

    ALERT("Original video: "+$remixedVideo.remixed_from_video_id)
    ALERT("New video: "+$remixedVideo.id)
    ALERT("Status: "+$remixedVideo.status)
End if
```

### Check Rate Limits

```4d
var $result:=$client.videos.create("A dog running on the beach"; cs.OpenAIVideoParameters.new())

// Check rate limit information
var $rateLimit:=$result.rateLimit

ALERT("Remaining requests: "+String($rateLimit.remaining_requests))
ALERT("Limit resets at: "+String($rateLimit.reset_requests_at))
```

### Error Handling

```4d
var $result:=$client.videos.create(""; cs.OpenAIVideoParameters.new())

If (Not($result.success))
    For each ($error; $result.errors)
        // Log each error
        TRACE
        $error.message  // "Prompt cannot be empty"
        $error.code     // Error code
    End for each
End if
```

## See Also

- [OpenAIVideosAPI](OpenAIVideosAPI.md) - Videos API methods
- [OpenAIVideo](OpenAIVideo.md) - Video data model
- [OpenAIResult](OpenAIResult.md) - Base result class
- [OpenAIVideoListResult](OpenAIVideoListResult.md) - List result
