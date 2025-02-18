# _OpenAIAsyncOptions

The `_OpenAIAsyncOptions` internal class provides function to handle asynchronously HTTP response and pass it to user configured formula.

## Properties

### HTTP Properties

| Property    | Type    |
|-------------|---------|
| method      | Text    |
| headers     | Object  |
| dataType    | Text    |
| body        | Variant |
| timeout     | Integer  |

## HTTP Properties

| Property    | Type    |
| client      | [OpenAI](OpenAI) |
| parameters  | [OpenAIChatCompletionParameters](OpenAIChatCompletionParameters) |
| result      | [OpenAIResult](OpenAIResult) |

## Functions

### onTerminate

On terminate send [OpenAIResult](OpenAIResult) to the callback "formula".

### onData

On data receive send [OpenAIChatCompletionsStreamResult](OpenAIChatCompletionsStreamResult) to the callback "formula".
