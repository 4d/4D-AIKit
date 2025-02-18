# OpenAIImagesAPI

The `OpenAIImagesAPI` class extends `OpenAIAPIResource` and provides functionalities to generate, edit, and create variations of images using OpenAI's API.

## Functions Description

### generate

Creates an image given a prompt.

| Argument     | Type                                           | Description                                          |
|--------------|------------------------------------------------|------------------------------------------------------|
| `$prompt`    | `Text`                                         | The prompt to use for image generation.              |
| `$parameters`| [OpenAIImageParameters](OpenAIImageParameters.md) | Parameters for image generation.                     |

#### Returns: [OpenAIImagesResult](OpenAIImagesResult.md)

## Example Usage

```4d
var $result := $client.image.generate($prompt; $parameters)
```