# Provider Model Aliases

The OpenAI client supports provider model aliases, allowing you to define provider configurations in JSON files and reference them using a simple `provider:model` syntax.

## Overview

Instead of hard-coding API endpoints and credentials in your code, you can:
- Define provider configurations in a JSON file
- Use the `provider:model` syntax in API calls
- Switch between providers (OpenAI, Anthropic, local Ollama, etc.) easily

## Configuration Files

The client automatically loads provider configurations from the first existing file found (in priority order):

| Priority | Location | File Path |
|----------|----------|-----------|
| 1 (highest) | userData | `<data folder>/Settings/AIProviders.json` |
| 2 | user | `<database folder>/Settings/AIProviders.json` |
| 3 (lowest) | structure | `/SOURCES/AIProviders.json` |

**Important:** Only the **first existing file** is loaded. There is no merging of multiple files.

### Configuration File Format

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

## Usage in API Calls

### Model Parameter Format

Use the `provider:model_name` syntax in any API call that accepts a model parameter:

```4d
var $client := cs.AIKit.OpenAI.new()

// Chat completions
var $result := $client.chat.completions.create($messages; {model: "openai:gpt-4o"})
var $result := $client.chat.completions.create($messages; {model: "anthropic:claude-3-opus"})
var $result := $client.chat.completions.create($messages; {model: "local:llama3"})

// Embeddings
var $result := $client.embeddings.create("text"; "openai:text-embedding-3-small")
var $result := $client.embeddings.create("text"; "local:nomic-embed-text")

// Image generation
var $result := $client.images.generate("prompt"; {model: "openai:dall-e-3"})
```

### How It Works

When you use the `provider:model` syntax, the client automatically:

1. **Parses** the model string to extract provider name and model name
   - Example: `"openai:gpt-4o"` → provider=`"openai"`, model=`"gpt-4o"`

2. **Looks up** the provider configuration from the loaded JSON file
   - Retrieves `baseURL`, `apiKey`, `organization`, `project`

3. **Makes the API request** using the resolved configuration
   - Sends request to the provider's `baseURL` with the correct `apiKey`

### Using Plain Model Names

If you specify a model name **without** a provider prefix, the client uses the configuration from its constructor:

```4d
// Use constructor configuration
var $client := cs.AIKit.OpenAI.new({apiKey: "sk-..."; baseURL: "https://api.openai.com/v1"})
var $result := $client.chat.completions.create($messages; {model: "gpt-4o"})

// Override with provider alias
var $result := $client.chat.completions.create($messages; {model: "anthropic:claude-3-opus"})
```

## Examples

### Multi-Provider Chat Application

```4d
var $client := cs.AIKit.OpenAI.new()
var $messages := []
$messages.push({role: "user"; content: "What is the capital of France?"})

// Try OpenAI
var $result := $client.chat.completions.create($messages; {model: "openai:gpt-4o"})

// Try Anthropic
var $result := $client.chat.completions.create($messages; {model: "anthropic:claude-3-5-sonnet"})

// Try local Ollama
var $result := $client.chat.completions.create($messages; {model: "local:llama3.2"})
```

### Dynamic Provider Selection

```4d
var $client := cs.AIKit.OpenAI.new()
var $provider := "openai"  // Could come from user preference

// Build model string dynamically
var $modelString := $provider + ":gpt-4o"
var $result := $client.chat.completions.create($messages; {model: $modelString})
```

### Embeddings with Multiple Providers

```4d
var $client := cs.AIKit.OpenAI.new()
var $text := "Hello world"

// Use OpenAI embeddings
var $embedding1 := $client.embeddings.create($text; "openai:text-embedding-3-small")

// Use local embeddings
var $embedding2 := $client.embeddings.create($text; "local:nomic-embed-text")
```

## Configuration Management

Provider configurations can be managed through [4D Settings](https://developer.4d.com/docs/settings/overview) or by directly editing JSON files.

**To add or modify providers:**
1. Use 4D Settings interface (recommended), or
2. Edit the appropriate JSON file (userData, user, or structure)
3. Restart your application or create a new OpenAI client instance to load changes

**Recommended file location:**
- **For user-specific configs:** `<data folder>/Settings/AIProviders.json`
- **For application defaults:** `/SOURCES/AIProviders.json`

### No Reload Capability

Once a client is instantiated, it cannot reload provider configurations. To pick up configuration changes:

```4d
// Configuration changed - create new client
var $client := cs.AIKit.OpenAI.new()
```

## Security Considerations

When using 4D in remote/server mode, it is **strongly recommended** to execute AI-related code on the server side to protect API tokens and credentials from exposure to client machines.

## Common Use Cases

### Local Development with Ollama

```json
{
  "providers": {
    "local": {
      "baseURL": "http://localhost:11434/v1"
    }
  }
}
```

```4d
var $client := cs.AIKit.OpenAI.new()
var $result := $client.chat.completions.create($messages; {model: "local:llama3.2"})
```

### Production with Multiple Cloud Providers

```json
{
  "providers": {
    "openai": {
      "baseURL": "https://api.openai.com/v1",
      "apiKey": "your-openai-key"
    },
    "anthropic": {
      "baseURL": "https://api.anthropic.com/v1",
      "apiKey": "your-anthropic-key"
    },
    "azure": {
      "baseURL": "https://your-resource.openai.azure.com",
      "apiKey": "your-azure-key"
    }
  }
}
```

### Provider-Specific Organizations

```json
{
  "providers": {
    "openai-team-a": {
      "baseURL": "https://api.openai.com/v1",
      "organization": "org-team-a-id"
    },
    "openai-team-b": {
      "baseURL": "https://api.openai.com/v1",
      "organization": "org-team-b-id"
    }
  }
}
```

```4d
// Route to different organizations
var $resultA := $client.chat.completions.create($messages; {model: "openai-team-a:gpt-4o"})
var $resultB := $client.chat.completions.create($messages; {model: "openai-team-b:gpt-4o"})
```

## Related Documentation

- [OpenAI Class](Classes/OpenAI.md) - Main client class
- [OpenAIProviders Class](Classes/OpenAIProviders.md) - Provider configuration management
- [Compatible OpenAI APIs](compatible-openai.md) - List of compatible providers
