# GeminiAPIResource

## Description

Base class for all Gemini API resource classes. Provides access to the Gemini client instance.

## Properties

| Property | Type        | Description                |
|----------|-------------|----------------------------|
| _client  | cs.Gemini   | Reference to Gemini client |

## Constructor

```4d
$resource:=cs.GeminiAPIResource.new($client)
```

| Parameter | Type      | Description       |
|-----------|-----------|-------------------|
| $client   | cs.Gemini | Gemini client     |

## Usage

This class is not typically instantiated directly. It serves as a base class for API resource classes like:
- `GeminiContentAPI`
- `GeminiEmbeddingsAPI`
- `GeminiModelsAPI`
- `GeminiFilesAPI`

## Example

```4d
// Not used directly, but inherited by API classes
Class extends GeminiAPIResource

Class constructor($client : cs.Gemini)
    Super($client)

Function someMethod()
    // Access client through This._client
    return This._client._get("/path"; $params; cs.GeminiResult)
```

## See Also

- [Gemini](Gemini.md) - Main client class
- [GeminiContentAPI](GeminiContentAPI.md) - Content API
- [GeminiEmbeddingsAPI](GeminiEmbeddingsAPI.md) - Embeddings API
- [GeminiModelsAPI](GeminiModelsAPI.md) - Models API
- [GeminiFilesAPI](GeminiFilesAPI.md) - Files API
