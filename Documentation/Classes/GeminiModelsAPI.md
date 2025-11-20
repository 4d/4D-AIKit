# GeminiModelsAPI

## Description

API for retrieving information about available Gemini models. Use this to list models, get model capabilities, and check supported features.

## Access

```4d
var $gemini:=cs.Gemini.new($apiKey)
var $modelsAPI:=$gemini.models
```

## Functions

### list()

**list**(*parameters* : GeminiParameters) : GeminiModelListResult

| Parameter       | Type                    | Description                    |
|-----------------|-------------------------|--------------------------------|
| *parameters*    | GeminiParameters        | Optional request parameters    |
| Function result | GeminiModelListResult   | List of available models       |

Lists all available Gemini models.

#### Example Usage

```4d
var $gemini:=cs.Gemini.new($apiKey)

var $result:=$gemini.models.list()

If ($result.success)
    For each ($model; $result.models)
        ALERT($model.displayName+" - "+$model.description)
    End for each
End if
```

### retrieve()

**retrieve**(*model* : Text ; *parameters* : GeminiParameters) : GeminiModelResult

| Parameter       | Type                | Description                              |
|-----------------|---------------------|------------------------------------------|
| *model*         | Text                | Model name (e.g., "gemini-2.0-flash-exp") |
| *parameters*    | GeminiParameters    | Optional request parameters              |
| Function result | GeminiModelResult   | Model information                        |

Retrieves detailed information about a specific model.

#### Example Usage

```4d
var $result:=$gemini.models.retrieve("gemini-2.0-flash-exp")

If ($result.success)
    var $model:=$result.model
    ALERT("Input limit: "+String($model.inputTokenLimit))
    ALERT("Output limit: "+String($model.outputTokenLimit))
End if
```

## Examples

### List All Models

```4d
var $gemini:=cs.Gemini.new($apiKey)

var $result:=$gemini.models.list()

If ($result.success)
    For each ($model; $result.models)
        TRACE  // Display model info
    End for each
End if
```

### Filter Gemini Models

```4d
var $result:=$gemini.models.list()

If ($result.success)
    var $geminiModels:=$result.models.query("name == :1"; "@gemini@")

    For each ($model; $geminiModels)
        ALERT($model.displayName)
    End for each
End if
```

### Get Model Capabilities

```4d
var $result:=$gemini.models.retrieve("gemini-2.0-flash-exp")

If ($result.success)
    var $model:=$result.model

    // Check capabilities
    ALERT("Name: "+$model.displayName)
    ALERT("Description: "+$model.description)
    ALERT("Input token limit: "+String($model.inputTokenLimit))
    ALERT("Output token limit: "+String($model.outputTokenLimit))

    // Check supported methods
    For each ($method; $model.supportedGenerationMethods)
        ALERT("Supports: "+$method)
    End for each
End if
```

### Choose Best Model for Task

```4d
var $result:=$gemini.models.list()

If ($result.success)
    // Find model with highest token limit
    var $bestModel:=Null
    var $maxTokens:=0

    For each ($model; $result.models)
        If ($model.inputTokenLimit>$maxTokens)
            $maxTokens:=$model.inputTokenLimit
            $bestModel:=$model
        End if
    End for each

    ALERT("Best model: "+$bestModel.displayName)
End if
```

## Model Properties

Each model object contains:

| Property                      | Type       | Description                              |
|-------------------------------|------------|------------------------------------------|
| name                          | Text       | Full model name (e.g., "models/gemini-2.0-flash-exp") |
| version                       | Text       | Model version                            |
| displayName                   | Text       | Human-readable name                      |
| description                   | Text       | Model description                        |
| inputTokenLimit               | Integer    | Maximum input tokens                     |
| outputTokenLimit              | Integer    | Maximum output tokens                    |
| supportedGenerationMethods    | Collection | Supported methods (generateContent, etc.) |
| temperature                   | Real       | Default temperature                      |
| maxTemperature                | Real       | Maximum temperature                      |
| topP                          | Real       | Default top-P value                      |
| topK                          | Integer    | Default top-K value                      |

## Common Model Names

- `gemini-2.0-flash-exp` - Fast experimental model
- `gemini-2.5-pro` - Most capable model
- `gemini-2.5-flash` - Balanced speed and capability
- `text-embedding-004` - Embedding model

## Error Handling

```4d
var $result:=$gemini.models.retrieve("invalid-model-name")

If (Not($result.success))
    For each ($error; $result.errors)
        ALERT("Error: "+$error.message)
    End for each
End if
```

## See Also

- [Gemini](Gemini.md) - Main client class
- [GeminiModelResult](GeminiModelResult.md) - Single model result
- [GeminiModelListResult](GeminiModelListResult.md) - Model list result
- [GeminiModel](GeminiModel.md) - Model data structure
