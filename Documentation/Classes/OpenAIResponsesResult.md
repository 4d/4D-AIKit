# OpenAIResponsesResult

The `OpenAIResponsesResult` class extends [OpenAIResult](OpenAIResult.md) and represents the result of a Responses API request.

## Properties

Inherits all properties from [OpenAIResult](OpenAIResult.md), including:
- `success`: Boolean indicating if the request was successful
- `errors`: Collection of errors if any occurred
- `headers`: Response headers
- `request`: The underlying HTTP request object

## Functions

### response

**get response** : [OpenAIResponse](OpenAIResponse.md)

| Property        | Type                                      | Description                               |
|-----------------|-------------------------------------------|-------------------------------------------|
| Function result | [OpenAIResponse](OpenAIResponse.md)       | The response object or Null if not available |

Returns the OpenAIResponse object containing the model's response and metadata.

#### Example Usage

```4d
var $result:=$client.responses.create("Hello"; {model: "gpt-4o"})
var $response:=$result.response
TRACE($response.text)
```

### text

**get text** : Text

| Property        | Type    | Description                               |
|-----------------|---------|-------------------------------------------|
| Function result | Text    | The text output or empty string if not available |

Returns the text output from the response. This is a convenience method that extracts text from the output structure.

#### Example Usage

```4d
var $result:=$client.responses.create("What is 2+2?"; {model: "gpt-4o"})
var $text:=$result.text
TRACE($text) // "4"
```

### output

**get output** : Variant

| Property        | Type    | Description                               |
|-----------------|---------|-------------------------------------------|
| Function result | Variant | The full output object or Null if not available |

Returns the complete output object from the response. The structure varies depending on the response format (text, JSON, etc.).

#### Example Usage

```4d
var $result:=$client.responses.create("Tell me about AI"; {model: "gpt-4o"})
var $output:=$result.output
If (Value type($output)=Is object)
    // Handle structured output
End if
```

## Example Usage

### Basic Usage

```4d
var $client:=cs.OpenAI.new("your-api-key")
var $result:=$client.responses.create("Hello, how are you?"; {model: "gpt-4o"})

If ($result.success)
    TRACE($result.text)
    TRACE($result.response.id)
    TRACE($result.response.model)
    TRACE($result.response.status)
Else
    TRACE("Errors: "+JSON Stringify($result.errors))
End if
```

### Checking Response Status

```4d
var $result:=$client.responses.create("Complex query"; {model: "gpt-4o"; background: True})

If ($result.success)
    var $response:=$result.response

    Case of
        : ($response.isComplete)
            TRACE("Response is complete: "+$response.text)
        : ($response.isProcessing)
            TRACE("Response is still processing...")
        : ($response.isFailed)
            TRACE("Response failed")
    End case
End if
```

### Accessing Metadata

```4d
var $result:=$client.responses.create("Hello"; {model: "gpt-4o"})

If ($result.success)
    TRACE("Response ID: "+$result.response.id)
    TRACE("Model: "+$result.response.model)
    TRACE("Conversation ID: "+$result.response.conversation_id)

    // Check usage
    If ($result.usage#Null)
        TRACE("Prompt tokens: "+String($result.usage.prompt_tokens))
        TRACE("Completion tokens: "+String($result.usage.completion_tokens))
        TRACE("Total tokens: "+String($result.usage.total_tokens))
    End if
End if
```

### Error Handling

```4d
var $result:=$client.responses.create("Hello"; {model: "invalid-model"})

If (Not($result.success))
    For each ($error; $result.errors)
        TRACE("Error: "+$error.message)
    End for each
End if
```
