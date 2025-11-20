# GeminiContent

## Description

Represents a content object in Gemini API requests and responses. Contains an array of parts and an optional role.

## Properties

| Property | Type       | Description                    |
|----------|------------|--------------------------------|
| parts    | Collection | Collection of GeminiPart objects |
| role     | Text       | Role (user, model, or empty)   |

## Constructor

```4d
$content:=cs.GeminiContent.new()
$content:=cs.GeminiContent.new($data)
```

## Functions

### fromText()

**fromText**(*text* : Text ; *role* : Text) : cs.GeminiContent

| Parameter       | Type          | Description                    |
|-----------------|---------------|--------------------------------|
| text            | Text          | The text content               |
| role            | Text          | Role (user, model)             |
| Function result | GeminiContent | New content object             |

Creates a new content object from text.

### addText()

**addText**(*text* : Text)

| Parameter | Type | Description          |
|-----------|------|----------------------|
| text      | Text | Text to add as part  |

Adds a text part to the content.

### toBody()

**toBody**() : Object

| Parameter       | Type   | Description                |
|-----------------|--------|----------------------------|
| Function result | Object | Content as request body    |

Converts content to request body format.

## Examples

### Create Text Content

```4d
var $content:=cs.GeminiContent.fromText("Hello world"; "user")

ALERT($content.parts[0].text)  // "Hello world"
ALERT($content.role)  // "user"
```

### Add Multiple Parts

```4d
var $content:=cs.GeminiContent.new()
$content.role:="user"

$content.addText("What's in this image?")

// Add image part (would need actual image data)
$content.parts.push(cs.GeminiPart.fromInlineData("image/jpeg"; $base64ImageData))
```

### Build Multi-Part Request

```4d
var $content:=cs.GeminiContent.new()
$content.role:="user"

// Add text
$content.addText("Analyze this document")

// Add file reference
var $filePart:=cs.GeminiPart.new()
$filePart.fileData:={fileUri: "files/abc123"; mimeType: "application/pdf"}
$content.parts.push($filePart)

// Use in request
var $contents:=[$content.toBody()]
var $result:=$gemini.content.generate($contents; "gemini-2.0-flash-exp")
```

### Parse Response Content

```4d
var $result:=$gemini.content.generate("Hello"; "gemini-2.0-flash-exp")

If ($result.success)
    var $candidate:=$result.candidate
    var $content:=$candidate.content

    ALERT("Role: "+$content.role)  // "model"

    For each ($part; $content.parts)
        If (Length($part.text)>0)
            ALERT("Text: "+$part.text)
        End if
    End for each
End if
```

### Multi-Turn Conversation

```4d
var $messages:=[]

// User message
var $userContent:=cs.GeminiContent.fromText("What is 2+2?"; "user")
$messages.push($userContent.toBody())

// Model response (from previous call)
var $modelContent:=cs.GeminiContent.fromText("2+2 equals 4."; "model")
$messages.push($modelContent.toBody())

// Next user message
$userContent:=cs.GeminiContent.fromText("And what is 4+4?"; "user")
$messages.push($userContent.toBody())

// Send conversation
var $result:=$gemini.content.generate($messages; "gemini-2.0-flash-exp")
```

### Create Content with Function Response

```4d
var $content:=cs.GeminiContent.new()
$content.role:="function"

var $funcResponse:=cs.GeminiPart.new()
$funcResponse.functionResponse:={\
    name: "get_weather"; \
    response: {temperature: 72; condition: "sunny"}}

$content.parts:=[$funcResponse]
```

### Extract All Text

```4d
var $result:=$gemini.content.generate("Explain AI"; "gemini-2.0-flash-exp")

If ($result.success)
    var $content:=$result.candidate.content
    var $allText:=""

    For each ($part; $content.parts)
        If (Length($part.text)>0)
            $allText+:=$part.text+" "
        End if
    End for each

    ALERT($allText)
End if
```

### Check for Function Calls

```4d
var $result:=$gemini.content.generate("What's the weather?"; "gemini-2.0-flash-exp"; $paramsWithTools)

If ($result.success)
    var $content:=$result.candidate.content

    For each ($part; $content.parts)
        If ($part.functionCall#Null)
            ALERT("Function to call: "+$part.functionCall.name)
            ALERT("Arguments: "+JSON Stringify($part.functionCall.args))
        End if
    End for each
End if
```

## Content Structure

A content object in requests:

```json
{
    "role": "user",
    "parts": [
        {"text": "Hello"},
        {"inlineData": {"mimeType": "image/jpeg", "data": "base64..."}}
    ]
}
```

## Roles

- `user` - User input
- `model` - Model response
- `function` - Function response
- Empty - No role specified

## See Also

- [GeminiContentResult](GeminiContentResult.md) - Content result
- [GeminiCandidate](GeminiCandidate.md) - Response candidate
- [GeminiPart](GeminiPart.md) - Content parts
