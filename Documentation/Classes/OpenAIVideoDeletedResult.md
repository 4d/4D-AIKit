# OpenAIVideoDeletedResult

The `OpenAIVideoDeletedResult` class extends [OpenAIResult](OpenAIResult.md) and provides access to video deletion operation results.

## Properties

### deleted

**deleted** : [OpenAIVideoDeleted](OpenAIVideoDeleted.md) (read-only)

Returns the video deletion status object from the API response, or `Null` if the operation failed or the response is invalid.

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

### Delete a Video

```4d
var $result:=$client.videos.delete("video-abc123")

If ($result.success)
    var $deleted:=$result.deleted

    ALERT("Video "+$deleted.id+" has been deleted")
    ALERT("Deletion confirmed: "+String($deleted.deleted))
Else
    // Handle errors
    var $error:=$result.errors.first()
    ALERT("Error deleting video: "+$error.message)
End if
```

### Delete and Verify

```4d
var $videoId:="video-abc123"
var $result:=$client.videos.delete($videoId)

If ($result.success)
    // Verify deletion
    If ($result.deleted.deleted)
        ALERT("Video successfully deleted")

        // Confirm by trying to retrieve it
        var $checkResult:=$client.videos.retrieve($videoId)

        If (Not($checkResult.success))
            ALERT("Confirmed: video no longer exists")
        End if
    End if
Else
    ALERT("Failed to delete video")
End if
```

### Batch Delete Old Videos

```4d
// List all videos
var $listResult:=$client.videos.list(cs.OpenAIVideoListParameters.new())

If ($listResult.success)
    var $thirtyDaysAgo:=Timestamp-(30*86400)

    For each ($video; $listResult.videos)
        // Delete videos older than 30 days
        If ($video.created_at<$thirtyDaysAgo)
            var $deleteResult:=$client.videos.delete($video.id)

            If ($deleteResult.success)
                ALERT("Deleted old video: "+$deleteResult.deleted.id)
            Else
                ALERT("Failed to delete: "+$video.id)
            End if
        End if
    End for each
End if
```

### Error Handling

```4d
var $result:=$client.videos.delete("invalid-video-id")

If (Not($result.success))
    For each ($error; $result.errors)
        // Log each error
        TRACE
        $error.message  // "Video not found"
        $error.code     // Error code
    End for each
Else
    ALERT("Video deleted: "+$result.deleted.id)
End if
```

### Check Response Metadata

```4d
var $result:=$client.videos.delete("video-abc123")

If ($result.success)
    // Check rate limits
    var $rateLimit:=$result.rateLimit

    ALERT("Remaining requests: "+String($rateLimit.remaining_requests))
    ALERT("Limit resets at: "+String($rateLimit.reset_requests_at))

    // Deletion info
    ALERT("Deleted video: "+$result.deleted.id)
End if
```

## See Also

- [OpenAIVideosAPI](OpenAIVideosAPI.md) - Videos API methods
- [OpenAIVideoDeleted](OpenAIVideoDeleted.md) - Deleted video data model
- [OpenAIResult](OpenAIResult.md) - Base result class
- [OpenAIVideoResult](OpenAIVideoResult.md) - Single video result
