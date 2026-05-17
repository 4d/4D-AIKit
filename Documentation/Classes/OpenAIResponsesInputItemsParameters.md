# OpenAIResponsesInputItemsParameters

The `OpenAIResponsesInputItemsParameters` class defines pagination options for listing the input items of a stored response.

## Inherits

- [OpenAIParameters](OpenAIParameters.md)

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `after` | Text | Cursor for pagination. |
| `include` | Collection | Additional fields to include in each returned input item. |
| `limit` | Integer | Maximum number of items to return. |
| `order` | Text | Sort order, `asc` or `desc`. |

## Example Usage

```4d
var $params:=cs.AIKit.OpenAIResponsesInputItemsParameters.new()
$params.limit:=20
$params.order:="asc"

var $result:=$client.responses.listInputItems("resp_abc123"; $params)
```

## See also

- [OpenAIResponsesAPI](OpenAIResponsesAPI.md)
- [OpenAIResponsesInputItemsResult](OpenAIResponsesInputItemsResult.md)
