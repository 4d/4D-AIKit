# OpenAIFileParameters

The `OpenAIFileParameters` class contains parameters for file operations.

## Inherits

[OpenAIParameters](OpenAIParameters.md)

## Properties

| Property Name | Type   | Description                          |
|---------------|--------|--------------------------------------|
| `expires_after` | Object | The expiration policy for a file. By default, files with purpose=batch expire after 30 days and all other files are persisted until they are manually deleted. |

### `expires_after` Object Structure

The `expires_after` object contains the following properties:

| Property Name | Type    | Description                          |
|---------------|---------|--------------------------------------|
| `anchor`      | Text    | Anchor timestamp after which the expiration policy applies. Supported anchors: `created_at`. |
| `seconds`     | Integer | The number of seconds after the anchor time that the file will expire. Must be between 3600 (1 hour) and 2592000 (30 days). |
