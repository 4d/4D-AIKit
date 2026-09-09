# _OpenAIAsyncOptions

The `_OpenAIAsyncOptions` internal class provides function to handle asynchronously HTTP response and pass it to user configured formula.

## Properties

### HTTP Properties

| Property    | Type    |
|-------------|---------|
| `method`      | Text    |
| `headers`     | Object  |
| `dataType`    | Text    |
| `body`        | Variant |
| `timeout     | Integer  |

### Class instances Properties

| Property    | Type    |
|-------------|---------|
| `client`      | [OpenAI](OpenAI.md) |
| `parameters`  | [OpenAIParameters](OpenAIParameters.md) |
| `result`      | [OpenAIResult](OpenAIResult.md) |

## Functions

### onTerminate()

On terminate send [OpenAIResult](OpenAIResult.md) to the callback "formula".

### onData()

On data receive send [OpenAIChatCompletionsStreamResult](OpenAIChatCompletionsStreamResult.md) for chat completions or [OpenAIResponsesStreamResult](OpenAIResponsesStreamResult.md) for Responses API streams to the callback "formula".
