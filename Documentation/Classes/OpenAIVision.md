# OpenAIVision

## Functions

### `create($imageURL: Text) : cs.OpenAIVisionHelper`

This function creates a new instance of the [`OpenAIVisionHelper`](OpenAIVisionHelper.md) using the provided image URL.

| Parameter   | Type  | Description                   |
|-------------|-------|-------------------------------|
| `$imageURL` | Text  | The URL of the image to analyze. |

### Example Usage

```4d
$helper := $client.chat.vision.create("http://example.com/image.jpg")
```