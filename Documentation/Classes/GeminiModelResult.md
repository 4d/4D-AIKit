# GeminiModelResult

## Description

Result object for single model retrieval. Contains detailed information about a specific Gemini model.

## Inherits

[GeminiResult](GeminiResult.md)

## Functions

### get model

**model** : cs.GeminiModel

| Property        | Type        | Description              |
|-----------------|-------------|--------------------------|
| Function result | GeminiModel | The model information    |

Returns the model object with all properties.

## Examples

### Basic Usage

```4d
var $result:=$gemini.models.retrieve("gemini-2.0-flash-exp")

If ($result.success)
    var $model:=$result.model

    ALERT("Name: "+$model.displayName)
    ALERT("Input limit: "+String($model.inputTokenLimit))
    ALERT("Output limit: "+String($model.outputTokenLimit))
End if
```

### Check Model Capabilities

```4d
var $result:=$gemini.models.retrieve("gemini-2.5-pro")

If ($result.success)
    var $model:=$result.model

    ALERT("Display name: "+$model.displayName)
    ALERT("Description: "+$model.description)
    ALERT("Version: "+$model.version)

    // Check token limits
    ALERT("Max input tokens: "+String($model.inputTokenLimit))
    ALERT("Max output tokens: "+String($model.outputTokenLimit))

    // Check supported methods
    ALERT("Supported methods:")
    For each ($method; $model.supportedGenerationMethods)
        ALERT("  - "+$method)
    End for each
End if
```

### Check Model Parameters

```4d
var $result:=$gemini.models.retrieve("gemini-2.0-flash-exp")

If ($result.success)
    var $model:=$result.model

    // Temperature settings
    ALERT("Default temperature: "+String($model.temperature))
    ALERT("Max temperature: "+String($model.maxTemperature))

    // Top-P and Top-K
    ALERT("Top-P: "+String($model.topP))
    ALERT("Top-K: "+String($model.topK))
End if
```

### Validate Model Before Use

```4d
var $modelName:="gemini-2.5-pro"
var $result:=$gemini.models.retrieve($modelName)

If ($result.success)
    var $model:=$result.model

    // Check if model supports generateContent
    If ($model.supportedGenerationMethods.indexOf("generateContent")>=0)
        // Model supports content generation
        var $contentResult:=$gemini.content.generate("Test"; $modelName)
    Else
        ALERT("Model doesn't support content generation")
    End if
End if
```

### Compare Models

```4d
var $models:=["gemini-2.0-flash-exp"; "gemini-2.5-pro"]
var $modelInfo:=[]

For each ($modelName; $models)
    var $result:=$gemini.models.retrieve($modelName)

    If ($result.success)
        $modelInfo.push({\
            name: $result.model.displayName; \
            inputLimit: $result.model.inputTokenLimit; \
            outputLimit: $result.model.outputTokenLimit})
    End if
End for each

// Compare limits
For each ($info; $modelInfo)
    ALERT($info.name+": "+String($info.inputLimit)+" / "+String($info.outputLimit))
End for each
```

### Choose Model Based on Requirements

```4d
var $requiredInputTokens:=50000

var $result:=$gemini.models.retrieve("gemini-2.5-pro")

If ($result.success)
    var $model:=$result.model

    If ($model.inputTokenLimit>=$requiredInputTokens)
        ALERT("Model can handle required input length")
        // Use this model
    Else
        ALERT("Model input limit too small")
        // Try different model
    End if
End if
```

### Get Full Model Name

```4d
var $result:=$gemini.models.retrieve("gemini-2.0-flash-exp")

If ($result.success)
    var $model:=$result.model

    // Full name includes "models/" prefix
    ALERT("Full name: "+$model.name)
    ALERT("Display name: "+$model.displayName)
End if
```

### Error Handling

```4d
var $result:=$gemini.models.retrieve("non-existent-model")

If (Not($result.success))
    For each ($error; $result.errors)
        ALERT("Error "+String($error.status)+": "+$error.message)
    End for each
End if
```

## Model Properties

The `model` object contains:
- `name` - Full model identifier (e.g., "models/gemini-2.0-flash-exp")
- `version` - Model version
- `displayName` - Human-readable name
- `description` - Model description
- `inputTokenLimit` - Maximum input tokens
- `outputTokenLimit` - Maximum output tokens
- `supportedGenerationMethods` - Supported methods
- `temperature` - Default temperature
- `maxTemperature` - Maximum temperature
- `topP` - Default top-P value
- `topK` - Default top-K value

## Supported Generation Methods

Common methods:
- `generateContent` - Text generation
- `embedContent` - Embedding creation
- `countTokens` - Token counting

## See Also

- [GeminiResult](GeminiResult.md) - Base result class
- [GeminiModel](GeminiModel.md) - Model structure
- [GeminiModelsAPI](GeminiModelsAPI.md) - Models API
- [GeminiModelListResult](GeminiModelListResult.md) - Model list result
