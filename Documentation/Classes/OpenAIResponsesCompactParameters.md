# OpenAIResponsesCompactParameters

The `OpenAIResponsesCompactParameters` class defines the optional parameters used to compact an existing response.

## Inherits

- [OpenAIParameters](OpenAIParameters.md)

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `model` | Text | Model to use for the compacted response. |
| `prompt_cache_key` | Text | Optional prompt cache key for the compacted response. |

## Example Usage

```4d
var $params:=cs.AIKit.OpenAIResponsesCompactParameters.new()
$params.model:="gpt-5"

var $result:=$client.responses.compact("resp_abc123"; $params)
```

## See also

- [OpenAIResponsesAPI](OpenAIResponsesAPI.md)
- [OpenAIParameters](OpenAIParameters.md)
