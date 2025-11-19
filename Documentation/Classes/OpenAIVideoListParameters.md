# OpenAIVideoListParameters

The `OpenAIVideoListParameters` class extends [OpenAIParameters](OpenAIParameters.md) and provides pagination options for listing videos.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| after | Text | `""` | Cursor for pagination - ID of the last video from the previous page |
| limit | Integer | `20` | Number of videos to retrieve per page (max: 100) |
| order | Text | `"desc"` | Sort order by creation timestamp. Options: `"asc"` or `"desc"` |

## Inherited Properties

Inherits all properties from [OpenAIParameters](OpenAIParameters.md):
- `user` - Unique end-user identifier
- `timeout` - Request timeout in seconds
- `httpAgent` - Custom HTTP agent
- `maxRetries` - Maximum retry attempts
- `extraHeaders` - Additional HTTP headers
- `onTerminate`, `onResponse`, `onError` - Async callback functions

## Constructor

**OpenAIVideoListParameters**(*object* : Object)

Creates a new instance with optional property initialization.

| Parameter | Type | Description |
|-----------|------|-------------|
| object | Object | Optional object with property values to initialize |

## Functions

### body()

**body**() : Object

Converts the parameters to API query parameter format.

Returns an object containing all non-empty parameter values for the list request.

## Examples

### List Most Recent Videos

```4d
var $params:=cs.OpenAIVideoListParameters.new({
    limit: 10;
    order: "desc"
})

var $result:=$client.videos.list($params)

If ($result.success)
    For each ($video; $result.videos)
        // Process each video
    End for each
End if
```

### Paginated Listing

```4d
var $params:=cs.OpenAIVideoListParameters.new({
    limit: 20;
    order: "desc"
})

var $allVideos:=[]
var $hasMore:=True

While ($hasMore)
    var $result:=$client.videos.list($params)

    If ($result.success)
        $allVideos.combine($result.videos)
        $hasMore:=$result.has_more

        If ($hasMore)
            // Set cursor for next page
            $params.after:=$result.last_id
        End if
    Else
        $hasMore:=False
    End if
End while

// $allVideos now contains all videos
```

### List Oldest Videos First

```4d
var $params:=cs.OpenAIVideoListParameters.new({
    limit: 5;
    order: "asc"
})

var $result:=$client.videos.list($params)

If ($result.success)
    // Get the oldest 5 videos
    var $oldestVideos:=$result.videos
End if
```

## Pagination Workflow

1. Make initial request with desired `limit` and `order`
2. Check `has_more` property in the result
3. If more results exist, use `last_id` from result as `after` parameter
4. Make next request with updated `after` cursor
5. Repeat until `has_more` is `False`

## See Also

- [OpenAIVideosAPI](OpenAIVideosAPI.md) - Videos API methods
- [OpenAIVideoListResult](OpenAIVideoListResult.md) - List result with pagination
- [OpenAIParameters](OpenAIParameters.md) - Base parameters class
