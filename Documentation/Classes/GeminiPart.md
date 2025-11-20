# GeminiPart

## Description

Represents a single part of content. Can contain text, inline data (images), file references, or function calls/responses.

## Properties

| Property         | Type   | Description                     |
|------------------|--------|---------------------------------|
| text             | Text   | Text content                    |
| inlineData       | Object | Inline data (images, etc.)      |
| fileData         | Object | File reference                  |
| functionCall     | Object | Function call from model        |
| functionResponse | Object | Function response to model      |

## Constructor

```4d
$part:=cs.GeminiPart.new()
$part:=cs.GeminiPart.new($data)
```

## Functions

### fromText()

**fromText**(*text* : Text) : cs.GeminiPart

| Parameter       | Type       | Description        |
|-----------------|------------|--------------------|
| text            | Text       | The text content   |
| Function result | GeminiPart | New part object    |

Creates a text part.

### fromInlineData()

**fromInlineData**(*mimeType* : Text ; *data* : Text) : cs.GeminiPart

| Parameter       | Type       | Description                      |
|-----------------|------------|----------------------------------|
| mimeType        | Text       | MIME type (e.g., "image/jpeg")   |
| data            | Text       | Base64-encoded data              |
| Function result | GeminiPart | New part object                  |

Creates an inline data part.

### toBody()

**toBody**() : Object

| Parameter       | Type   | Description           |
|-----------------|--------|-----------------------|
| Function result | Object | Part as request body  |

Converts part to request body format.

## Examples

### Text Part

```4d
var $part:=cs.GeminiPart.fromText("Hello world")

ALERT($part.text)  // "Hello world"
```

### Inline Image Part

```4d
// Load image and convert to base64
var $imageFile:=File("/RESOURCES/photo.jpg")
var $imageBlob:=$imageFile.getContent()
var $base64:=""
BASE64 ENCODE($imageBlob; $base64)

// Create part
var $part:=cs.GeminiPart.fromInlineData("image/jpeg"; $base64)

ALERT($part.inlineData.mimeType)  // "image/jpeg"
```

### File Reference Part

```4d
var $part:=cs.GeminiPart.new()
$part.fileData:={\
    fileUri: "files/abc123"; \
    mimeType: "application/pdf"}
```

### Function Call Part (from model response)

```4d
var $result:=$gemini.content.generate("What's the weather?"; "model"; $paramsWithTools)

If ($result.success)
    var $part:=$result.candidate.content.parts[0]

    If ($part.functionCall#Null)
        var $funcName:=$part.functionCall.name
        var $funcArgs:=$part.functionCall.args

        ALERT("Call: "+$funcName)
        ALERT("Args: "+JSON Stringify($funcArgs))

        // Execute function
        var $weather:=getWeather($funcArgs.location)

        // Create response part
        var $response:=cs.GeminiPart.new()
        $response.functionResponse:={\
            name: $funcName; \
            response: $weather}
    End if
End if
```

### Build Multi-Part Content

```4d
var $parts:=[]

// Add text
$parts.push(cs.GeminiPart.fromText("What's in these images?"))

// Add multiple images
var $images:=[File("/RESOURCES/img1.jpg"); File("/RESOURCES/img2.jpg")]

For each ($imageFile; $images)
    var $blob:=$imageFile.getContent()
    var $base64:=""
    BASE64 ENCODE($blob; $base64)

    $parts.push(cs.GeminiPart.fromInlineData("image/jpeg"; $base64))
End for each

// Use in request
var $content:={role: "user"; parts: $parts.map(Formula($1.value.toBody()))}
var $result:=$gemini.content.generate([$content]; "gemini-2.0-flash-exp")
```

### Mixed Content Types

```4d
var $content:=cs.GeminiContent.new()
$content.role:="user"

// Add text
$content.parts.push(cs.GeminiPart.fromText("Analyze this:"))

// Add image
var $imagePart:=cs.GeminiPart.fromInlineData("image/jpeg"; $base64Image)
$content.parts.push($imagePart)

// Add file reference
var $filePart:=cs.GeminiPart.new()
$filePart.fileData:={fileUri: "files/doc123"; mimeType: "application/pdf"}
$content.parts.push($filePart)
```

### Check Part Type

```4d
var $result:=$gemini.content.generate("Prompt"; "gemini-2.0-flash-exp")

If ($result.success)
    For each ($part; $result.candidate.content.parts)
        Case of
            : (Length($part.text)>0)
                ALERT("Text part: "+$part.text)
            : ($part.inlineData#Null)
                ALERT("Inline data: "+$part.inlineData.mimeType)
            : ($part.fileData#Null)
                ALERT("File: "+$part.fileData.fileUri)
            : ($part.functionCall#Null)
                ALERT("Function call: "+$part.functionCall.name)
            : ($part.functionResponse#Null)
                ALERT("Function response: "+$part.functionResponse.name)
        End case
    End for each
End if
```

### Extract Text from Parts

```4d
var $result:=$gemini.content.generate("Prompt"; "gemini-2.0-flash-exp")

If ($result.success)
    var $textParts:=[]

    For each ($part; $result.candidate.content.parts)
        If (Length($part.text)>0)
            $textParts.push($part.text)
        End if
    End for each

    var $fullText:=$textParts.join(" ")
    ALERT($fullText)
End if
```

### Function Call Handling

```4d
// Model requests function call
var $part:=cs.GeminiPart.new()
$part.functionCall:={\
    name: "get_current_weather"; \
    args: {location: "San Francisco"; unit: "celsius"}}

// Create response after executing function
var $responsePart:=cs.GeminiPart.new()
$responsePart.functionResponse:={\
    name: "get_current_weather"; \
    response: {temperature: 18; condition: "cloudy"}}
```

## Part Types

A part can contain only ONE of:
- `text` - Plain text
- `inlineData` - Base64-encoded data (images, audio, etc.)
- `fileData` - Reference to uploaded file
- `functionCall` - Function call from model
- `functionResponse` - Function result to model

## Inline Data Structure

```json
{
    "mimeType": "image/jpeg",
    "data": "base64encodeddata..."
}
```

## File Data Structure

```json
{
    "fileUri": "files/abc123",
    "mimeType": "application/pdf"
}
```

## Function Call Structure

```json
{
    "name": "function_name",
    "args": {"param1": "value1"}
}
```

## Function Response Structure

```json
{
    "name": "function_name",
    "response": {"result": "value"}
}
```

## See Also

- [GeminiContent](GeminiContent.md) - Content structure
- [GeminiCandidate](GeminiCandidate.md) - Response candidate
- [GeminiContentResult](GeminiContentResult.md) - Content result
