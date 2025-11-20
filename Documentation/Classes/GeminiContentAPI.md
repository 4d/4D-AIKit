# GeminiContentAPI

## Description

API for generating content using Gemini models. Supports text generation, multimodal inputs, system instructions, and configuration options.

## Access

```4d
var $gemini:=cs.Gemini.new($apiKey)
var $contentAPI:=$gemini.content
```

## Functions

### generate()

**generate**(*prompt* : Variant ; *model* : Text ; *parameters* : GeminiContentParameters) : GeminiContentResult

| Parameter       | Type                      | Description                                      |
|-----------------|---------------------------|--------------------------------------------------|
| *prompt*        | Text or Collection        | The text prompt or contents array                |
| *model*         | Text                      | Model name (e.g., "gemini-2.0-flash-exp")        |
| *parameters*    | GeminiContentParameters   | Optional generation parameters                   |
| Function result | GeminiContentResult       | The generation result                            |

Generates content using the specified model.

#### Example Usage

```4d
var $gemini:=cs.Gemini.new($apiKey)

// Simple text generation
var $result:=$gemini.content.generate("Explain quantum physics"; "gemini-2.0-flash-exp")

If ($result.success)
    var $text:=$result.candidates[0].text
    ALERT($text)
End if
```

### generateText()

**generateText**(*prompt* : Text ; *model* : Text ; *parameters* : GeminiContentParameters) : Text

| Parameter       | Type                      | Description                                      |
|-----------------|---------------------------|--------------------------------------------------|
| *prompt*        | Text                      | The text prompt                                  |
| *model*         | Text                      | Model name                                       |
| *parameters*    | GeminiContentParameters   | Optional generation parameters                   |
| Function result | Text                      | The generated text (convenience method)          |

Convenience method that returns the generated text directly.

#### Example Usage

```4d
var $response:=$gemini.content.generateText("Say hello"; "gemini-2.0-flash-exp")
ALERT($response)
```

## Examples

### Basic Text Generation

```4d
var $gemini:=cs.Gemini.new($apiKey)

var $result:=$gemini.content.generate("Write a haiku about coding"; "gemini-2.0-flash-exp")

If ($result.success)
    ALERT($result.candidates[0].text)
End if
```

### With Generation Config

```4d
var $params:=cs.GeminiContentParameters.new()
$params.setGenerationConfig(0.7; 500; -1; -1)  // temperature, maxTokens, topP, topK

var $result:=$gemini.content.generate("Write a creative story"; "gemini-2.0-flash-exp"; $params)
```

### With System Instruction

```4d
var $params:=cs.GeminiContentParameters.new()
$params.systemInstruction:="You are a helpful coding assistant. Always provide code examples."

var $result:=$gemini.content.generate("How do I sort an array?"; "gemini-2.0-flash-exp"; $params)
```

### Multimodal Input (Text + Image)

```4d
var $contents:=[]
$contents.push({parts: [{text: "What's in this image?"}]})

// Add image as inline data
var $imageData:="..."  // Base64 encoded image
$contents[0].parts.push({inlineData: {mimeType: "image/jpeg"; data: $imageData}})

var $result:=$gemini.content.generate($contents; "gemini-2.0-flash-exp")
```

### With Safety Settings

```4d
var $params:=cs.GeminiContentParameters.new()
$params.safetySettings:=[\
    {category: "HARM_CATEGORY_HARASSMENT"; threshold: "BLOCK_MEDIUM_AND_ABOVE"}; \
    {category: "HARM_CATEGORY_HATE_SPEECH"; threshold: "BLOCK_MEDIUM_AND_ABOVE"}]

var $result:=$gemini.content.generate("Your prompt"; "gemini-2.0-flash-exp"; $params)
```

## Available Models

Common Gemini models:
- `gemini-2.0-flash-exp` - Fast and efficient model
- `gemini-2.5-pro` - Most capable model for complex tasks
- `gemini-2.5-flash` - Balanced performance and speed

Use `$gemini.models.list()` to see all available models.

## Response Structure

The result contains:
- `candidates`: Array of candidate responses
- `candidate`: First candidate (convenience)
- `usage`: Token usage information
- `promptFeedback`: Feedback about the prompt

## Error Handling

```4d
var $result:=$gemini.content.generate("test"; "invalid-model")

If (Not($result.success))
    For each ($error; $result.errors)
        ALERT($error.message)
    End for each
End if
```

## See Also

- [Gemini](Gemini.md) - Main client class
- [GeminiContentParameters](GeminiContentParameters.md) - Generation parameters
- [GeminiContentResult](GeminiContentResult.md) - Result structure
- [GeminiCandidate](GeminiCandidate.md) - Response candidate
