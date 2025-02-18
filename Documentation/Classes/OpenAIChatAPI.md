# OpenAIChatAPI

The `OpenAIChatAPI` class provides an interface to interact with OpenAI's chat based functionality, leveraging completion and vision capabilities.

## Properties

| Property      | Type                               | Description                                             |
|---------------|------------------------------------|--------------------------------------------------------|
| `completions`   | [OpenAIChatCompletionsAPI](OpenAIChatCompletions)    | An instance that handles chat completions requests.    |
| `vision`        | [OpenAIVision](OpenAIVision)             | An helper instance that handles vision-related requests.       |

## Function

### create($systemPrompt: Text): OpenAIChatHelper

Create a [OpenAIChatHelper](OpenAIChatHelper)
