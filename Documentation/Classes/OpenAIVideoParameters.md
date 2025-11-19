# OpenAIVideoParameters

The `OpenAIVideoParameters` class extends [OpenAIParameters](OpenAIParameters.md) and provides configuration options for video creation and remix operations.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| model | Text | `"sora-2"` | The model to use for generation. Options: `"sora-2"` or `"sora-2-pro"` |
| seconds | Integer | `4` | Duration of the video in seconds. Options: `4`, `8`, or `12` |
| size | Text | `"720x1280"` | Video resolution. Options: `"720x1280"`, `"1280x720"`, `"1024x1792"`, `"1792x1024"` |
| input_reference | 4D.File or 4D.Blob | `Null` | Optional image file to guide video generation |

## Inherited Properties

Inherits all properties from [OpenAIParameters](OpenAIParameters.md):
- `user` - Unique end-user identifier
- `timeout` - Request timeout in seconds
- `httpAgent` - Custom HTTP agent
- `maxRetries` - Maximum retry attempts
- `extraHeaders` - Additional HTTP headers
- `onTerminate`, `onResponse`, `onError` - Async callback functions

## Constructor

**OpenAIVideoParameters**(*object* : Object)

Creates a new instance with optional property initialization.

| Parameter | Type | Description |
|-----------|------|-------------|
| object | Object | Optional object with property values to initialize |

## Functions

### body()

**body**() : Object

Converts the parameters to an API request body format.

Returns an object containing all non-empty parameter values in the format expected by the OpenAI API.

> **Note:** The `input_reference` property is handled separately by the API method using multipart form-data encoding.

## Examples

### Basic Video Generation

```4d
var $params:=cs.OpenAIVideoParameters.new()
$params.model:="sora-2"
$params.seconds:=8
$params.size:="1280x720"

var $result:=$client.videos.create("A sunset over the ocean"; $params)
```

### With Object Constructor

```4d
var $params:=cs.OpenAIVideoParameters.new({
    model: "sora-2-pro";
    seconds: 12;
    size: "1792x1024"
})

var $result:=$client.videos.create("A cinematic aerial shot of a mountain range"; $params)
```

### With Input Reference Image

```4d
var $referenceImage:=File("/RESOURCES/scene.jpg")

var $params:=cs.OpenAIVideoParameters.new({
    model: "sora-2-pro";
    seconds: 4;
    size: "720x1280";
    input_reference: $referenceImage
})

var $result:=$client.videos.create("Animate this scene with gentle motion"; $params)
```

### With Async Callback

```4d
var $params:=cs.OpenAIVideoParameters.new({
    model: "sora-2";
    seconds: 8;
    onResponse: Formula(
        If ($1.success)
            ALERT("Video job created: "+$1.video.id)
        Else
            ALERT("Error: "+$1.errors.first().message)
        End if
    )
})

var $result:=$client.videos.create("A robot walking in a park"; $params)
// Function returns immediately, callback executes when complete
```

## See Also

- [OpenAIVideosAPI](OpenAIVideosAPI.md) - Videos API methods
- [OpenAIVideoResult](OpenAIVideoResult.md) - Video operation results
- [OpenAIParameters](OpenAIParameters.md) - Base parameters class
