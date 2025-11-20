# GeminiModel

## Description

Represents information about a Gemini model. Contains model capabilities, token limits, and configuration parameters.

## Properties

| Property                      | Type       | Description                          |
|-------------------------------|------------|--------------------------------------|
| name                          | Text       | Full model identifier                |
| version                       | Text       | Model version                        |
| displayName                   | Text       | Human-readable name                  |
| description                   | Text       | Model description                    |
| inputTokenLimit               | Integer    | Maximum input tokens                 |
| outputTokenLimit              | Integer    | Maximum output tokens                |
| supportedGenerationMethods    | Collection | Supported API methods                |
| temperature                   | Real       | Default temperature                  |
| maxTemperature                | Real       | Maximum temperature                  |
| topP                          | Real       | Default top-P value                  |
| topK                          | Integer    | Default top-K value                  |

## Constructor

```4d
$model:=cs.GeminiModel.new($data)
```

## Examples

### Access Model Properties

```4d
var $result:=$gemini.models.retrieve("gemini-2.0-flash-exp")

If ($result.success)
    var $model:=$result.model

    ALERT("Name: "+$model.displayName)
    ALERT("Description: "+$model.description)
    ALERT("Version: "+$model.version)
    ALERT("Input limit: "+String($model.inputTokenLimit))
    ALERT("Output limit: "+String($model.outputTokenLimit))
End if
```

### Check Capabilities

```4d
var $result:=$gemini.models.retrieve("gemini-2.5-pro")

If ($result.success)
    var $model:=$result.model

    // Check if supports content generation
    If ($model.supportedGenerationMethods.indexOf("generateContent")>=0)
        ALERT("Supports content generation")
    End if

    // Check if supports embeddings
    If ($model.supportedGenerationMethods.indexOf("embedContent")>=0)
        ALERT("Supports embeddings")
    End if
End if
```

### Compare Token Limits

```4d
var $models:=["gemini-2.0-flash-exp"; "gemini-2.5-pro"]

For each ($modelName; $models)
    var $result:=$gemini.models.retrieve($modelName)

    If ($result.success)
        var $model:=$result.model

        ALERT($model.displayName)
        ALERT("  Input: "+String($model.inputTokenLimit))
        ALERT("  Output: "+String($model.outputTokenLimit))
    End if
End for each
```

### Check Temperature Limits

```4d
var $result:=$gemini.models.retrieve("gemini-2.0-flash-exp")

If ($result.success)
    var $model:=$result.model

    ALERT("Default temp: "+String($model.temperature))
    ALERT("Max temp: "+String($model.maxTemperature))

    // Use within limits
    var $params:=cs.GeminiContentParameters.new()
    $params.setGenerationConfig($model.maxTemperature; 1000; -1; -1)
End if
```

### Select Model by Requirement

```4d
// Need model with at least 100k input tokens
var $requiredTokens:=100000
var $result:=$gemini.models.list()

If ($result.success)
    For each ($model; $result.models)
        If ($model.inputTokenLimit>=$requiredTokens)
            ALERT("Suitable model: "+$model.displayName)
            // Use this model
            break
        End if
    End for each
End if
```

### Get Full Model Name

```4d
var $result:=$gemini.models.retrieve("gemini-2.0-flash-exp")

If ($result.success)
    var $model:=$result.model

    // Full name includes "models/" prefix
    ALERT("Full name: "+$model.name)  // "models/gemini-2.0-flash-exp"

    // Extract short name
    var $shortName:=$model.name
    If (Position("models/"; $shortName)=1)
        $shortName:=Substring($shortName; 8)
    End if
    ALERT("Short name: "+$shortName)  // "gemini-2.0-flash-exp"
End if
```

### Display Model Info

```4d
var $result:=$gemini.models.retrieve("gemini-2.5-pro")

If ($result.success)
    var $model:=$result.model

    var $info:=""
    $info+:="Model: "+$model.displayName+"\r\n"
    $info+:="Version: "+$model.version+"\r\n"
    $info+:="Description: "+$model.description+"\r\n"
    $info+:="Input tokens: "+String($model.inputTokenLimit)+"\r\n"
    $info+:="Output tokens: "+String($model.outputTokenLimit)+"\r\n"
    $info+:="Methods: "+$model.supportedGenerationMethods.join(", ")+"\r\n"

    ALERT($info)
End if
```

## Supported Generation Methods

Common methods include:
- `generateContent` - Text/content generation
- `embedContent` - Text embeddings
- `countTokens` - Token counting

## Model Naming

Model names follow the pattern:
- Full: `models/gemini-2.0-flash-exp`
- Display: `Gemini 2.0 Flash (Experimental)`
- Short: `gemini-2.0-flash-exp`

## Common Models

- `gemini-2.0-flash-exp` - Fast experimental model
- `gemini-2.5-pro` - Most capable model
- `gemini-2.5-flash` - Balanced model
- `text-embedding-004` - Embedding model

## See Also

- [GeminiModelResult](GeminiModelResult.md) - Model result
- [GeminiModelListResult](GeminiModelListResult.md) - Model list result
- [GeminiModelsAPI](GeminiModelsAPI.md) - Models API
