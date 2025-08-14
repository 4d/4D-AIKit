# OpenAIResponsesResult

The `OpenAIResponsesResult` provides functionality to handle response results from the OpenAI Responses API.

## Inherits

- [OpenAIResult](OpenAIResult.md)
 
## Properties

| Property | Type | Description |
|----------|------|-------------|
| `response` | [OpenAIResponse](OpenAIResponse.md) | The response object |
| `output` | Collection | Collection of response output items |
| `output_text` | Text | Convenience property that aggregates all output_text items |

## Example

```4d
var $client : cs.OpenAI
$client:=cs.OpenAI.new()

var $parameters : cs.OpenAIResponsesParameters
$parameters:=cs.OpenAIResponsesParameters.new()

var $result : cs.OpenAIResponsesResult
$result:=$client.responses.create("Hello!"; $parameters)

If ($result.success)
    // Get the full response object
    var $response : cs.OpenAIResponse
    $response:=$result.response
    
    // Or get just the text output
    var $text : Text
    $text:=$result.output_text
    
    ALERT($text)
End if
```

## See also

- [OpenAIResponsesAPI](OpenAIResponsesAPI.md)
- [OpenAIResponse](OpenAIResponse.md)
- [OpenAIResult](OpenAIResult.md)
