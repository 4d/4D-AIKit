# OpenAIResponsesAPI

The `OpenAIResponsesAPI` class is designed for managing responses with OpenAI's API. It provides methods to create, retrieve, update, and delete responses. The Responses API supports text and image inputs with text or JSON outputs, making it suitable for modern AI applications.

https://platform.openai.com/docs/api-reference/responses

## Functions

### create()

**create**(*input* : Variant ; *parameters* : [OpenAIResponsesParameters](OpenAIResponsesParameters.md)) : [OpenAIResponsesResult](OpenAIResponsesResult.md)

| Parameter         | Type                                      | Description                               |
|-------------------|-------------------------------------------|-------------------------------------------|
| *input*           | Variant                                   | Text, image, or file inputs for the model. Can be a string or collection. |
| *parameters*      | [OpenAIResponsesParameters](OpenAIResponsesParameters.md) | The parameters for the response request. |
| Function result   | [OpenAIResponsesResult](OpenAIResponsesResult.md) | The result of the response request. |

Creates a model response supporting text and image inputs with text or JSON outputs.

https://platform.openai.com/docs/api-reference/responses/create

#### Example Usage

Basic text response:

```4d
var $client:=cs.AIKit.OpenAI.new("your-api-key")

var $result:=$client.responses.create("Hello, how are you?"; {model: "gpt-5"})
var $text:=$result.outputText
```

With instructions and conversation:

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.model:="gpt-5"
$params.instructions:="You are a helpful assistant."
$params.conversation:="conv_123"

var $result:=$client.responses.create("What's the weather like?"; $params)
var $text:=$result.response.outputText
```

With streaming (callback receives [OpenAIResponsesStreamResult](OpenAIResponsesStreamResult.md)):

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.model:="gpt-5"
$params.stream:=True
$params.onData:=Formula(_handleResponsesStream($1))

// _handleResponsesStream($event)
// If ($event.event="response.output_text.delta")
//     // $event.data.delta contains the next text chunk
// End if

var $result:=$client.responses.create("Tell me a story"; $params)
```

Multi-turn conversation:

```4d
// First turn
var $result1:=$client.responses.create("What is 2+2?"; {model: "gpt-5"; conversation: "my-conv"})
var $responseId:=$result1.response.id

// Second turn - reference previous response
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.model:="gpt-5"
$params.conversation:="my-conv"
$params.previous_response_id:=$responseId

var $result2:=$client.responses.create("What about 3+3?"; $params)
```

### retrieve()

**retrieve**(*responseID* : Text; *parameters* : OpenAIParameters) : [OpenAIResponsesResult](OpenAIResponsesResult.md)

| Parameter         | Type                                      | Description                               |
|-------------------|-------------------------------------------|-------------------------------------------|
| *responseID*      | Text                                      | The ID of the response to retrieve.       |
| *parameters*      | [OpenAIParameters](OpenAIParameters.md)   | Additional parameters for the request.    |
| Function result   | [OpenAIResponsesResult](OpenAIResponsesResult.md) | The retrieved response object.      |

Get a stored response.

https://platform.openai.com/docs/api-reference/responses/retrieve

#### Example Usage

```4d
var $result:=$client.responses.retrieve("resp_abc123")
var $response:=$result.response
```

### listInputItems()

**listInputItems**(*responseID* : Text; *parameters* : [OpenAIResponsesInputItemsParameters](OpenAIResponsesInputItemsParameters.md)) : [OpenAIResponsesInputItemsResult](OpenAIResponsesInputItemsResult.md)

Returns the input items of a stored response.

https://developers.openai.com/api/reference/resources/responses/methods/input-items

```4d
var $result:=$client.responses.listInputItems("resp_abc123")
// $result.items contains the raw input item objects
```

### update()

**update**(*responseID* : Text; *metadata* : Object; *parameters* : OpenAIParameters) : [OpenAIResponsesResult](OpenAIResponsesResult.md)

| Parameter         | Type                                      | Description                               |
|-------------------|-------------------------------------------|-------------------------------------------|
| *responseID*      | Text                                      | The ID of the response to update.         |
| *metadata*        | Object                                    | Metadata to update the response with.     |
| *parameters*      | [OpenAIParameters](OpenAIParameters.md)   | Additional parameters for the request.    |
| Function result   | [OpenAIResponsesResult](OpenAIResponsesResult.md) | The updated response object.        |

Modify a stored response.

https://platform.openai.com/docs/api-reference/responses/update

#### Example Usage

```4d
var $metadata:={user_id: "user123"; session: "session456"}
var $result:=$client.responses.update("resp_abc123"; $metadata)
```

### cancel()

**cancel**(*responseID* : Text; *parameters* : OpenAIParameters) : [OpenAIResponsesResult](OpenAIResponsesResult.md)

Cancels an in-progress background response.

https://developers.openai.com/api/reference/resources/responses/methods/cancel

```4d
var $result:=$client.responses.cancel("resp_abc123")
```

### countInputTokens()

**countInputTokens**(*input* : Variant ; *parameters* : [OpenAIResponsesParameters](OpenAIResponsesParameters.md)) : [OpenAIResponsesInputTokensResult](OpenAIResponsesInputTokensResult.md)

Counts the number of input tokens for a Responses request before generating output.

https://developers.openai.com/api/reference/resources/responses/methods/input_tokens

```4d
var $result:=$client.responses.countInputTokens("Hello"; {model: "gpt-5"})
ALERT("Input tokens: "+String($result.input_tokens))
```

### compact()

**compact**(*responseID* : Text ; *parameters* : [OpenAIResponsesCompactParameters](OpenAIResponsesCompactParameters.md)) : [OpenAIResponsesResult](OpenAIResponsesResult.md)

Creates a compacted response from an existing response.

https://developers.openai.com/api/reference/resources/responses/methods/compact

```4d
var $params:=cs.AIKit.OpenAIResponsesCompactParameters.new({model: "gpt-5"})
var $result:=$client.responses.compact("resp_abc123"; $params)
```

### delete()

**delete**(*responseID* : Text; *parameters* : OpenAIParameters) : [OpenAIResponseDeletedResult](OpenAIResponseDeletedResult.md)

| Parameter         | Type                                      | Description                               |
|-------------------|-------------------------------------------|-------------------------------------------|
| *responseID*      | Text                                      | The ID of the response to delete.         |
| *parameters*      | [OpenAIParameters](OpenAIParameters.md)   | Additional parameters for the request.    |
| Function result   | [OpenAIResponseDeletedResult](OpenAIResponseDeletedResult.md) | Result indicating deletion success. |

Delete a stored response.

https://developers.openai.com/api/reference/resources/responses/methods/delete

#### Example Usage

```4d
var $result:=$client.responses.delete("resp_abc123")
If ($result.deleted#Null) && $result.deleted.deleted
    ALERT("Response deleted successfully")
End if
```

## Key Features

- **Multi-modal inputs**: Support for text, images, and files
- **Structured outputs**: Generate JSON or plain text responses
- **Streaming**: Real-time response streaming with server-sent events
- **Conversations**: Multi-turn dialogues with conversation tracking
- **Tool calling**: Built-in tools and custom function execution
- **Background processing**: Long-running response generation
- **Storage**: Automatic response storage for retrieval and updates

## See also

- [OpenAIResponsesParameters](OpenAIResponsesParameters.md)
- [OpenAIResponsesResult](OpenAIResponsesResult.md)
- [OpenAIResponse](OpenAIResponse.md)
- [OpenAIResponsesInputItemsParameters](OpenAIResponsesInputItemsParameters.md)
- [OpenAIResponsesInputItemsResult](OpenAIResponsesInputItemsResult.md)
- [OpenAIResponsesInputTokensResult](OpenAIResponsesInputTokensResult.md)
- [OpenAIResponsesCompactParameters](OpenAIResponsesCompactParameters.md)
- [OpenAIResponseDeletedResult](OpenAIResponseDeletedResult.md)
