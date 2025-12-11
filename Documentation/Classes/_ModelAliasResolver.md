# _ModelAliasResolver

## Summary

The `_ModelAliasResolver` class is an internal utility class that handles resolution of model strings in the `provider:model` format to their full configuration (baseURL, apiKey, and actual model name).

## Description

This class enables multi-provider support by allowing you to define provider configurations in a centralized `ai-providers.json` file and reference them using simple `provider:model` syntax.

## Configuration File

The configuration file should be placed at:
- `Resources/ai-providers.json`

### Example Configuration

```json
{
  "providers": {
    "openai": {
      "baseURL": "https://api.openai.com/v1",
      "apiKeyEnv": "OPENAI_API_KEY"
    },
    "anthropic": {
      "baseURL": "https://api.anthropic.com/v1",
      "apiKeyEnv": "ANTHROPIC_API_KEY"
    },
    "4d": {
      "models": {
        "mychatmodel": {
          "baseURL": "https://api.mistral.ai/v1",
          "apiKeyEnv": "MISTRAL_API_KEY",
          "modelName": "mistral-small-latest"
        }
      }
    }
  }
}
```

## Usage

Model aliases are automatically resolved when using the `OpenAI` client:

```4d
var $client := cs.AIKit.OpenAI.new()

// Use OpenAI
var $messages := []
$messages.push({role: "user"; content: "Hello!"})
var $result := $client.chat.completions.create($messages; {model: "openai:gpt-4o"})

// Use Anthropic
var $result := $client.chat.completions.create($messages; {model: "anthropic:claude-3-opus"})

// Use custom model alias
var $result := $client.chat.completions.create($messages; {model: "4d:mychatmodel"})
```

## Methods

### setProvidersFile($filePath : Text)

Set a custom path for the providers configuration file.

### resolveModel($modelString : Text) -> Object

Resolve a model string to its configuration. Returns an object with:
- `success` : Boolean
- `baseURL` : Text
- `apiKey` : Text  
- `model` : Text (the actual model name to use)
- `error` : Text (error message if resolution failed)

### hasConfiguration() -> Boolean

Returns True if a valid providers configuration file exists.
