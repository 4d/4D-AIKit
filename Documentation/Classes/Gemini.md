# Gemini

## Description

Main client class for interacting with Google's Gemini API. Provides access to content generation, embeddings, models, and file management services.

## Constructor

```4d
$gemini:=cs.Gemini.new($apiKey)
$gemini:=cs.Gemini.new($apiKey; $baseURL)
$gemini:=cs.Gemini.new($config)
```

| Parameter | Type   | Description                                          |
|-----------|--------|------------------------------------------------------|
| $apiKey   | Text   | Optional. Your Gemini API key (or set GEMINI_API_KEY env var) |
| $baseURL  | Text   | Optional. Custom base URL (default: https://generativelanguage.googleapis.com/v1beta) |
| $config   | Object | Optional. Configuration object with apiKey, baseURL, timeout, maxRetries, etc. |

## Properties

| Property      | Type          | Description                                    |
|---------------|---------------|------------------------------------------------|
| apiKey        | Text          | Gemini API key                                  |
| baseURL       | Text          | API base URL                                    |
| timeout       | Real          | Request timeout in seconds (default: 600)       |
| maxRetries    | Integer       | Maximum retry attempts (default: 2)             |
| httpAgent     | 4D.HTTPAgent  | Custom HTTP agent                               |
| customHeaders | Object        | Additional headers to send with requests        |
| content       | GeminiContentAPI | Content generation API                      |
| embeddings    | GeminiEmbeddingsAPI | Embeddings API                           |
| models        | GeminiModelsAPI | Models API                                   |
| files         | GeminiFilesAPI  | Files API                                    |

## Examples

### Basic Usage

```4d
// Initialize client with API key
var $gemini : cs.Gemini
$gemini:=cs.Gemini.new("YOUR_API_KEY")

// Or use environment variable
$gemini:=cs.Gemini.new()  // Reads from GEMINI_API_KEY

// Generate content
var $result : cs.GeminiContentResult
$result:=$gemini.content.generate("What is the meaning of life?"; "gemini-2.0-flash-exp")

If ($result.success)
    var $text : Text:=$result.candidates[0].text
    ALERT($text)
End if
```

### Advanced Configuration

```4d
var $config : Object
$config:={\
    apiKey: "YOUR_API_KEY"; \
    timeout: 30; \
    maxRetries: 3; \
    customHeaders: {}}

var $gemini:=cs.Gemini.new($config)
```

### Using Different Services

```4d
var $gemini:=cs.Gemini.new("YOUR_API_KEY")

// Content generation
var $content:=$gemini.content.generate("Hello"; "gemini-2.0-flash-exp")

// Embeddings
var $embedding:=$gemini.embeddings.create("Text to embed"; "text-embedding-004")

// List models
var $models:=$gemini.models.list()

// Upload file
var $file:=File("/RESOURCES/document.pdf")
var $fileResult:=$gemini.files.create($file; {displayName: "My Document"})
```

## Environment Variables

The Gemini client can read configuration from environment variables:

- `GEMINI_API_KEY`: Your Gemini API key
- `GEMINI_BASE_URL`: Custom base URL (optional)

## Authentication

Gemini uses API key authentication via the `x-goog-api-key` header. Get your API key from [Google AI Studio](https://aistudio.google.com/app/apikey).

## Error Handling

```4d
var $result:=$gemini.content.generate("test"; "invalid-model")

If (Not($result.success))
    var $error:=$result.errors[0]
    ALERT($error.message)
End if
```

## See Also

- [GeminiContentAPI](GeminiContentAPI.md) - Content generation
- [GeminiEmbeddingsAPI](GeminiEmbeddingsAPI.md) - Text embeddings
- [GeminiModelsAPI](GeminiModelsAPI.md) - Model information
- [GeminiFilesAPI](GeminiFilesAPI.md) - File management
