# GeminiResult

## Description

Base class for all Gemini API responses. Provides common functionality for success/error handling, headers, rate limiting, and usage information.

## Inherits

None (base class)

## Properties

| Property    | Type             | Description                              |
|-------------|------------------|------------------------------------------|
| request     | 4D.HTTPRequest   | The HTTP request object                  |
| _parsed     | Object           | Cached parsed response body              |
| _terminated | Boolean          | Force terminated flag                    |
| _errors     | Collection       | Forced errors collection                 |

## Functions

### get success

**success** : Boolean

| Property        | Type    | Description                              |
|-----------------|---------|------------------------------------------|
| Function result | Boolean | True if HTTP status is 2xx and no errors |

Returns true if the request succeeded.

### get terminated

**terminated** : Boolean

| Property        | Type    | Description                         |
|-----------------|---------|-------------------------------------|
| Function result | Boolean | True if request has completed       |

Returns true if the request has finished.

### get errors

**errors** : Collection

| Property        | Type       | Description                    |
|-----------------|------------|--------------------------------|
| Function result | Collection | Collection of error objects    |

Returns collection of errors if any occurred.

### get headers

**headers** : Object

| Property        | Type   | Description                      |
|-----------------|--------|----------------------------------|
| Function result | Object | Response headers                 |

Returns HTTP response headers.

### get rateLimit

**rateLimit** : Object

| Property        | Type   | Description                      |
|-----------------|--------|----------------------------------|
| Function result | Object | Rate limit information           |

Returns rate limit information from headers.

### get usage

**usage** : Object

| Property        | Type   | Description                      |
|-----------------|--------|----------------------------------|
| Function result | Object | Token usage metadata             |

Returns usage metadata (token counts).

### throw()

**throw**()

Throws all errors in the errors collection.

### _shouldRetry()

**_shouldRetry**() : Boolean

| Property        | Type    | Description                          |
|-----------------|---------|--------------------------------------|
| Function result | Boolean | True if request should be retried    |

Checks if request should be retried based on status code.

### _retryAfterValue

**_retryAfterValue** : Integer

| Property        | Type    | Description                          |
|-----------------|---------|--------------------------------------|
| Function result | Integer | Seconds to wait before retry         |

Gets retry delay from headers.

### _failWith()

**_failWith**(*errors* : Collection)

| Parameter | Type       | Description             |
|-----------|------------|-------------------------|
| errors    | Collection | Errors to set           |

Force fail the result with given errors.

## Examples

### Check Success

```4d
var $result:=$gemini.content.generate("Hello"; "gemini-2.0-flash-exp")

If ($result.success)
    ALERT("Request succeeded")
    // Process result
Else
    ALERT("Request failed")
    // Handle errors
End if
```

### Access Errors

```4d
var $result:=$gemini.content.generate("Test"; "invalid-model")

If (Not($result.success))
    For each ($error; $result.errors)
        ALERT("Error "+String($error.status)+": "+$error.message)
    End for each
End if
```

### Check Headers

```4d
var $result:=$gemini.content.generate("Test"; "gemini-2.0-flash-exp")

If ($result.success)
    var $headers:=$result.headers
    ALERT("Content-Type: "+$headers["content-type"])
End if
```

### Rate Limit Info

```4d
var $result:=$gemini.content.generate("Test"; "gemini-2.0-flash-exp")

If ($result.success)
    var $rateLimit:=$result.rateLimit

    If ($rateLimit#Null)
        ALERT("Limit: "+String($rateLimit.limit.request))
        ALERT("Remaining: "+String($rateLimit.remaining.request))
    End if
End if
```

### Usage Metadata

```4d
var $result:=$gemini.content.generate("Hello world"; "gemini-2.0-flash-exp")

If ($result.success)
    var $usage:=$result.usage

    If ($usage#Null)
        ALERT("Prompt tokens: "+String($usage.promptTokenCount))
        ALERT("Candidates tokens: "+String($usage.candidatesTokenCount))
        ALERT("Total tokens: "+String($usage.totalTokenCount))
    End if
End if
```

### Throw Errors

```4d
var $result:=$gemini.content.generate("Test"; "invalid-model")

Try
    $result.throw()  // Throws if there are errors
Catch
    ALERT("Caught: "+Last errors[0].message)
End try
```

### Wait for Completion (Async)

```4d
var $params:=cs.GeminiContentParameters.new()
$params.onResponse:=Formula
    ALERT("Done!")
End formula

var $result:=$gemini.content.generate("Test"; "gemini-2.0-flash-exp"; $params)

// For synchronous wait
While (Not($result.terminated))
    DELAY PROCESS(Current process; 10)
End while

If ($result.success)
    // Process result
End if
```

### Check Retry Status

```4d
var $result:=$gemini.content.generate("Test"; "gemini-2.0-flash-exp")

If (Not($result.success))
    If ($result._shouldRetry())
        var $retryAfter:=$result._retryAfterValue()
        ALERT("Retry after "+String($retryAfter)+" seconds")
    End if
End if
```

## Rate Limit Structure

The `rateLimit` object contains:

```4d
{
    limit: {
        request: 100  // Request limit
    },
    remaining: {
        request: 95  // Remaining requests
    },
    reset: {
        request: "2024-01-01T00:00:00Z"  // Reset time
    }
}
```

## Usage Metadata Structure

The `usage` object (Gemini calls it `usageMetadata`) contains:

```4d
{
    promptTokenCount: 10,
    candidatesTokenCount: 50,
    totalTokenCount: 60
}
```

## Error Handling Patterns

### Pattern 1: Check Success

```4d
If ($result.success)
    // Process successful result
Else
    // Handle error
    For each ($error; $result.errors)
        ALERT($error.message)
    End for each
End if
```

### Pattern 2: Throw Errors

```4d
Try
    var $result:=$gemini.content.generate("Test"; "model")
    $result.throw()  // Throws if errors exist

    // Process result (only reached if successful)
    ALERT($result.candidates[0].text)
Catch
    ALERT("Error: "+Last errors[0].message)
End try
```

### Pattern 3: Use Throw Parameter

```4d
var $params:=cs.GeminiContentParameters.new()
$params.throw:=True

Try
    var $result:=$gemini.content.generate("Test"; "invalid-model"; $params)
Catch
    ALERT("Caught: "+Last errors[0].message)
End try
```

## HTTP Status Codes

Common status codes:
- `200` - Success
- `400` - Bad Request
- `401` - Authentication Error
- `403` - Permission Denied
- `404` - Not Found
- `429` - Rate Limit Exceeded
- `500+` - Server Error

## See Also

- [GeminiContentResult](GeminiContentResult.md) - Content generation result
- [GeminiEmbeddingsResult](GeminiEmbeddingsResult.md) - Embeddings result
- [GeminiError](GeminiError.md) - Error structure
- [GeminiParameters](GeminiParameters.md) - Request parameters
