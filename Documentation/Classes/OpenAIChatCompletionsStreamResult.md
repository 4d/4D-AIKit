# OpenAIChatCompletionsStreamResult

## Inherits

- [OpenAIResult](OpenAIResult.md)
 
## Properties

| Property  | Type                         | Description                                      |
|-----------|------------------------------|--------------------------------------------------|
| `data`      | Object                     | Contains the stream data sent by the server.    |

## Computed Properties

| Property   | Type                                   | Description                                                         |
|------------|----------------------------------------|---------------------------------------------------------------------|
| `choice`   | [OpenAIChoice](OpenAIChoice.md) | Returns a choice data, with a `delta` message.                             |
| `choices`  | Collection  | Returns a collection of [OpenAIChoice](OpenAIChoice.md) data, with `delta` messages.           |
| `stopReason` | Text      | Why the response stopped. See [stopReason](#stopreason).                            |

### stopReason

`stopReason` explains why the streamed response stopped, derived from the result itself (so it is
meaningful whether or not you go through [OpenAIChatHelper](OpenAIChatHelper.md)):

1. an explicit reason set by the agent loop (e.g. `"max_iterations"`, `"cancelled"`) wins;
2. otherwise the final [choice](OpenAIChoice.md)'s `finish_reason` verbatim (`"stop"`, `"length"`,
   `"tool_calls"`, `"content_filter"`, or any value the provider returns);
3. otherwise `"error"` if the request failed;
4. otherwise `""` while the stream is still in progress (no `finish_reason` yet).

See the [Agent loop](OpenAIChatHelper.md#agent-loop) section for the full list of values.

### Overridden properties

| Property     | Type                                   | Description                                                         |
|--------------|----------------------------------------|---------------------------------------------------------------------|
| `success`    | Boolean | Returns `True` if the streaming data was successfully decoded as an object. |
| `terminated` | Boolean  | A Boolean indicating whether the HTTP request was terminated. ie `onTerminate` called.          |
| `usage`      | Object   | Returns token usage information from the stream data (only available in the final chunk when `stream_options.include_usage` is set to `True`). |
| `errors`     | Collection | Returns a collection of errors found in the streamed data, the request, or the decoding step. |

### usage

The `usage` property returns an object containing token usage information, available only in the final streaming chunk when enabled via `stream_options.include_usage: True` in the request parameters.

The structure is the same as [OpenAIChatCompletionsResult](OpenAIChatCompletionsResult.md#usage):

| Field | Type | Description |
|-------|------|-------------|
| `prompt_tokens` | Integer | Number of tokens in the prompt. |
| `completion_tokens` | Integer | Number of tokens in the completion. |
| `total_tokens` | Integer | Total tokens used (prompt + completion). |
| `prompt_tokens_details` | Object | Breakdown of prompt tokens (optional). |
| `completion_tokens_details` | Object | Breakdown of completion tokens (optional). |

> **Note:** To receive usage information in streaming responses, you must set `stream_options: {include_usage: True}` in your request parameters. See [OpenAIChatCompletionsParameters](OpenAIChatCompletionsParameters.md) for details.
