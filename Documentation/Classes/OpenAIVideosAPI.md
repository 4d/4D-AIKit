# OpenAIVideosAPI

The `OpenAIVideosAPI` class provides functionalities to generate and manipulate videos using OpenAI's Sora API. Videos can be created from text prompts, remixed with new prompts, and managed through listing and retrieval operations.

> **Note:** This API is only compatible with OpenAI's Sora models. Other providers listed in the [compatible providers](../compatible-openai.md) documentation do not support video generation.

API Reference: <https://platform.openai.com/docs/api-reference/videos>

## Available Models

- `sora-2`: Standard video generation model (default)
- `sora-2-pro`: Enhanced video generation model with higher quality

## Functions

### create()

**create**(*prompt* : Text; *parameters* : cs.OpenAIVideoParameters) : cs.OpenAIVideoResult

Create a video based on a text prompt.

**Endpoint:** `POST https://api.openai.com/v1/videos`

| Parameter       | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| *prompt*        | Text                           | **Required.** Text describing the video to generate.     |
| *parameters*    | [OpenAIVideoParameters](OpenAIVideoParameters.md) | Optional parameters including model, duration, size, and input reference. |
| Function result | [OpenAIVideoResult](OpenAIVideoResult.md) | The video job result with status tracking. |

**Throws:** An error if `prompt` is empty.

#### Response

Returns a video job object with:
- `id`: Unique identifier for the video job
- `status`: Current status (`queued`, `processing`, `completed`, or `failed`)
- `output_url`: Download URL (available when status is `completed`)
- `created_at`: Unix timestamp of creation
- `expires_at`: Unix timestamp when the video expires

#### Example

```4d
var $params:=cs.OpenAIVideoParameters.new({
    model: "sora-2";
    seconds: 8;
    size: "1280x720"
})

var $result:=$client.videos.create("A cat playing piano in a cozy living room"; $params)

If ($result.success)
    var $video:=$result.video
    // $video.id -> "video-abc123"
    // $video.status -> "queued"
    // $video.prompt -> "A cat playing piano in a cozy living room"
    // $video.created_at -> 1699564800
End if
```

#### With Input Reference Image

```4d
var $image:=File("/RESOURCES/reference-image.jpg")

var $params:=cs.OpenAIVideoParameters.new({
    model: "sora-2-pro";
    seconds: 4;
    size: "720x1280";
    input_reference: $image
})

var $result:=$client.videos.create("Animate this scene with gentle camera movement"; $params)

If ($result.success)
    var $video:=$result.video
    // Video generation started with image reference
End if
```

### remix()

**remix**(*videoId* : Text; *prompt* : Text; *parameters* : cs.OpenAIVideoParameters) : cs.OpenAIVideoResult

Create a remixed version of an existing completed video.

**Endpoint:** `POST https://api.openai.com/v1/videos/{video_id}/remix`

| Parameter       | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| *videoId*       | Text                           | **Required.** The ID of the video to remix.              |
| *prompt*        | Text                           | **Required.** Text describing the remix modifications.   |
| *parameters*    | [OpenAIVideoParameters](OpenAIVideoParameters.md) | Optional parameters for the remix operation.             |
| Function result | [OpenAIVideoResult](OpenAIVideoResult.md) | The new video job result with remix tracking. |

**Throws:** An error if `videoId` or `prompt` is empty.

#### Response

Returns a new video job object with:
- `remixed_from_video_id`: ID of the original video

#### Example

```4d
var $result:=$client.videos.remix("video-abc123"; "Make it black and white with a vintage film effect")

If ($result.success)
    var $remixedVideo:=$result.video
    // $remixedVideo.id -> "video-xyz789"
    // $remixedVideo.remixed_from_video_id -> "video-abc123"
    // $remixedVideo.status -> "queued"
End if
```

### list()

**list**(*parameters* : cs.OpenAIVideoListParameters) : cs.OpenAIVideoListResult

List all videos for the organization with optional pagination.

**Endpoint:** `GET https://api.openai.com/v1/videos`

| Parameter       | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| *parameters*    | [OpenAIVideoListParameters](OpenAIVideoListParameters.md) | Parameters for pagination and filtering. |
| Function result | [OpenAIVideoListResult](OpenAIVideoListResult.md) | Paginated list of video jobs. |

#### Pagination Support

The result includes:
- `videos`: Collection of video objects
- `has_more`: Boolean indicating if more results are available
- `first_id`: ID of the first video in the list
- `last_id`: ID of the last video (use as `after` cursor for next page)

#### Example

```4d
// Get first page
var $params:=cs.OpenAIVideoListParameters.new({
    limit: 10;
    order: "desc"
})

var $result:=$client.videos.list($params)

If ($result.success)
    For each ($video; $result.videos)
        // Process each video
        // $video.id -> "video-abc123"
        // $video.status -> "completed"
    End for each

    // Get next page if available
    If ($result.has_more)
        $params.after:=$result.last_id
        var $nextResult:=$client.videos.list($params)
        // Process next page...
    End if
End if
```

### retrieve()

**retrieve**(*videoId* : Text; *parameters* : cs.OpenAIParameters) : cs.OpenAIVideoResult

Retrieve details of a specific video by ID.

**Endpoint:** `GET https://api.openai.com/v1/videos/{video_id}`

| Parameter       | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| *videoId*       | Text                           | **Required.** The ID of the video to retrieve.           |
| *parameters*    | [OpenAIParameters](OpenAIParameters.md) | Optional parameters for the request.                     |
| Function result | [OpenAIVideoResult](OpenAIVideoResult.md) | The video job result. |

**Throws:** An error if `videoId` is empty.

#### Example

```4d
var $result:=$client.videos.retrieve("video-abc123")

If ($result.success)
    var $video:=$result.video

    Case of
        : ($video.status="completed")
            // Download the video
            var $url:=$video.output_url

        : ($video.status="failed")
            // Handle error
            var $errorMsg:=$video.error.message

        : ($video.status="processing")
            // Still processing, check again later

        : ($video.status="queued")
            // Waiting in queue
    End case
End if
```

## Video Duration Options

Videos can be generated with the following durations (specified in seconds):
- `4` seconds (default)
- `8` seconds
- `12` seconds

## Video Resolution Options

Videos can be generated with the following resolutions:
- `720x1280` - Portrait (default)
- `1280x720` - Landscape
- `1024x1792` - Tall portrait
- `1792x1024` - Wide landscape

## Polling for Completion

Video generation is asynchronous. Poll the retrieve endpoint to check the status:

```4d
var $videoId:="video-abc123"
var $completed:=False

While (Not($completed))
    var $result:=$client.videos.retrieve($videoId)

    If ($result.success)
        Case of
            : ($result.video.status="completed")
                $completed:=True
                // Download video from $result.video.output_url

            : ($result.video.status="failed")
                $completed:=True
                // Handle error: $result.video.error

            Else
                // Still processing, wait before next check
                DELAY PROCESS(Current process; 60*5)  // Wait 5 seconds
        End case
    Else
        $completed:=True  // Error occurred
    End if
End while
```

## See Also

- [OpenAI](OpenAI.md) - Main client class
- [OpenAIVideoParameters](OpenAIVideoParameters.md) - Video generation parameters
- [OpenAIVideoListParameters](OpenAIVideoListParameters.md) - List pagination parameters
- [OpenAIVideoResult](OpenAIVideoResult.md) - Single video result
- [OpenAIVideoListResult](OpenAIVideoListResult.md) - List result with pagination
- [OpenAIVideo](OpenAIVideo.md) - Video data model
