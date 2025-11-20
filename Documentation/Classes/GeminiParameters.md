# GeminiParameters

## Description

Base class for all Gemini API request parameters. Provides common functionality for request configuration, async callbacks, and request options.

## Inherits

None (base class)

## Properties

### Execution Parameters

| Property     | Type         | Description                                                |
|--------------|--------------|-----------------------------------------------------------|
| onTerminate  | 4D.Function  | Function called when request completes (success or error) |
| onResponse   | 4D.Function  | Function called when request succeeds                     |
| onError      | 4D.Function  | Function called when request fails                        |
| formula      | 4D.Function  | Generic callback function for any completion              |
| throw        | Boolean      | If true, throw errors instead of returning them (default: false) |

### Request Parameters

| Property      | Type          | Description                                       |
|---------------|---------------|--------------------------------------------------|
| timeout       | Real          | Request timeout in seconds (overrides client timeout) |
| httpAgent     | 4D.HTTPAgent  | Custom HTTP agent (overrides client agent)       |
| maxRetries    | Integer       | Maximum retry attempts (overrides client retries) |
| extraHeaders  | Object        | Additional headers to send with this request     |

## Constructor

```4d
$params:=cs.GeminiParameters.new()
$params:=cs.GeminiParameters.new($object)
```

| Parameter | Type   | Description                          |
|-----------|--------|--------------------------------------|
| $object   | Object | Optional. Object with property values |

## Functions

### body()

**body**() : Object

| Parameter       | Type   | Description                    |
|-----------------|--------|--------------------------------|
| Function result | Object | Request body object            |

Returns the request body object. Override in subclasses to add specific parameters.

### _isAsync()

**_isAsync**() : Boolean

| Parameter       | Type    | Description                          |
|-----------------|---------|--------------------------------------|
| Function result | Boolean | True if any async callback is defined |

Checks if the request should be executed asynchronously.

## Examples

### Basic Usage

```4d
var $params:=cs.GeminiParameters.new()
$params.timeout:=30  // 30 seconds
$params.maxRetries:=5
```

### With Callbacks

```4d
var $params:=cs.GeminiParameters.new()

// Success callback
$params.onResponse:=Formula
    ALERT("Request succeeded!")
    ALERT($1.value.candidates[0].text)
End formula

// Error callback
$params.onError:=Formula
    ALERT("Request failed: "+$1.value.errors[0].message)
End formula

// Execute async request
var $result:=$gemini.content.generate("Hello"; "gemini-2.0-flash-exp"; $params)
// Request runs in background, callbacks will be called when done
```

### Generic Formula Callback

```4d
var $params:=cs.GeminiParameters.new()

$params.formula:=Formula
    If ($1.value.success)
        ALERT("Success: "+$1.value.candidates[0].text)
    Else
        ALERT("Error: "+$1.value.errors[0].message)
    End if
End formula

var $result:=$gemini.content.generate("Test"; "gemini-2.0-flash-exp"; $params)
```

### Throw Errors

```4d
var $params:=cs.GeminiParameters.new()
$params.throw:=True

Try
    var $result:=$gemini.content.generate("Test"; "invalid-model"; $params)
Catch
    ALERT("Caught error: "+Last errors[0].message)
End try
```

### Custom Headers

```4d
var $params:=cs.GeminiParameters.new()
$params.extraHeaders:={\
    "X-Custom-Header": "value"; \
    "X-Request-ID": Generate UUID}

var $result:=$gemini.content.generate("Test"; "gemini-2.0-flash-exp"; $params)
```

## Async Callback Context

When callbacks are executed, they receive the result as `$1.value`:

```4d
$params.onResponse:=Formula
    var $result:=$1.value  // GeminiContentResult, GeminiEmbeddingsResult, etc.

    // Access result properties
    If ($result.success)
        // Process successful result
    End if
End formula
```

## Notes

- Callbacks only work in worker processes or form/application context
- The `_formulaThis` property preserves the original context object
- Setting any callback (`onTerminate`, `onResponse`, `onError`, or `formula`) makes the request asynchronous
- Async requests require a persistent process to receive callbacks

## See Also

- [GeminiContentParameters](GeminiContentParameters.md) - Content generation parameters
- [GeminiEmbeddingsParameters](GeminiEmbeddingsParameters.md) - Embeddings parameters
- [GeminiFileParameters](GeminiFileParameters.md) - File upload parameters
- [GeminiResult](GeminiResult.md) - Base result class
