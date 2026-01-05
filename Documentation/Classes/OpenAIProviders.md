# OpenAIProviders

## Summary

The `OpenAIProviders` class is a **singleton** that manages AI provider configurations and handles resolution of model strings in the `provider:model` format.

## Description

This class enables multi-provider support by:
- Managing provider configurations in a centralized JSON file
- Resolving `provider:model` syntax to full API configurations
- Supporting listeners for CRUD operations with veto capability
- Providing delete/rename protection through listener patterns

## Configuration File

The configuration file is located at:
- `Settings/AIProviders.json`

### Example Configuration

```json
{
  "providers": {
    "openai": {
      "baseURL": "https://api.openai.com/v1",
      "apiKey": "sk-..."
    },
    "anthropic": {
      "baseURL": "https://api.anthropic.com/v1",
      "apiKeyEnv": "ANTHROPIC_API_KEY"
    },
    "mistral": {
      "baseURL": "https://api.mistral.ai/v1",
      "apiKey": "..."
    }
  }
}
```

### Provider Fields

| Field | Type | Description |
|-------|------|-------------|
| `baseURL` | Text | API endpoint URL (required) |
| `apiKey` | Text | API key value |
| `apiKeyEnv` | Text | Environment variable name for API key |
| `organization` | Text | Organization ID (optional) |
| `project` | Text | Project ID (optional) |

## Usage

### Basic Provider Resolution

```4d
var $providers:=cs.OpenAIProviders.me

// Resolve a model string to its configuration
var $config:=$providers.resolveModel("openai:gpt-4o")
// Returns: {success: True, baseURL: "https://api.openai.com/v1", apiKey: "sk-...", model: "gpt-4o"}

var $config:=$providers.resolveModel("mistral:mistral-large-latest")
// Returns: {success: True, baseURL: "https://api.mistral.ai/v1", apiKey: "...", model: "mistral-large-latest"}
```

### Managing Providers

```4d
var $providers:=cs.OpenAIProviders.me

// Add a provider
$providers.addProvider("myProvider"; {baseURL: "https://api.example.com/v1"; apiKey: "key123"})

// Get a provider
var $config:=$providers.getProvider("myProvider")

// Modify a provider
$providers.modifyProvider("myProvider"; {apiKey: "newKey456"})

// Rename a provider
var $result:=$providers.renameProvider("myProvider"; "renamedProvider")
If (Not($result.success))
    ALERT($result.message)
End if

// Remove a provider
var $result:=$providers.removeProvider("renamedProvider")
If (Not($result.success))
    ALERT($result.message)
End if

// Get all provider keys
var $keys:=$providers.getProviderKeys()
// Returns: ["openai", "anthropic", "mistral"]

// Save changes
$providers.save()
```

---

## Methods

### Configuration Management

#### `providersFile` (property)

Get or set the providers configuration file.

```4d
$providers.providersFile:=File("/RESOURCES/custom-providers.json")
```

#### `load() -> Boolean`

Load providers from the configuration file.

```4d
var $success:=$providers.load()
```

#### `save()`

Save current providers to the configuration file.

```4d
$providers.save()
```

---

### Provider CRUD Operations

#### `addProvider($key : Text; $config : Object) -> cs.OpenAIProviders`

Add or update a provider configuration.

| Parameter | Type | Description |
|-----------|------|-------------|
| `$key` | Text | Provider name/key |
| `$config` | Object | Provider configuration |

```4d
$providers.addProvider("azure"; {baseURL: "https://myinstance.openai.azure.com"; apiKey: "..."})
```

#### `getProvider($key : Text) -> Object`

Get a provider configuration by key.

```4d
var $config:=$providers.getProvider("openai")
// Returns: {baseURL: "...", apiKey: "...", ...} or Null
```

#### `getProviderKeys() -> Collection`

Get all provider keys.

```4d
var $keys:=$providers.getProviderKeys()
// Returns: ["openai", "anthropic", ...]
```

#### `modifyProvider($key : Text; $updates : Object) -> Boolean`

Merge updates into an existing provider configuration.

```4d
var $success:=$providers.modifyProvider("openai"; {organization: "org-123"})
```

#### `renameProvider($oldKey : Text; $newKey : Text) -> Object`

Rename a provider. Checks with listeners before proceeding.

**Returns:** `{success: Boolean, message: Text}`

```4d
var $result:=$providers.renameProvider("oldName"; "newName")
If (Not($result.success))
    ALERT($result.message)  // e.g., "Provider is used by vector 'MyVector'"
End if
```

#### `removeProvider($key : Text) -> Object`

Remove a provider. Checks with listeners before proceeding.

**Returns:** `{success: Boolean, message: Text}`

```4d
var $result:=$providers.removeProvider("myProvider")
If (Not($result.success))
    ALERT($result.message)
End if
```

---

### Model Resolution

#### `resolveModel($modelString : Text) -> Object`

Resolve a model string to its full configuration.

**Returns:**
| Property | Type | Description |
|----------|------|-------------|
| `success` | Boolean | True if resolution succeeded |
| `baseURL` | Text | API endpoint URL |
| `apiKey` | Text | API key |
| `model` | Text | Actual model name to use |
| `error` | Text | Error message if resolution failed |

```4d
var $config:=$providers.resolveModel("openai:gpt-4o")
If ($config.success)
    // Use $config.baseURL, $config.apiKey, $config.model
End if
```

---

### Listener Pattern

The class supports listeners that can:
1. **Veto** operations (remove, rename) by returning `{success: False, message: "reason"}`
2. **React** to events after they occur

#### `addListener($listener : Object) -> cs.OpenAIProviders`

Register a listener object.

#### `removeListener($listener : Object) -> Boolean`

Unregister a listener object.

### Veto Events (called before operation)

Listeners can implement these methods to veto operations:

| Event | Parameters | Description |
|-------|------------|-------------|
| `canRemoveProvider` | `{key}` | Return `{success: False, message: "..."}` to block deletion |
| `canRenameProvider` | `{oldKey, newKey}` | Return `{success: False, message: "..."}` to block rename |

### Notification Events (called after operation)

| Event | Parameters | Description |
|-------|------------|-------------|
| `onLoad` | `{}` | Configuration loaded |
| `onSave` | `{}` | Configuration saved |
| `onProviderAdded` | `{key, config}` | Provider added/updated |
| `onProviderRemoved` | `{key}` | Provider removed |
| `onProviderModified` | `{key, updates}` | Provider modified |
| `onProviderRenamed` | `{oldKey, newKey, config}` | Provider renamed |
| `onModelResolved` | `{modelString, config}` | Model string resolved |

### Example: Delete Protection Listener

```4d
// Create a listener that blocks deletion if provider is used by a vector
var $vectorProtector:={\
    vectors: $myVectorCollection; \
    canRemoveProvider: Formula(\
        var $usedBy:=This.vectors.query("providerName = :1"; $1.key)\
        If ($usedBy.length>0)\
            return {success: False; message: "Provider is used by vector '"+$usedBy[0].name+"'"}\
        End if\
        return {success: True; message: ""}\
    )\
}

cs.OpenAIProviders.me.addListener($vectorProtector)

// Now removeProvider will fail if the provider is used
var $result:=cs.OpenAIProviders.me.removeProvider("myProvider")
If (Not($result.success))
    ALERT($result.message)  // "Provider is used by vector 'MyVector'"
End if
```

### Example: Rename Propagation Listener

```4d
// Create a listener that updates vector references on rename
var $renameHandler:={\
    vectors: $myVectorCollection; \
    onProviderRenamed: Formula(\
        For each ($v; This.vectors.query("providerName = :1"; $1.oldKey))\
            $v.providerName:=$1.newKey\
        End for each\
    )\
}

cs.OpenAIProviders.me.addListener($renameHandler)
```

---

### Collection Conversion (UI Compatibility)

#### `toCollection() -> Collection`

Convert providers to a collection format for UI list display.

```4d
var $list:=$providers.toCollection()
// Returns: [{name: "openai", apiKey: "...", baseURL: "..."}, ...]
```

#### `fromCollection($models : Collection)`

Import from collection format and save.

```4d
$providers.fromCollection($modifiedList)
```
