# OpenAIResponsesResult

## Description

Result object returned from OpenAI Responses API requests. Contains the response output, status, and metadata.

## Inherits

[OpenAIResult](OpenAIResult.md)

## Properties

All properties are read-only getters that parse the API response.

| Property | Type | Description |
|----------|------|-------------|
| output | Variant | The output from the response |
| id | Text | Unique identifier for the response |
| status | Text | Status of the response (e.g., "completed", "in_progress", "failed") |
| model | Text | The model used to generate the response |
| tool_calls | Collection | Array of tool calls made during the response |
| metadata | Object | Metadata associated with the response |
| created_at | Text | Timestamp when the response was created |
| completed_at | Text | Timestamp when the response completed |

## Inherited Properties

From [OpenAIResult](OpenAIResult.md):

| Property | Type | Description |
|----------|------|-------------|
| success | Boolean | True if the request was successful |
| terminated | Boolean | True if the request is completed |
| errors | Collection | Array of error objects if any |
| request | 4D.HTTPRequest | The underlying HTTP request |
| headers | Object | Response headers |
| rateLimit | Object | Rate limit information |
| usage | Object | Token usage information |

## Functions

### Inherited Functions

From [OpenAIResult](OpenAIResult.md):

- **throw()** - Throws any errors that occurred
- Various getter functions for accessing response data

## Examples

### Basic Usage

```4d
var $client:=cs.AIKit.OpenAI.new($apiKey)

var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("What is 2+2?")

If ($result.success)
    ALERT("Output: "+String($result.output))
    ALERT("Model: "+$result.model)
    ALERT("Response ID: "+$result.id)
End if
```

### Checking Status

```4d
var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("Complex task")

Case of
    : ($result.status="completed")
        ALERT("Task completed: "+String($result.output))
    : ($result.status="in_progress")
        ALERT("Task is still running")
    : ($result.status="failed")
        ALERT("Task failed: "+String($result.errors[0].message))
End case
```

### Accessing Tool Calls

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.tools:=[{type: "web_search"}]

var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("What's the weather today?"; $params)

If ($result.success)
    If ($result.tool_calls#Null) && ($result.tool_calls.length>0)
        var $toolCall : Object
        For each ($toolCall; $result.tool_calls)
            ALERT("Tool used: "+$toolCall.type)
        End for each
    End if
End if
```

### Using Response ID

```4d
var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("Remember: My favorite color is blue")

If ($result.success)
    // Store the response ID for later use
    var $responseID:=$result.id

    // Use in a follow-up request
    var $params:=cs.AIKit.OpenAIResponsesParameters.new()
    $params.previous_response_id:=$responseID

    var $result2 : cs.AIKit.OpenAIResponsesResult
    $result2:=$client.responses.create("What is my favorite color?"; $params)
End if
```

### Checking Metadata

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.metadata:={user_id: "123"; session_id: "abc"}
$params.store:=True

var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("Hello"; $params)

If ($result.success)
    If ($result.metadata#Null)
        ALERT("User ID: "+$result.metadata.user_id)
    End if
End if
```

### Checking Timestamps

```4d
var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("Process this task")

If ($result.success)
    ALERT("Created at: "+$result.created_at)
    If (Length($result.completed_at)>0)
        ALERT("Completed at: "+$result.completed_at)
    End if
End if
```

### Error Handling

```4d
var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("Some input")

If (Not($result.success))
    If ($result.errors.length>0)
        var $error:=$result.errors[0]
        ALERT("Error: "+$error.message)
        TRACE
    End if
Else
    // Process successful response
    ALERT($result.output)
End if
```

### Usage Information

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.stream_options:={include_usage: True}

var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("Tell me a story"; $params)

If ($result.success)
    If ($result.usage#Null)
        ALERT("Tokens used: "+String($result.usage.total_tokens))
        ALERT("Prompt tokens: "+String($result.usage.prompt_tokens))
        ALERT("Completion tokens: "+String($result.usage.completion_tokens))
    End if
End if
```

### Rate Limit Information

```4d
var $result : cs.AIKit.OpenAIResponsesResult
$result:=$client.responses.create("Hello")

If ($result.success)
    If ($result.rateLimit#Null)
        ALERT("Requests remaining: "+String($result.rateLimit.remaining.request))
        ALERT("Tokens remaining: "+String($result.rateLimit.remaining.tokens))
    End if
End if
```

## See Also

- [OpenAIResponsesAPI](OpenAIResponsesAPI.md)
- [OpenAIResponsesParameters](OpenAIResponsesParameters.md)
- [OpenAIResult](OpenAIResult.md)
