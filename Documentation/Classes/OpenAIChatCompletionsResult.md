# OpenAIChatCompletionsResult

## Inherits

- [OpenAIResult](OpenAIResult.md)

## Computed properties

| Property  | Type          | Description                                                                 |
|-----------|---------------|-----------------------------------------------------------------------------|
| `choices` | Collection    | Returns a collection of [OpenAIChoice](OpenAIChoice.md) from the OpenAI response. |
| `choice`  | OpenAIChoice  | Returns the first [OpenAIChoice](OpenAIChoice.md) from the choices collection.    |
| `stopReason` | Text       | Why the response stopped. See [stopReason](#stopreason).                          |
| `usage`   | Object        | Returns token usage information (inherited from [OpenAIResult](OpenAIResult.md)). |

### stopReason

`stopReason` explains why the response stopped, derived from the result itself (so it is
meaningful whether or not you go through [OpenAIChatHelper](OpenAIChatHelper.md)):

1. an explicit reason set by the agent loop (e.g. `"max_iterations"`, `"cancelled"`) wins;
2. otherwise the [choice](OpenAIChoice.md)'s `finish_reason` verbatim (`"stop"`, `"length"`,
   `"tool_calls"`, `"content_filter"`, or any value the provider returns);
3. otherwise `"error"` if the request failed;
4. otherwise `""` if the response is not terminated.

The agent loop uses this property both ways: it sets it (loop-level reasons) and reads it
(deriving the model's `finish_reason`). See the [Agent loop](OpenAIChatHelper.md#agent-loop)
section for the full list of values.

### usage

The `usage` property returns an object containing token usage information for chat completions.

| Field | Type | Description |
|-------|------|-------------|
| `prompt_tokens` | Integer | Number of tokens in the prompt. |
| `completion_tokens` | Integer | Number of tokens in the completion. |
| `total_tokens` | Integer | Total tokens used (prompt + completion). |
| `prompt_tokens_details` | Object | Breakdown of prompt tokens (optional). |
| `completion_tokens_details` | Object | Breakdown of completion tokens (optional). |

#### prompt_tokens_details

| Field | Type | Description |
|-------|------|-------------|
| `cached_tokens` | Integer | Number of tokens served from cache. |
| `audio_tokens` | Integer | Number of audio tokens (if applicable). |

#### completion_tokens_details

| Field | Type | Description |
|-------|------|-------------|
| `reasoning_tokens` | Integer | Tokens used for reasoning (e.g., o1 models). |
| `audio_tokens` | Integer | Number of audio tokens (if applicable). |
| `accepted_prediction_tokens` | Integer | Tokens from accepted predictions. |
| `rejected_prediction_tokens` | Integer | Tokens from rejected predictions. |

**Example response:**

```json
{
  "prompt_tokens": 19,
  "completion_tokens": 10,
  "total_tokens": 29,
  "prompt_tokens_details": {
    "cached_tokens": 0,
    "audio_tokens": 0
  },
  "completion_tokens_details": {
    "reasoning_tokens": 0,
    "audio_tokens": 0,
    "accepted_prediction_tokens": 0,
    "rejected_prediction_tokens": 0
  }
}
```

> **Note:** The `*_tokens_details` objects may not be present in all responses or from all providers.

## See also

- [OpenAIChatCompletionsAPI](OpenAIChatCompletionsAPI.md)
