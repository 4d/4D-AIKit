# OpenAIProviders

## Summary

The `OpenAIProviders` class manages AI provider configurations by loading a single JSON configuration file and handling resolution of model strings in the `provider:model` format.

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

Creates a new instance that loads provider configuration from the first existing file found (in priority order):

| Priority | Location | File Path |
|----------|----------|-----------|
| 1 (highest) | userData | `<data folder>/Settings/AIProviders.json` |
| 2 | user | `<database folder>/Settings/AIProviders.json` |
| 3 (lowest) | structure | `/SOURCES/AIProviders.json` |

**Important:** Only the **first existing file** is loaded. There is no merging of multiple files.

## Configuration File Format

### Structure

```json
{
  "providers": {
    "provider_name": {
      "baseURL": "https://api.example.com/v1",
      "apiKey": "optional-key",
      "organization": "optional-org-id",
      "project": "optional-project-id"
    }
  }
}
```

### Provider Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `baseURL` | Text | Yes | API endpoint URL |
| `apiKey` | Text | No | API key value |
| `organization` | Text | No | Organization ID (optional, OpenAI-specific) |
| `project` | Text | No | Project ID (optional, OpenAI-specific) |

### Example Configuration

```json
{
  "providers": {
    "openai": {
      "baseURL": "https://api.openai.com/v1"
    },
    "anthropic": {
      "baseURL": "https://api.anthropic.com/v1"
    },
    "local": {
      "baseURL": "http://localhost:11434/v1"
    },
    "mistral": {
      "baseURL": "https://api.mistral.ai/v1",
      "apiKey": "your-mistral-key"
    }
  }
}
```

## Usage

### Integration with OpenAI Class

```4d
var $client := cs.OpenAI.new()

// Use model aliases with provider:model syntax
var $result := $client.chat.completions.create($messages; {model: "openai:gpt-4o"})
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

## Public Methods

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
$client.chat.completions.create($messages; {model: "openai:gpt-4o"})
```

This is resolved internally to:
1. Split `"openai:gpt-4o"` into provider=`"openai"` and model=`"gpt-4o"`
2. Look up the `"openai"` provider configuration
3. Extract `baseURL` and `apiKey`
4. Make the API request using the resolved configuration

**Format:** `provider:model_name`

**Examples:**
- `"openai:gpt-4o"` → Use OpenAI provider with gpt-4o model
- `"anthropic:claude-3-opus"` → Use Anthropic provider with claude-3-opus
- `"local:llama3"` → Use local provider with llama3 model

## Configuration Management

### No Reload Capability

Once a `OpenAIProviders` instance is created, it cannot be reloaded. If you need to pick up configuration changes, create a new instance:

```4d
// Configuration changed - create new instance
var $providers := cs.OpenAIProviders.new()
```

### Management Options

Provider configurations can be managed through [4D Settings](https://developer.4d.com/docs/settings/overview) or by directly editing JSON files.

**To add or modify providers:**
1. Use 4D Settings interface (recommended), or
2. Edit the appropriate JSON file (userData, user, or structure)
3. Create a new `OpenAIProviders` instance to load the changes

**Recommended file location:**
- For user-specific configs: `<data folder>/Settings/AIProviders.json`
- For application defaults: `/SOURCES/AIProviders.json`
