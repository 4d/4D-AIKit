# OpenAIResponsesHelper

The `OpenAIResponsesHelper` class provides a simplified interface for working with OpenAI's Responses API, particularly useful for multi-turn conversations and common use cases.

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `instructions` | Text | The system instructions for the conversation |
| `parameters` | [OpenAIResponsesParameters](OpenAIResponsesParameters.md) | The parameters used for responses |
| `conversationHistory` | Collection | History of all conversation exchanges |

## Functions

### send()

Send a message and get a complete response result.

```4d
$result:=$helper.send($input)
```

#### Parameters

- `$input` (Variant): Text, image, or file inputs to send to the model

#### Returns

- [OpenAIResponsesResult](OpenAIResponsesResult.md): The complete response result

### ask()

Send a message and return just the text output (convenience method).

```4d
$text:=$helper.ask($input)
```

**Parameters:**

- `$input` (Variant): Text, image, or file inputs to send to the model

**Returns:**

- Text: The output text from the response

### reset()

Clear the conversation history and start fresh.

```4d
$helper.reset()
```

### helper()

Create a new helper instance (called on OpenAIResponsesAPI).

```4d
$helper:=$client.responses.helper($instructions; $parameters)
```

## Computed Properties

### lastResponse

Get the last response from the conversation.

```4d
var $lastResponse : cs.OpenAIResponsesResult
$lastResponse:=$helper.lastResponse
```

### summary

Get a summary of the conversation including message count and token usage.

```4d
var $summary : Object
$summary:=$helper.summary
```

## Example Usage

### Basic Conversation

```4d
var $client : cs.OpenAI
$client:=cs.OpenAI.new()

// Create a helper for easy conversation management
var $helper : cs.OpenAIResponsesHelper
$helper:=$client.responses.helper("You are a helpful assistant."; Null)

// Send messages - conversation state is automatically maintained
var $response1 : Text
$response1:=$helper.ask("What is the capital of France?")
ALERT($response1)  // "The capital of France is Paris."

var $response2 : Text
$response2:=$helper.ask("What about Germany?")
ALERT($response2)  // "The capital of Germany is Berlin."

// Get conversation summary
var $summary : Object
$summary:=$helper.summary
ALERT("Messages: "+String($summary.messageCount)+", Tokens: "+String($summary.totalTokens))
```

### Advanced Usage with Custom Parameters

```4d
var $client : cs.OpenAI
$client:=cs.OpenAI.new()

// Create custom parameters
var $parameters : cs.OpenAIResponsesParameters
$parameters:=cs.OpenAIResponsesParameters.new()
$parameters.model:="gpt-4o"
$parameters.temperature:=0.7
$parameters.max_output_tokens:=500

// Create helper with custom parameters
var $helper : cs.OpenAIResponsesHelper
$helper:=$client.responses.helper("You are a creative writing assistant."; $parameters)

// Use full response for detailed information
var $result : cs.OpenAIResponsesResult
$result:=$helper.send("Write a short story about a robot.")

If ($result.success)
    ALERT($result.output_text)
    
    // Access detailed response information
    var $response : cs.OpenAIResponse
    $response:=$result.response
    ALERT("Response ID: "+$response.id)
    ALERT("Tokens used: "+String($response.usage.total_tokens))
End if
```

### Multi-turn Technical Conversation

```4d
var $client : cs.OpenAI
$client:=cs.OpenAI.new()

var $parameters : cs.OpenAIResponsesParameters
$parameters:=cs.OpenAIResponsesParameters.new()
$parameters.model:="gpt-4o"
$parameters.tools:=New collection(New object("type"; "web_search"))

var $helper : cs.OpenAIResponsesHelper
$helper:=$client.responses.helper("You are a technical expert. Provide detailed, accurate answers."; $parameters)

// Multi-turn conversation with automatic state management
$helper.ask("Explain REST APIs")
$helper.ask("What are the main HTTP methods?")
$helper.ask("How does authentication work in REST?")

// Get the last response details
var $lastResponse : cs.OpenAIResponsesResult
$lastResponse:=$helper.lastResponse

If ($lastResponse.success)
    ALERT("Last answer: "+$lastResponse.output_text)
End if

// Reset for a new conversation
$helper.reset()
$helper.ask("Now let's talk about databases")
```

## Benefits

1. **Automatic State Management**: Handles `previous_response_id` automatically
2. **Conversation History**: Tracks all exchanges for debugging and analysis
3. **Simplified API**: `ask()` method for quick text responses
4. **Flexible**: Can use `send()` for full control when needed
5. **Statistics**: Built-in conversation summary and token tracking

## See also

- [OpenAIResponsesAPI](OpenAIResponsesAPI.md)
- [OpenAIResponsesParameters](OpenAIResponsesParameters.md)
- [OpenAIResponsesResult](OpenAIResponsesResult.md)
