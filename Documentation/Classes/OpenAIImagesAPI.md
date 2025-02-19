# OpenAIImagesAPI

The `OpenAIImagesAPI` provides functionalities to generate images using OpenAI's API.

https://platform.openai.com/docs/api-reference/images

## Functions

### generate

https://platform.openai.com/docs/api-reference/images/create

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