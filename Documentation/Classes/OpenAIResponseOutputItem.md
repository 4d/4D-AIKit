# OpenAIResponseOutputItem

The `OpenAIResponseOutputItem` class represents an output item from a response in the OpenAI Responses API.

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `type` | Text | The type of the output item (e.g., "message") |
| `role` | Text | The role of the message (e.g., "assistant") |
| `content` | Collection | The content of the output item |
| `id` | Text | Unique identifier for this output item |
| `refusal` | Text | Any refusal message if the model refuses to respond |

## Computed Properties

| Property | Type | Description |
|----------|------|-------------|
| `text` | Text | Convenience property that extracts and concatenates all text content |

## Example

```4d
var $result : cs.OpenAIResponsesResult
$result:=$client.responses.create("Hello!"; $parameters)

If ($result.success)
    var $output : Collection
    $output:=$result.output
    
    For each ($outputItem; $output)
        var $item : cs.OpenAIResponseOutputItem
        $item:=$outputItem
        
        ALERT("Type: "+$item.type)
        ALERT("Role: "+$item.role)
        ALERT("Text: "+$item.text)
    End for each
End if
```

## See also

- [OpenAIResponse](OpenAIResponse.md)
- [OpenAIResponsesResult](OpenAIResponsesResult.md)
