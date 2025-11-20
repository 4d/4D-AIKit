# GeminiError

## Description

Error object for Gemini API responses. Contains error details including status code, message, and error type.

## Properties

| Property | Type    | Description                          |
|----------|---------|--------------------------------------|
| errCode  | Integer | Error code                           |
| message  | Text    | Error message                        |
| body     | Object  | Full error response body             |
| response | Object  | HTTP response object                 |

## Constructor

```4d
$error:=cs.GeminiError.new($response; $body)
```

| Parameter | Type   | Description              |
|-----------|--------|--------------------------|
| $response | Object | HTTP response object     |
| $body     | Object | Parsed response body     |

## Functions

### get headers

**headers** : Object

Returns response headers.

### get type

**type** : Text

Returns error type.

### get code

**code** : Variant

Returns error code from body.

### get statusText

**statusText** : Text

Returns HTTP status text.

### get status

**status** : Integer

Returns HTTP status code.

### get isBadRequestError

**isBadRequestError** : Boolean

Returns true if status is 400.

### get isAuthenticationError

**isAuthenticationError** : Boolean

Returns true if status is 401.

### get isPermissionDeniedError

**isPermissionDeniedError** : Boolean

Returns true if status is 403.

### get isNotFoundError

**isNotFoundError** : Boolean

Returns true if status is 404.

###get isUnprocessableEntityError

**isUnprocessableEntityError** : Boolean

Returns true if status is 422.

### get isRateLimitError

**isRateLimitError** : Boolean

Returns true if status is 429.

### get isInternalServerError

**isInternalServerError** : Boolean

Returns true if status is 500 or higher.

## Examples

### Access Error Details

```4d
var $result:=$gemini.content.generate("Test"; "invalid-model")

If (Not($result.success))
    var $error:=$result.errors[0]

    ALERT("Error: "+$error.message)
    ALERT("Status: "+String($error.status))
    ALERT("Code: "+String($error.code))
End if
```

### Check Error Type

```4d
var $result:=$gemini.content.generate("Test"; "gemini-2.0-flash-exp")

If (Not($result.success))
    var $error:=$result.errors[0]

    Case of
        : ($error.isBadRequestError)
            ALERT("Bad request - check your parameters")
        : ($error.isAuthenticationError)
            ALERT("Authentication failed - check your API key")
        : ($error.isRateLimitError)
            ALERT("Rate limit exceeded - try again later")
        : ($error.isInternalServerError)
            ALERT("Server error - try again later")
    End case
End if
```

### Log Error Details

```4d
var $result:=$gemini.content.generate("Test"; "model")

If (Not($result.success))
    For each ($error; $result.errors)
        var $logEntry:=Current date+" "+String(Current time)+": "
        $logEntry+:="["+String($error.status)+"] "
        $logEntry+:=$error.message

        // Write to log file
        var $logFile:=File("/LOGS/gemini_errors.txt")
        $logFile.setText($logFile.getText()+$logEntry+"\r\n")
    End for each
End if
```

### Retry on Specific Errors

```4d
var $result:=$gemini.content.generate("Test"; "gemini-2.0-flash-exp")

If (Not($result.success))
    var $error:=$result.errors[0]

    If ($error.isRateLimitError || $error.isInternalServerError)
        // Retry after delay
        DELAY PROCESS(Current process; 60*5)  // Wait 5 seconds
        $result:=$gemini.content.generate("Test"; "gemini-2.0-flash-exp")
    End if
End if
```

### Display User-Friendly Messages

```4d
var $result:=$gemini.content.generate("Test"; "model")

If (Not($result.success))
    var $error:=$result.errors[0]
    var $userMessage:=""

    Case of
        : ($error.isAuthenticationError)
            $userMessage:="Invalid API key. Please check your configuration."
        : ($error.isRateLimitError)
            $userMessage:="Too many requests. Please try again in a moment."
        : ($error.isBadRequestError)
            $userMessage:="Invalid request. Please check your input."
        : ($error.isNotFoundError)
            $userMessage:="Resource not found. Please check the model name."
        Else
            $userMessage:="An error occurred: "+$error.message
    End case

    ALERT($userMessage)
End if
```

### Extract Error Details from Body

```4d
var $result:=$gemini.content.generate("Test"; "invalid")

If (Not($result.success))
    var $error:=$result.errors[0]

    If ($error.body#Null)
        If ($error.body.error#Null)
            ALERT("Error type: "+String($error.body.error.type))
            ALERT("Error code: "+String($error.body.error.code))
            ALERT("Error message: "+String($error.body.error.message))

            // Additional details
            If ($error.body.error.details#Null)
                ALERT("Details: "+JSON Stringify($error.body.error.details))
            End if
        End if
    End if
End if
```

## Common Error Status Codes

| Status | Name                       | Meaning                               |
|--------|----------------------------|---------------------------------------|
| 400    | Bad Request                | Invalid parameters                    |
| 401    | Unauthorized               | Invalid or missing API key            |
| 403    | Forbidden                  | Permission denied                     |
| 404    | Not Found                  | Resource not found                    |
| 422    | Unprocessable Entity       | Invalid entity                        |
| 429    | Too Many Requests          | Rate limit exceeded                   |
| 500    | Internal Server Error      | Server error                          |
| 503    | Service Unavailable        | Service temporarily unavailable       |

## Error Body Structure

Typical error response body:

```json
{
    "error": {
        "code": 400,
        "message": "Invalid model name",
        "status": "INVALID_ARGUMENT",
        "details": [...]
    }
}
```

## See Also

- [GeminiResult](GeminiResult.md) - Base result class
- [Gemini](Gemini.md) - Main client class
