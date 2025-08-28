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
| `parameters`  | [OpenAIFileParameters](OpenAIFileParameters.md) | Optional parameters for the request.                     |

**Returns:** [OpenAIFileResult](OpenAIFileResult.md)

**Throws:** An error if `file` is Null or if `purpose` is empty.

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

**Returns:** [OpenAIFileResult](OpenAIFileResult.md)

**Throws:** An error if `fileId` is empty.

### list()

Returns a list of files that belong to the user's organization.

| Argument Name | Type                           | Description                                               |
|---------------|--------------------------------|-----------------------------------------------------------|
| `parameters`  | [OpenAIFileListParameters](OpenAIFileListParameters.md) | Optional parameters for filtering and pagination.        |

**Returns:** [OpenAIFileListResult](OpenAIFileListResult.md)

### delete()

Delete a file.

| Argument Name | Type                           | Description                                               |
|---------------|--------------------------------|-----------------------------------------------------------|
| `fileId`      | Text                           | The ID of the file to delete.                            |
| `parameters`  | [OpenAIParameters](OpenAIParameters.md) | Optional parameters for the request.                     |

**Returns:** [OpenAIFileDeletedResult](OpenAIFileDeletedResult.md)

**Throws:** An error if `fileId` is empty.
