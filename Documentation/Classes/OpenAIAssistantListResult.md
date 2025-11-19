# OpenAIAssistantListResult

The `OpenAIAssistantListResult` class contains the result of a list assistants operation with pagination support.

## Inherits

[OpenAIResult](OpenAIResult.md)

## Computed properties

| Property     | Type       | Description                                                                 |
|-------------|------------|-----------------------------------------------------------------------------|
| `assistants` | Collection | Returns a collection of [OpenAIAssistant](OpenAIAssistant.md) objects from the API response. Returns an empty collection if the response doesn't contain valid assistants. |
| `firstId`    | Text       | Returns the ID of the first assistant in the list. Useful for pagination with the `before` parameter. Returns empty string if the list is empty. |
| `lastId`     | Text       | Returns the ID of the last assistant in the list. Useful for pagination with the `after` parameter. Returns empty string if the list is empty. |
| `hasMore`    | Boolean    | Returns `True` if there are more assistants available beyond this page. Use with `lastId` to fetch the next page. |

## Example Usage

```4d
var $params:=cs.AIKit.OpenAIAssistantListParameters.new()
$params.limit:=20

var $result:=$client.assistants.list($params)

If ($result.success)
    var $assistants:=$result.assistants

    For each ($assistant; $assistants)
        // Process each assistant
    End for each

    // Check if there are more results
    If ($result.hasMore)
        // Fetch next page
        $params.after:=$result.lastId
        var $nextPage:=$client.assistants.list($params)
    End if
End if
```

## See also

- [OpenAIAssistantsAPI](OpenAIAssistantsAPI.md)
- [OpenAIAssistant](OpenAIAssistant.md)
- [OpenAIAssistantListParameters](OpenAIAssistantListParameters.md)
