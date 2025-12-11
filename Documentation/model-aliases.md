# Model Aliases

Model aliases allow you to define provider configurations in a centralized file and reference them using a simple `provider:model` syntax.

## Quick Start

1. Copy `Resources/ai-providers.template.json` to your `Resources/ai-providers.json`
2. Configure your providers and API keys
3. Use the `provider:model` syntax in your code

```4d
var $client := cs.AIKit.OpenAI.new()

// Use different providers with the same client
var $result := $client.chat.completions.create($messages; {model: "openai:gpt-4o"})
var $result := $client.chat.completions.create($messages; {model: "anthropic:claude-3-opus"})
var $result := $client.chat.completions.create($messages; {model: "local:llama3"})
```

## Configuration File

Create `Resources/ai-providers.json`:

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
    "local": {
      "baseURL": "http://localhost:11434/v1"
    }
  }
}
```

### Configuration Options

| Property | Description |
|----------|-------------|
| `baseURL` | The API endpoint URL (required) |
| `apiKey` | Direct API key value |
| `apiKeyEnv` | Environment variable name containing the API key |
| `models` | Nested model-specific configurations |
| `models.<name>.modelName` | Actual model name to send to the API |

## Model Syntax

### Simple Provider

```
provider:model
```

Examples:
- `openai:gpt-4o` → calls OpenAI with model `gpt-4o`
- `anthropic:claude-3-opus` → calls Anthropic with model `claude-3-opus`
- `local:llama3` → calls local server with model `llama3`

### Custom Model Aliases

Define custom aliases that map to specific configurations:

```json
{
  "providers": {
    "4d": {
      "models": {
        "chat": {
          "baseURL": "https://api.mistral.ai/v1",
          "apiKeyEnv": "MISTRAL_API_KEY",
          "modelName": "mistral-small-latest"
        },
        "embedder": {
          "baseURL": "https://api.openai.com/v1",
          "apiKeyEnv": "OPENAI_API_KEY",
          "modelName": "text-embedding-3-small"
        }
      }
    }
  }
}
```

Usage:
```4d
$client.chat.completions.create($messages; {model: "4d:chat"})
$client.embeddings.create("Hello"; "4d:embedder")
```

### No Prefix (Default Behavior)

Models without a prefix use the client's instance configuration:

```4d
var $client := cs.AIKit.OpenAI.new({apiKey: "..."; baseURL: "..."})
$client.chat.completions.create($messages; {model: "gpt-4o"})  // Uses instance config
```

## API Key Resolution

API keys are resolved in this order:

1. `apiKey` in model definition
2. `apiKey` in provider definition  
3. `apiKeyEnv` environment variable (model-level)
4. `apiKeyEnv` environment variable (provider-level)
5. Search providers with matching `baseURL`

## Security

- Add `Resources/ai-providers.json` to `.gitignore` (already configured)
- Use `apiKeyEnv` to reference environment variables instead of storing keys directly
- Use the template file for documentation: `Resources/ai-providers.template.json`
