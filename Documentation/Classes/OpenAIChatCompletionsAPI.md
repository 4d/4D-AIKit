# OpenAIChatCompletionsAPI

The `OpenAIChatCompletionsAPI` class is designed for managing chat completions with OpenAI's API. It provides methods to create, retrieve, update, delete, and list chat completions.

## Functions

### create

Creates a model response for the given chat conversation.

| Argument     | Type                                      | Description                               |
|--------------|-------------------------------------------|-------------------------------------------|
| `$messages`  | Collection of [OpenAIMessage](OpenAIMessage)   | The chat messages to include in the request. |
| `$parameters`| [OpenAIChatCompletionParameters](OpenAIChatCompletionParameters)            | The parameters for the chat completion request. |

#### Example Usage

```4d
var $messages:=[]
$messages.push({"role":"user"; "content":"Hello, how are you?"})

var $result:=$client.chat.completions.create($messages; $parameters)
```

### retrieve

Get a stored chat completion.

| Argument         | Type   | Description                               |
|------------------|--------|-------------------------------------------|
| `$completionID`  | Text   | The ID of the chat completion to retrieve. |
| `$parameters`    | [OpenAIParameters](OpenAIParameters) | Additional parameters for the request.    |

### update

Modify a stored chat completion.

| Argument         | Type   | Description                               |
|------------------|--------|-------------------------------------------|
| `$completionID`  | Text   | The ID of the chat completion to update. |
| `$metadata`      | Object | Metadata to update the completion with.   |
| `$parameters`    | [OpenAIParameters](OpenAIParameters) | Additional parameters for the request.    |

### delete

Delete a stored chat completion.

| Argument         | Type   | Description                               |
|------------------|--------|-------------------------------------------|
| `$completionID`  | Text   | The ID of the chat completion to delete.  |
| `$parameters`    | [OpenAIParameters](OpenAIParameters) | Additional parameters for the request.    |

### list

List stored chat completions.

| Argument         | Type                                      | Description                               |
|------------------|-------------------------------------------|-------------------------------------------|
| `$parameters`    | [OpenAIChatCompletionsListParameters](OpenAIChatCompletionsListParameters)       | Parameters for listing chat completions.  |
