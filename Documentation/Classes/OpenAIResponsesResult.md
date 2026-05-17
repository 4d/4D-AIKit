# OpenAIResponsesResult

The `OpenAIResponsesResult` class extends [OpenAIResult](OpenAIResult.md) and represents the result of a Responses API request.

## Inherits

- [OpenAIResult](OpenAIResult.md)

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
var $result:=$client.responses.create("Hello"; {model: "gpt-5"})
var $response:=$result.response
ALERT($response.outputText)
```

### outputText

**get outputText** : Text

| Property        | Type    | Description                               |
|-----------------|---------|-------------------------------------------|
| Function result | Text    | The text output or empty string if not available |

Returns the text output from the response. This is a convenience method that extracts `output_text` items from the output structure.

#### Example Usage

```4d
var $result:=$client.responses.create("What is 2+2?"; {model: "gpt-5"})
var $text:=$result.outputText
ALERT($text)
```

### output

**get output** : Variant

| Property        | Type    | Description                               |
|-----------------|---------|-------------------------------------------|
| Function result | Variant | The full output object or Null if not available |

Returns the complete output object from the response. The structure varies depending on the response format (text, JSON, etc.).

#### Example Usage

```4d
var $result:=$client.responses.create("Tell me about AI"; {model: "gpt-5"})
var $output:=$result.output
If (Value type($output)=Is object)
    // Handle structured output
End if
```

## Example Usage

### Basic Usage

```4d
var $client:=cs.AIKit.OpenAI.new("your-api-key")
var $result:=$client.responses.create("Hello, how are you?"; {model: "gpt-5"})

If ($result.success)
    ALERT($result.outputText)
    // $result.response.id contains the response identifier
    // $result.response.model contains the model ID
    // $result.response.status contains the current status
Else
    ALERT("Errors: "+JSON Stringify($result.errors))
End if
```

### Checking Response Status

```4d
var $result:=$client.responses.create("Complex query"; {model: "gpt-5"; background: True})

If ($result.success)
    var $response:=$result.response

    Case of
        : ($response.isComplete)
            ALERT($response.outputText)
        : ($response.isProcessing)
            // Poll again later or wait for completion
        : ($response.isFailed)
            ALERT("Response failed")
    End case
End if
```

### Accessing Metadata

```4d
var $result:=$client.responses.create("Hello"; {model: "gpt-5"})

If ($result.success)
    // $result.response.id contains the response identifier
    // $result.response.model contains the model ID
    // $result.response.conversation contains the conversation reference when present

    // Check usage
    If ($result.usage#Null)
        // Responses usage uses input_tokens, output_tokens, and total_tokens
        ALERT("Input tokens: "+String($result.usage.input_tokens))
        ALERT("Output tokens: "+String($result.usage.output_tokens))
        ALERT("Total tokens: "+String($result.usage.total_tokens))
    End if
End if
```

### Error Handling

```4d
var $result:=$client.responses.create("Hello"; {model: "invalid-model"})

If (Not($result.success))
    For each ($error; $result.errors)
        ALERT("Error: "+$error.message)
    End for each
End if
```

## See also

- [OpenAIResponse](OpenAIResponse.md)
- [OpenAIResponsesAPI](OpenAIResponsesAPI.md)
- [OpenAIResult](OpenAIResult.md)
