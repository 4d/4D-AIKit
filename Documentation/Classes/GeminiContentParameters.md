# GeminiContentParameters

## Description

Parameters for content generation requests. Allows configuration of generation behavior, safety settings, tool use, and system instructions.

## Inherits

[GeminiParameters](GeminiParameters.md)

## Properties

| Property          | Type       | Description                                    |
|-------------------|------------|------------------------------------------------|
| generationConfig  | Object     | Configuration for model generation             |
| safetySettings    | Collection | Safety filtering settings                      |
| tools             | Collection | Tools available to the model                   |
| systemInstruction | Variant    | System instruction (text or object)            |
| cachedContent     | Text       | Reference to cached content                    |

## Constructor

```4d
$params:=cs.GeminiContentParameters.new()
$params:=cs.GeminiContentParameters.new($object)
```

## Functions

### body()

**body**() : Object

Returns the request body with all configured parameters.

### setGenerationConfig()

**setGenerationConfig**(*temperature* : Real ; *maxOutputTokens* : Integer ; *topP* : Real ; *topK* : Integer)

| Parameter        | Type    | Description                                      |
|------------------|---------|--------------------------------------------------|
| temperature      | Real    | Sampling temperature (0.0 to 2.0)                |
| maxOutputTokens  | Integer | Maximum tokens to generate                       |
| topP             | Real    | Nucleus sampling threshold                       |
| topK             | Integer | Top-K sampling parameter                         |

Helper function to set generation configuration options.

## Examples

### Basic Generation Config

```4d
var $params:=cs.GeminiContentParameters.new()
$params.setGenerationConfig(0.7; 1000; -1; -1)

var $result:=$gemini.content.generate("Write a story"; "gemini-2.0-flash-exp"; $params)
```

### Manual Generation Config

```4d
var $params:=cs.GeminiContentParameters.new()
$params.generationConfig:={\
    temperature: 0.9; \
    maxOutputTokens: 2048; \
    topP: 0.95; \
    topK: 40; \
    candidateCount: 1; \
    stopSequences: ["END"]}

var $result:=$gemini.content.generate("Creative writing"; "gemini-2.5-pro"; $params)
```

### System Instruction (Text)

```4d
var $params:=cs.GeminiContentParameters.new()
$params.systemInstruction:="You are a helpful coding assistant. Always provide code examples with explanations."

var $result:=$gemini.content.generate("How do I sort an array?"; "gemini-2.0-flash-exp"; $params)
```

### System Instruction (Object)

```4d
var $params:=cs.GeminiContentParameters.new()
$params.systemInstruction:={parts: [{text: "You are a French tutor. Always respond in French."}]}

var $result:=$gemini.content.generate("Hello"; "gemini-2.0-flash-exp"; $params)
```

### Safety Settings

```4d
var $params:=cs.GeminiContentParameters.new()
$params.safetySettings:=[\
    {category: "HARM_CATEGORY_HARASSMENT"; threshold: "BLOCK_MEDIUM_AND_ABOVE"}; \
    {category: "HARM_CATEGORY_HATE_SPEECH"; threshold: "BLOCK_MEDIUM_AND_ABOVE"}; \
    {category: "HARM_CATEGORY_SEXUALLY_EXPLICIT"; threshold: "BLOCK_MEDIUM_AND_ABOVE"}; \
    {category: "HARM_CATEGORY_DANGEROUS_CONTENT"; threshold: "BLOCK_MEDIUM_AND_ABOVE"}]

var $result:=$gemini.content.generate("Your prompt"; "gemini-2.0-flash-exp"; $params)
```

### With Response Format (JSON)

```4d
var $params:=cs.GeminiContentParameters.new()
$params.generationConfig:={\
    temperature: 0.2; \
    responseMimeType: "application/json"; \
    responseSchema: {\
        type: "object"; \
        properties: {\
            name: {type: "string"}; \
            age: {type: "integer"}; \
            city: {type: "string"}}}}

var $result:=$gemini.content.generate("Extract person info: John Doe, 30, Paris"; "gemini-2.0-flash-exp"; $params)
```

### Function Calling / Tools

```4d
var $params:=cs.GeminiContentParameters.new()

// Define available tools
$params.tools:=[{\
    functionDeclarations: [{\
        name: "get_weather"; \
        description: "Get the current weather for a location"; \
        parameters: {\
            type: "object"; \
            properties: {\
                location: {type: "string"; description: "City name"}; \
                unit: {type: "string"; enum: ["celsius"; "fahrenheit"]}; \
            required: ["location"]}}]}]}]

var $result:=$gemini.content.generate("What's the weather in Paris?"; "gemini-2.0-flash-exp"; $params)

// Check if model wants to call a function
If ($result.candidates[0].content.parts[0].functionCall#Null)
    var $funcCall:=$result.candidates[0].content.parts[0].functionCall
    ALERT("Model wants to call: "+$funcCall.name)
End if
```

### Cached Content

```4d
// First, create cached content (see Gemini Caching documentation)
var $cacheId:="cachedContent/abc123"

var $params:=cs.GeminiContentParameters.new()
$params.cachedContent:=$cacheId

var $result:=$gemini.content.generate("Question about cached content"; "gemini-2.0-flash-exp"; $params)
```

### Combined Configuration

```4d
var $params:=cs.GeminiContentParameters.new()

// Generation settings
$params.setGenerationConfig(0.7; 1024; 0.95; 40)

// System instruction
$params.systemInstruction:="You are a helpful assistant."

// Safety settings
$params.safetySettings:=[\
    {category: "HARM_CATEGORY_HARASSMENT"; threshold: "BLOCK_ONLY_HIGH"}]

// Async callback
$params.onResponse:=Formula
    ALERT($1.value.candidates[0].text)
End formula

var $result:=$gemini.content.generate("Hello"; "gemini-2.0-flash-exp"; $params)
```

## Generation Config Options

| Option           | Type       | Description                                  |
|------------------|------------|----------------------------------------------|
| temperature      | Real       | 0.0 to 2.0 (higher = more random)           |
| maxOutputTokens  | Integer    | Maximum tokens to generate                   |
| topP             | Real       | Nucleus sampling (0.0 to 1.0)                |
| topK             | Integer    | Top-K sampling                               |
| candidateCount   | Integer    | Number of response candidates (default: 1)   |
| stopSequences    | Collection | Stop generation at these sequences           |
| responseMimeType | Text       | Output MIME type (e.g., "application/json")  |
| responseSchema   | Object     | JSON schema for structured output            |

## Safety Categories

- `HARM_CATEGORY_HARASSMENT`
- `HARM_CATEGORY_HATE_SPEECH`
- `HARM_CATEGORY_SEXUALLY_EXPLICIT`
- `HARM_CATEGORY_DANGEROUS_CONTENT`

## Safety Thresholds

- `BLOCK_NONE` - No blocking
- `BLOCK_ONLY_HIGH` - Block only high probability
- `BLOCK_MEDIUM_AND_ABOVE` - Block medium and high (default)
- `BLOCK_LOW_AND_ABOVE` - Block low, medium, and high

## See Also

- [GeminiParameters](GeminiParameters.md) - Base parameters class
- [GeminiContentAPI](GeminiContentAPI.md) - Content generation API
- [GeminiContentResult](GeminiContentResult.md) - Result structure
