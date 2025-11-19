# OpenAIAssistantsResult

The `OpenAIAssistantsResult` class contains the result of a single assistant operation (create, retrieve, or modify).

## Inherits

[OpenAIResult](OpenAIResult.md)

## Computed properties

| Property    | Type          | Description                                                                 |
|-------------|---------------|-----------------------------------------------------------------------------|
| `assistant` | [OpenAIAssistant](OpenAIAssistant.md) | Returns the assistant object from the API response. Returns `Null` if the response doesn't contain a valid assistant. |

## Example Usage

```4d
// Create an assistant
var $params:=cs.AIKit.OpenAIAssistantsParameters.new()
$params.model:="gpt-4o"
$params.name:="Math Tutor"

var $result:=$client.assistants.create($params)
var $assistant:=$result.assistant

// Retrieve assistant information
var $retrieveResult:=$client.assistants.retrieve($assistant.id)
```

## See also

- [OpenAIAssistantsAPI](OpenAIAssistantsAPI.md)
- [OpenAIAssistant](OpenAIAssistant.md)
