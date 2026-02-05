# OpenAIProviders

## Summary

The `OpenAIProviders` class manages AI provider configurations by loading configuration and handling resolution of model strings in the `provider:model` format.

For complete usage documentation, see [Provider Model Aliases](../provider-model-aliases.md).

## Description

This class enables multi-provider support by:
- Loading provider configurations from a single JSON file
- Resolving `provider:model` syntax to full API configurations

The `OpenAI` class automatically loads provider configurations when instantiated.

## Constructor

```4d
var $providers := cs.OpenAIProviders.new()
```

Creates a new instance that loads provider configuration from the `AIProviders.json` file. See [Configuration Files](../provider-model-aliases.md#configuration-files) in the Provider Model Aliases documentation for details on file locations and format.

**Important:** Only the **first existing file** is loaded. There is no merging of multiple files.

## Usage

### Integration with OpenAI Class

```4d
var $client := cs.OpenAI.new()

// Use model aliases with provider:model syntax
var $result := $client.chat.completions.create($messages; {model: "openai:gpt-5.1"})
var $result := $client.chat.completions.create($messages; {model: "anthropic:claude-3-opus"})
var $result := $client.chat.completions.create($messages; {model: "local:llama3"})
```

### Direct Provider Access

```4d
var $providers := cs.OpenAIProviders.new()

// Get a specific provider configuration
var $config := $providers.get("openai")
// Returns: {baseURL: "...", apiKey: "...", ...} or Null

// Get all provider names
var $names := $providers.list()
// Returns: ["openai", "anthropic", "mistral", "local"]
```

## Functions

### get()

**get**(*name* : Text) : Object

Get a provider configuration by name.

| Parameter | Type | Description |
|-----------|------|-------------|
| *name* | Text | The provider name |
| Function result | Object | Provider configuration object, or `Null` if not found |

#### Example

```4d
var $config := $providers.get("openai")
If ($config # Null)
    // Use $config.baseURL, $config.apiKey, etc.

    // We could build a client with it
    var $client:=cs.OpenAI.new($config)
End if
```

### list()

**list**() : Collection

Get all provider names.

| Parameter | Type | Description |
|-----------|------|-------------|
| Function result | Collection | Collection of provider names |

#### Example

```4d
var $names := $providers.list()
// Returns: ["openai", "anthropic", ...]

For each ($name; $names)
    var $config := $providers.get($name)
End for each
```

## Model Resolution

The `provider:model` syntax allows you to specify which provider to use for a given model:

```4d
var $client := cs.OpenAI.new()
$client.chat.completions.create($messages; {model: "openai:gpt-5.1"})
```

This is resolved internally to:
1. Split `"openai:gpt-5.1"` into provider=`"openai"` and model=`"gpt-5.1"`
2. Look up the `"openai"` provider configuration
3. Extract `baseURL` and `apiKey`
4. Make the API request using the resolved configuration

**Format:** `provider:model_name`

**Examples:**
- `"openai:gpt-5.1"` → Use OpenAI provider with gpt-5.1 model
- `"anthropic:claude-3-opus"` → Use Anthropic provider with claude-3-opus
- `"local:llama3"` → Use local provider with llama3 model
