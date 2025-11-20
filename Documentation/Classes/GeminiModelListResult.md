# GeminiModelListResult

## Description

Result object for listing all available models. Contains a collection of model information objects.

## Inherits

[GeminiResult](GeminiResult.md)

## Functions

### get models

**models** : Collection

| Property        | Type       | Description                          |
|-----------------|------------|--------------------------------------|
| Function result | Collection | Collection of GeminiModel objects    |

Returns collection of all available models.

## Examples

### Basic Usage

```4d
var $result:=$gemini.models.list()

If ($result.success)
    For each ($model; $result.models)
        ALERT($model.displayName)
    End for each
End if
```

### Filter Gemini Models

```4d
var $result:=$gemini.models.list()

If ($result.success)
    // Filter models with "gemini" in the name
    var $geminiModels:=[]

    For each ($model; $result.models)
        If (Position("gemini"; Lowercase($model.name))>0)
            $geminiModels.push($model)
        End if
    End for each

    ALERT("Found "+String($geminiModels.length)+" Gemini models")
End if
```

### Find Model by Capability

```4d
var $result:=$gemini.models.list()

If ($result.success)
    // Find models that support generateContent
    var $contentModels:=[]

    For each ($model; $result.models)
        If ($model.supportedGenerationMethods.indexOf("generateContent")>=0)
            $contentModels.push($model)
        End if
    End for each

    ALERT("Models supporting content generation: "+String($contentModels.length))
End if
```

### Find Model with Highest Token Limit

```4d
var $result:=$gemini.models.list()

If ($result.success)
    var $bestModel:=Null
    var $maxTokens:=0

    For each ($model; $result.models)
        If ($model.inputTokenLimit>$maxTokens)
            $maxTokens:=$model.inputTokenLimit
            $bestModel:=$model
        End if
    End for each

    If ($bestModel#Null)
        ALERT("Highest input limit: "+$bestModel.displayName)
        ALERT("Tokens: "+String($maxTokens))
    End if
End if
```

### List Embedding Models

```4d
var $result:=$gemini.models.list()

If ($result.success)
    var $embeddingModels:=[]

    For each ($model; $result.models)
        If ($model.supportedGenerationMethods.indexOf("embedContent")>=0)
            $embeddingModels.push($model)
        End if
    End for each

    ALERT("Embedding models:")
    For each ($model; $embeddingModels)
        ALERT("  - "+$model.displayName)
    End for each
End if
```

### Compare Model Capabilities

```4d
var $result:=$gemini.models.list()

If ($result.success)
    ALERT("Model Comparison:")

    For each ($model; $result.models)
        var $info:=$model.displayName+": "
        $info+:=String($model.inputTokenLimit)+" in / "
        $info+:=String($model.outputTokenLimit)+" out"

        ALERT($info)
    End for each
End if
```

### Create Model Menu

```4d
var $result:=$gemini.models.list()

If ($result.success)
    var $menuRef:=Create menu

    For each ($model; $result.models)
        // Only add models supporting content generation
        If ($model.supportedGenerationMethods.indexOf("generateContent")>=0)
            APPEND MENU ITEM($menuRef; $model.displayName)
            SET MENU ITEM PARAMETER($menuRef; -1; $model.name)
        End if
    End for each

    var $choice:=Dynamic pop up menu($menuRef)
    // Use selected model
End if
```

### Find Model by Name

```4d
var $result:=$gemini.models.list()

If ($result.success)
    var $searchName:="flash"
    var $found:=False

    For each ($model; $result.models)
        If (Position($searchName; Lowercase($model.displayName))>0)
            ALERT("Found: "+$model.displayName)
            ALERT("Full name: "+$model.name)
            $found:=True
        End if
    End for each

    If (Not($found))
        ALERT("No model found matching: "+$searchName)
    End if
End if
```

### Group Models by Type

```4d
var $result:=$gemini.models.list()

If ($result.success)
    var $byType:={}

    For each ($model; $result.models)
        // Categorize by supported methods
        For each ($method; $model.supportedGenerationMethods)
            If ($byType[$method]=Null)
                $byType[$method]:=[]
            End if
            $byType[$method].push($model.displayName)
        End for each
    End for each

    // Display grouped models
    For each ($type; $byType)
        ALERT($type+":")
        For each ($modelName; $byType[$type])
            ALERT("  - "+$modelName)
        End for each
    End for each
End if
```

### Export Model Information

```4d
var $result:=$gemini.models.list()

If ($result.success)
    var $export:=[]

    For each ($model; $result.models)
        $export.push({\
            name: $model.displayName; \
            version: $model.version; \
            inputLimit: $model.inputTokenLimit; \
            outputLimit: $model.outputTokenLimit; \
            methods: $model.supportedGenerationMethods})
    End for each

    // Save to file
    var $file:=File("/PACKAGE/models.json")
    $file.setText(JSON Stringify($export; *))

    ALERT("Exported "+String($export.length)+" models")
End if
```

### Find Latest Version

```4d
var $result:=$gemini.models.list()

If ($result.success)
    var $modelFamily:="gemini-pro"
    var $versions:=[]

    For each ($model; $result.models)
        If (Position($modelFamily; Lowercase($model.name))>0)
            $versions.push({\
                model: $model; \
                version: $model.version})
        End if
    End for each

    // Sort by version (assuming semantic versioning)
    $versions:=$versions.orderBy("version desc")

    If ($versions.length>0)
        ALERT("Latest version: "+$versions[0].model.displayName)
    End if
End if
```

## Common Filters

### By Capability
```4d
$filtered:=$result.models.query("supportedGenerationMethods.indexOf(:1) >= 0"; "generateContent")
```

### By Name Pattern
```4d
var $geminiModels:=[]
For each ($model; $result.models)
    If (Position("gemini"; Lowercase($model.name))>0)
        $geminiModels.push($model)
    End if
End for each
```

### By Token Limit
```4d
$largeContext:=$result.models.query("inputTokenLimit > :1"; 50000)
```

## See Also

- [GeminiResult](GeminiResult.md) - Base result class
- [GeminiModel](GeminiModel.md) - Model structure
- [GeminiModelsAPI](GeminiModelsAPI.md) - Models API
- [GeminiModelResult](GeminiModelResult.md) - Single model result
