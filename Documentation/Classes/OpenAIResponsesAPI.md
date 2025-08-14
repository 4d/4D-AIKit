# OpenAIResponsesAPI

The `OpenAIResponsesAPI` provides functionalities to create and manage responses using OpenAI's new Responses API.

https://platform.openai.com/docs/api-reference/responses

## Functions

### create()

Creates a model response for the given input.

#### Syntax

```4d
$result:=$client.responses.create($input; $parameters)
```

#### Parameters

- `$input` (Variant): Text, image, or file inputs to the model, used to generate a response
- `$parameters` ([OpenAIResponsesParameters](OpenAIResponsesParameters.md)): Parameters for the response generation

#### Returns

- [OpenAIResponsesResult](OpenAIResponsesResult.md): The response result

### retrieve()

Get a stored response.

#### Syntax

```4d
$result:=$client.responses.retrieve($responseID; $parameters)
```

#### Parameters

- `$responseID` (Text): The unique ID of the response
- `$parameters` ([OpenAIParameters](OpenAIParameters.md)): Optional request parameters

#### Returns

- [OpenAIResponsesResult](OpenAIResponsesResult.md): The response result

### delete()

Delete a stored response.

#### Syntax

```4d
$result:=$client.responses.delete($responseID; $parameters)
```

#### Parameters

- `$responseID` (Text): The unique ID of the response
- `$parameters` ([OpenAIParameters](OpenAIParameters.md)): Optional request parameters

#### Returns

- [OpenAIResult](OpenAIResult.md): The deletion result

### cancel()

Cancel a response that is currently being generated.

#### Syntax

```4d
$result:=$client.responses.cancel($responseID; $parameters)
```

#### Parameters

- `$responseID` (Text): The unique ID of the response
- `$parameters` ([OpenAIParameters](OpenAIParameters.md)): Optional request parameters

#### Returns

- [OpenAIResult](OpenAIResult.md): The cancellation result

## Properties

### input_items

- Type: [OpenAIResponseInputItemsAPI](OpenAIResponseInputItemsAPI.md)
- Access to the Response Input Items API for listing input items

## Example

```4d
var $client : cs.OpenAI
$client:=cs.OpenAI.new()

// Create a simple text response
var $parameters : cs.OpenAIResponsesParameters
$parameters:=cs.OpenAIResponsesParameters.new()
$parameters.model:="gpt-4o"
$parameters.instructions:="You are a helpful assistant."

var $result : cs.OpenAIResponsesResult
$result:=$client.responses.create("Hello, how are you?"; $parameters)

If ($result.success)
    ALERT($result.output_text)
End if
```

## See also

- [OpenAIResponsesParameters](OpenAIResponsesParameters.md)
- [OpenAIResponsesResult](OpenAIResponsesResult.md)
- [OpenAIResponse](OpenAIResponse.md)
