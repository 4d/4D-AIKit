# OpenAIFilesAPI

The `OpenAIFilesAPI` class provides functionalities to manage files using OpenAI's API. Files can be uploaded and used across various endpoints including Assistants, Fine-tuning, and Batch processing.

<https://platform.openai.com/docs/api-reference/files>

## Functions

### create()

Upload a file that can be used across various endpoints.

| Argument Name | Type                           | Description                                               |
|---------------|--------------------------------|-----------------------------------------------------------|
| `file`        | [4D.File](https://developer.4d.com/docs/API/FileClass) | The File object to be uploaded.                         |
| `purpose`     | Text                           | The intended purpose of the uploaded file.               |
| `parameters`  | [OpenAIParameters](OpenAIParameters.md) | Optional parameters for the request.                     |

**Returns:** [OpenAIFilesResult](OpenAIFilesResult.md)

Individual files can be up to 512 MB, and the size of all files uploaded by one organization can be up to 100 GB.

Supported purposes:

- `assistants`: Used in the Assistants API
- `batch`: Used in the Batch API  
- `fine-tune`: Used for fine-tuning
- `vision`: Images used for vision fine-tuning
- `user_data`: Flexible file type for any purpose
- `evals`: Used for eval data sets

### retrieve()

Returns information about a specific file.

| Argument Name | Type                           | Description                                               |
|---------------|--------------------------------|-----------------------------------------------------------|
| `fileId`      | Text                           | The ID of the file to retrieve.                          |
| `parameters`  | [OpenAIParameters](OpenAIParameters.md) | Optional parameters for the request.                     |

**Returns:** [OpenAIFilesResult](OpenAIFilesResult.md)

### list()

Returns a list of files that belong to the user's organization.

| Argument Name | Type                           | Description                                               |
|---------------|--------------------------------|-----------------------------------------------------------|
| `parameters`  | [OpenAIFilesListParameters](OpenAIFilesListParameters.md) | Optional parameters for filtering and pagination.        |

**Returns:** [OpenAIFilesListResult](OpenAIFilesListResult.md)

### delete()

Delete a file.

| Argument Name | Type                           | Description                                               |
|---------------|--------------------------------|-----------------------------------------------------------|
| `fileId`      | Text                           | The ID of the file to delete.                            |
| `parameters`  | [OpenAIParameters](OpenAIParameters.md) | Optional parameters for the request.                     |

**Returns:** [OpenAIFilesDeletedResult](OpenAIFilesDeletedResult.md)

### content()

Returns the contents of the specified file.

| Argument Name | Type                           | Description                                               |
|---------------|--------------------------------|-----------------------------------------------------------|
| `fileId`      | Text                           | The ID of the file whose content to retrieve.            |
| `parameters`  | [OpenAIParameters](OpenAIParameters.md) | Optional parameters for the request.                     |

**Returns:** [OpenAIResult](OpenAIResult.md) - The raw file content

## Example

```4d
var $client:=cs.AIKit.OpenAI.new("your api key")

// Upload a file
var $file:=File("/Users/username/documents/data.jsonl")
var $result:=$client.files.create($file; "fine-tune")

If ($result.success)
    var $fileId:=$result.file.id
    
    // Retrieve file information
    var $fileInfo:=$client.files.retrieve($fileId)
    
    // List all files
    var $allFiles:=$client.files.list()
    
    // Delete the file
    var $deleted:=$client.files.delete($fileId)
End if
```

## Parent

[OpenAIAPIResource](OpenAIAPIResource.md)
