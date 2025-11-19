# OpenAIVideoListResult

The `OpenAIVideoListResult` class extends [OpenAIResult](OpenAIResult.md) and provides access to paginated video list results.

## Properties

### videos

**videos** : Collection of [OpenAIVideo](OpenAIVideo.md) (read-only)

Returns a collection of video objects from the API response, or an empty collection if the operation failed or no videos exist.

### has_more

**has_more** : Boolean (read-only)

Indicates whether more results are available for pagination.

Returns `True` if additional videos can be retrieved using the `after` parameter in the next request, `False` otherwise.

### first_id

**first_id** : Text (read-only)

Returns the ID of the first video in the current page, or an empty string if no videos exist.

### last_id

**last_id** : Text (read-only)

Returns the ID of the last video in the current page. Use this value as the `after` parameter in [OpenAIVideoListParameters](OpenAIVideoListParameters.md) to retrieve the next page.

Returns an empty string if no videos exist.

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

### List Videos

```4d
var $params:=cs.OpenAIVideoListParameters.new({
    limit: 10;
    order: "desc"
})

var $result:=$client.videos.list($params)

If ($result.success)
    ALERT("Found "+String($result.videos.length)+" videos")

    For each ($video; $result.videos)
        // Process each video
        ALERT("Video: "+$video.id+" - Status: "+$video.status)
    End for each
End if
```

### Pagination Example

```4d
var $params:=cs.OpenAIVideoListParameters.new({
    limit: 20;
    order: "desc"
})

var $page:=1
var $result:=$client.videos.list($params)

While ($result.success)
    ALERT("Page "+String($page)+": "+String($result.videos.length)+" videos")

    For each ($video; $result.videos)
        // Process each video
    End for each

    // Check if more pages exist
    If ($result.has_more)
        // Get next page using last_id as cursor
        $params.after:=$result.last_id
        $result:=$client.videos.list($params)
        $page:=$page+1
    Else
        break  // No more pages
    End if
End while
```

### Collect All Videos

```4d
var $params:=cs.OpenAIVideoListParameters.new({
    limit: 50;
    order: "desc"
})

var $allVideos:=[]
var $result:=$client.videos.list($params)

While ($result.success && ($result.videos.length>0))
    // Add current page to collection
    $allVideos.combine($result.videos)

    // Check for next page
    If ($result.has_more)
        $params.after:=$result.last_id
        $result:=$client.videos.list($params)
    Else
        break
    End if
End while

ALERT("Total videos: "+String($allVideos.length))
```

### Filter Completed Videos

```4d
var $result:=$client.videos.list(cs.OpenAIVideoListParameters.new())

If ($result.success)
    var $completedVideos:=$result.videos.query("status = :1"; "completed")

    ALERT("Completed videos: "+String($completedVideos.length))

    For each ($video; $completedVideos)
        // Download or process completed videos
        var $url:=$video.output_url
    End for each
End if
```

### Check Pagination Info

```4d
var $result:=$client.videos.list(cs.OpenAIVideoListParameters.new({limit: 5}))

If ($result.success)
    ALERT("Videos in this page: "+String($result.videos.length))
    ALERT("First ID: "+$result.first_id)
    ALERT("Last ID: "+$result.last_id)
    ALERT("Has more pages: "+String($result.has_more))

    If ($result.has_more)
        ALERT("Use after='"+$result.last_id+"' to get next page")
    End if
End if
```

## Pagination Workflow

1. Create [OpenAIVideoListParameters](OpenAIVideoListParameters.md) with desired `limit` and `order`
2. Call `videos.list()` to get first page
3. Process `videos` collection
4. Check `has_more` property
5. If `True`, set `after` parameter to `last_id` value
6. Repeat steps 2-5 until `has_more` is `False`

## See Also

- [OpenAIVideosAPI](OpenAIVideosAPI.md) - Videos API methods
- [OpenAIVideo](OpenAIVideo.md) - Video data model
- [OpenAIVideoListParameters](OpenAIVideoListParameters.md) - List parameters
- [OpenAIResult](OpenAIResult.md) - Base result class
