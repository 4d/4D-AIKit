# OpenAIResponsesAPI

## Description

The OpenAI Responses API is a unified API that combines the capabilities of Chat Completions and Assistants APIs. It provides a streamlined interface for creating AI responses with built-in support for tools like web search, file search, and more.

## Inherits

[OpenAIAPIResource](OpenAIAPIResource.md)

## Properties

| Property | Type | Description |
|----------|------|-------------|
| _client | cs.AIKit.OpenAI | Reference to the OpenAI client instance |

## Functions

### create()

**create**(*input* : Variant ; *parameters* : cs.AIKit.OpenAIResponsesParameters) : cs.AIKit.OpenAIResponsesResult

| Parameter       | Type        | Description                    |
|-----------------|-------------|--------------------------------|
| *input*         | Variant     | The input for the response. Can be a string or an array of message objects |
| *parameters*    | cs.AIKit.OpenAIResponsesParameters | Optional parameters for the request |
| Function result | cs.AIKit.OpenAIResponsesResult | The response from the API |

Creates a response for the given input using OpenAI's Responses API.

#### Example Usage

```4d
var $client : cs.AIKit.OpenAI
$client:=cs.AIKit.OpenAI.new($apiKey)

// Simple string input
var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("Tell me a joke about programming")

If ($result.success)
    ALERT($result.output)
End if
```

### retrieve()

**retrieve**(*responseID* : Text ; *parameters* : cs.AIKit.OpenAIParameters) : cs.AIKit.OpenAIResponsesResult

| Parameter       | Type        | Description                    |
|-----------------|-------------|--------------------------------|
| *responseID*    | Text        | The ID of the response to retrieve |
| *parameters*    | cs.AIKit.OpenAIParameters | Optional parameters for the request |
| Function result | cs.AIKit.OpenAIResponsesResult | The retrieved response |

Retrieves a previously stored response by its ID.

#### Example Usage

```4d
var $client : cs.AIKit.OpenAI
$client:=cs.AIKit.OpenAI.new($apiKey)

var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.retrieve("response_abc123")
```

### list()

**list**(*parameters* : cs.AIKit.OpenAIParameters) : cs.AIKit.OpenAIResult

| Parameter       | Type        | Description                    |
|-----------------|-------------|--------------------------------|
| *parameters*    | cs.AIKit.OpenAIParameters | Optional parameters for the request |
| Function result | cs.AIKit.OpenAIResult | List of stored responses |

Lists all stored responses.

#### Example Usage

```4d
var $client : cs.AIKit.OpenAI
$client:=cs.AIKit.OpenAI.new($apiKey)

var $result : cs.AIKit.OpenAIResult
$result:=$client.responses.list()
```

### delete()

**delete**(*responseID* : Text ; *parameters* : cs.AIKit.OpenAIParameters) : cs.AIKit.OpenAIResult

| Parameter       | Type        | Description                    |
|-----------------|-------------|--------------------------------|
| *responseID*    | Text        | The ID of the response to delete |
| *parameters*    | cs.AIKit.OpenAIParameters | Optional parameters for the request |
| Function result | cs.AIKit.OpenAIResult | Deletion confirmation |

Deletes a stored response by its ID.

#### Example Usage

```4d
var $client : cs.AIKit.OpenAI
$client:=cs.AIKit.OpenAI.new($apiKey)

var $result : cs.AIKit.OpenAIResult
$result:=$client.responses.delete("response_abc123")
```

## Examples

### Basic Usage

```4d
var $client:=cs.AIKit.OpenAI.new($apiKey)

// Simple text response
var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("What is the capital of France?")

If ($result.success)
    ALERT($result.output)
End if
```

### Advanced Usage with Tools

```4d
var $client:=cs.AIKit.OpenAI.new($apiKey)

// Create response with web search tool
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.model:="gpt-4o"
$params.tools:=[{type: "web_search"}]
$params.instructions:="Search for the latest news about AI"

var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("What are the latest developments in AI?"; $params)

If ($result.success)
    ALERT($result.output)
End if
```

### Streaming Responses

```4d
var $client:=cs.AIKit.OpenAI.new($apiKey)

var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.stream:=True
$params.onData:=Formula($this.handleStreamData($1))

var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("Tell me a long story"; $params)
```

### Using Message Objects

```4d
var $client:=cs.AIKit.OpenAI.new($apiKey)

var $messages:=[]
$messages.push({role: "system"; content: "You are a helpful assistant"})
$messages.push({role: "user"; content: "What is 2+2?"})

var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.model:="gpt-4o"

var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create($messages; $params)

If ($result.success)
    ALERT($result.output)
End if
```

### Stateful Interactions

```4d
var $client:=cs.AIKit.OpenAI.new($apiKey)

// First response
var $result1 : cs.AIKit.OpenAIResponsesResult
$result1:=$client.responses.create("My name is Alice")

// Continue conversation
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.previous_response_id:=$result1.id

var $result2 : cs.AIKit.OpenAIResponsesResult
$result2:=$client.responses.create("What is my name?"; $params)

If ($result2.success)
    ALERT($result2.output)  // Should mention "Alice"
End if
```

### Reasoning Control

```4d
var $client:=cs.AIKit.OpenAI.new($apiKey)

var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.model:="o3-mini"
$params.reasoning:={effort: "high"}

var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("Solve this complex math problem: ..."; $params)
```

## Error Handling

```4d
var $client:=cs.AIKit.OpenAI.new($apiKey)

var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("Tell me a joke")

If (Not($result.success))
    // Handle error
    If ($result.errors.length>0)
        var $error:=$result.errors[0]
        ALERT("Error: "+$error.message)
    End if
Else
    // Process successful response
    ALERT($result.output)
End if
```

## See Also

- [OpenAIResponsesParameters](OpenAIResponsesParameters.md)
- [OpenAIResponsesResult](OpenAIResponsesResult.md)
- [OpenAI](OpenAI.md)
- [OpenAIChatCompletionsAPI](OpenAIChatCompletionsAPI.md)
