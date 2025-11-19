# OpenAIAssistantDeletedResult

The `OpenAIAssistantDeletedResult` class contains the result of a delete assistant operation.

## Inherits

[OpenAIResult](OpenAIResult.md)

## Computed properties

| Property  | Type          | Description                                                                 |
|-----------|---------------|-----------------------------------------------------------------------------|
| `deleted` | [OpenAIAssistantDeleted](OpenAIAssistantDeleted.md) | Returns the deletion status object from the API response. Returns `Null` if the response doesn't contain valid deletion information. |

## Example Usage

```4d
var $result:=$client.assistants.delete("asst_abc123")

If ($result.success)
    var $status:=$result.deleted

    If ($status.deleted)
        ALERT("Assistant "+$status.id+" was deleted successfully")
    End if
End if
```

## See also

- [OpenAIAssistantsAPI](OpenAIAssistantsAPI.md)
- [OpenAIAssistantDeleted](OpenAIAssistantDeleted.md)
