# OpenAIResponseInputItemsAPI

The `OpenAIResponseInputItemsAPI` provides functionality to manage input items for responses in the OpenAI Responses API.

<https://platform.openai.com/docs/api-reference/responses/input-items>

## Functions

### list()

List input items for a response.

```4d
$result:=$client.responses.input_items.list($responseID; $parameters)
```

#### Parameters

- `$responseID` (Text): The unique ID of the response
- `$parameters` ([OpenAIParameters](OpenAIParameters.md)): Optional request parameters

#### Returns

- [OpenAIResult](OpenAIResult.md): The list of input items

## Example

```4d
var $client : cs.OpenAI
$client:=cs.OpenAI.new()

// List input items for a response
var $result : cs.OpenAIResult
$result:=$client.responses.input_items.list("resp_123")

If ($result.success)
    // Process input items
End if
```

## See also

- [OpenAIResponsesAPI](OpenAIResponsesAPI.md)
- [OpenAIResult](OpenAIResult.md)
