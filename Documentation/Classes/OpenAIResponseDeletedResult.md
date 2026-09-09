# OpenAIResponseDeletedResult

The `OpenAIResponseDeletedResult` class contains the result of a response deletion operation.

## Inherits

- [OpenAIResult](OpenAIResult.md)

## Computed properties

| Property  | Type | Description |
|-----------|------|-------------|
| `deleted` | [OpenAIResponseDeleted](OpenAIResponseDeleted.md) | Returns the response deletion result from the API response. Returns `Null` if the response does not contain a valid result. |

## Example Usage

```4d
var $result:=$client.responses.delete("resp_abc123")
var $deletionStatus:=$result.deleted

If ($deletionStatus#Null) && $deletionStatus.deleted
    ALERT("Response deleted")
End if
```

## See also

- [OpenAIResponsesAPI](OpenAIResponsesAPI.md)
- [OpenAIResponseDeleted](OpenAIResponseDeleted.md)
