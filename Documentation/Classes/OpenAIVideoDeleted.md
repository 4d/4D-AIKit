# OpenAIVideoDeleted

The `OpenAIVideoDeleted` class represents the metadata of a deleted video from the OpenAI Videos API.

## Properties

| Property | Type | Description |
|----------|------|-------------|
| id | Text | Unique identifier for the deleted video (e.g., "video-abc123") |
| deleted | Boolean | Indicates if the video was successfully deleted (always `True`) |
| object | Text | Object type (always "video") |

## Constructor

**OpenAIVideoDeleted**(*object* : Object)

Creates a new OpenAIVideoDeleted instance from an API response object.

| Parameter | Type | Description |
|-----------|------|-------------|
| object | Object | The deleted video object from the API response |

## Examples

### Delete a Video

```4d
var $result:=$client.videos.delete("video-abc123")

If ($result.success)
    var $deleted:=$result.deleted

    // Access deletion metadata
    ALERT("Deleted video ID: "+$deleted.id)
    ALERT("Deletion confirmed: "+String($deleted.deleted))
    ALERT("Object type: "+$deleted.object)
End if
```

### Verify Deletion

```4d
var $deleteResult:=$client.videos.delete("video-abc123")

If ($deleteResult.success && $deleteResult.deleted.deleted)
    ALERT("Video successfully deleted")

    // Try to retrieve the deleted video (should fail)
    var $retrieveResult:=$client.videos.retrieve("video-abc123")

    If (Not($retrieveResult.success))
        ALERT("Video no longer exists")
    End if
End if
```

### Conditional Deletion

```4d
// Get video details first
var $video:=$client.videos.retrieve("video-abc123").video

If ($video#Null)
    // Only delete if video is not completed or if it's old
    If (($video.status#"completed") | ($video.created_at<(Timestamp-86400)))
        var $result:=$client.videos.delete($video.id)

        If ($result.success)
            ALERT("Video "+$result.deleted.id+" has been deleted")
        End if
    End if
End if
```

## See Also

- [OpenAIVideosAPI](OpenAIVideosAPI.md) - Videos API methods
- [OpenAIVideoDeletedResult](OpenAIVideoDeletedResult.md) - Delete result wrapper
- [OpenAIVideo](OpenAIVideo.md) - Video data model
