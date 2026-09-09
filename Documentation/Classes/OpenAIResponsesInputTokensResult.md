# OpenAIResponsesInputTokensResult

The `OpenAIResponsesInputTokensResult` class contains the token count returned by the Responses API input-token counting endpoint.

## Inherits

- [OpenAIResult](OpenAIResult.md)

## Computed properties

| Property | Type | Description |
|----------|------|-------------|
| `input_tokens` | Integer | Number of input tokens counted for the request body. |
| `details` | Object | Additional details returned by the API, when available. |

## Example Usage

```4d
var $result:=$client.responses.countInputTokens("Explain why 42 is a special number."; {model: "gpt-5"})

If ($result.success)
    ALERT("Input tokens: "+String($result.input_tokens))
End if
```

## See also

- [OpenAIResponsesAPI](OpenAIResponsesAPI.md)
- [OpenAIResponsesParameters](OpenAIResponsesParameters.md)
