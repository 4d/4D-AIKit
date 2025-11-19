# OpenAIResponsesInputItemsResult

The `OpenAIResponsesInputItemsResult` class contains the paginated input items returned for a stored response.

## Inherits

- [OpenAIResult](OpenAIResult.md)

## Computed properties

| Property | Type | Description |
|----------|------|-------------|
| `items` | Collection | Raw input item objects returned by the API. |
| `first_id` | Text | ID of the first input item in the current page. |
| `last_id` | Text | ID of the last input item in the current page. |
| `has_more` | Boolean | Indicates whether more pages are available. |

## Example Usage

```4d
var $result:=$client.responses.listInputItems("resp_abc123")

If ($result.success)
    // $result.items contains the raw input item objects
End if
```

## See also

- [OpenAIResponsesAPI](OpenAIResponsesAPI.md)
- [OpenAIResponsesInputItemsParameters](OpenAIResponsesInputItemsParameters.md)
