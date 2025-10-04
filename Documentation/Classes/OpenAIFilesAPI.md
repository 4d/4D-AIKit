# OpenAIFilesAPI

The `OpenAIFilesAPI` class provides functionalities to manage files using OpenAI's API. Files can be uploaded and used across various endpoints including Assistants, Fine-tuning, Batch processing, and Vision.

API Reference: <https://platform.openai.com/docs/api-reference/files>

## File Size Limits

- **Individual files:** up to 512 MB
- **Organization total:** up to 1 TB
- **Assistants API:** files up to 2 million tokens
- **Batch API:** .jsonl files up to 200 MB

## Functions

### create()

Upload a file that can be used across various endpoints.

**Endpoint:** `POST https://api.openai.com/v1/files`

| Argument Name | Type                           | Description                                               |
|---------------|--------------------------------|-----------------------------------------------------------|
| `file`        | [4D.File](https://developer.4d.com/docs/API/FileClass) or [4D.Blob](https://developer.4d.com/docs/API/BlobClass) | The File or Blob object (not file name) to be uploaded. |
| `purpose`     | Text                           | **Required.** The intended purpose of the uploaded file. |
| `parameters`  | [OpenAIFileParameters](OpenAIFileParameters.md) | Optional parameters including expiration policy.         |

**Returns:** [OpenAIFileResult](OpenAIFileResult.md)

**Throws:** An error if `file` is not a 4D.File or 4D.Blob, or if `purpose` is empty.

#### Supported Purposes

- `assistants`: Used in the Assistants API
- `batch`: Used in the Batch API (expires after 30 days by default)
- `fine-tune`: Used for fine-tuning
- `vision`: Images used for vision fine-tuning
- `user_data`: Flexible file type for any purpose
- `evals`: Used for eval data sets

#### File Format Requirements

- **Fine-tuning API:** Only supports `.jsonl` files with specific required formats
- **Batch API:** Only supports `.jsonl` files up to 200 MB with specific required format
- **Assistants API:** Supports specific file types (see Assistants Tools guide)

#### Example

```4d
var $file:=File("/RESOURCES/training-data.jsonl")

var $params:=cs.AIKit.OpenAIFileParameters.new()
$params.expires_after:={}
$params.expires_after.anchor:="created_at"
$params.expires_after.seconds:=2592000  // 30 days

var $result:=$client.files.create($file; "fine-tune"; $params)

If ($result.error=Null)
    var $uploadedFile:=$result.file
    // $uploadedFile.id -> "file-abc123"
    // $uploadedFile.filename -> "training-data.jsonl"
    // $uploadedFile.bytes -> 120000
End if
```

### retrieve()

Returns information about a specific file.

**Endpoint:** `GET https://api.openai.com/v1/files/{file_id}`

| Argument Name | Type                           | Description                                               |
|---------------|--------------------------------|-----------------------------------------------------------|
| `fileId`      | Text                           | **Required.** The ID of the file to retrieve.            |
| `parameters`  | [OpenAIParameters](OpenAIParameters.md) | Optional parameters for the request.                     |

**Returns:** [OpenAIFileResult](OpenAIFileResult.md)

**Throws:** An error if `fileId` is empty.

#### Example

```4d
var $result:=$client.files.retrieve("file-abc123"; Null)

If ($result.error=Null)
    var $file:=$result.file
    // $file.filename -> "mydata.jsonl"
    // $file.bytes -> 120000
    // $file.purpose -> "fine-tune"
End if
```

### list()

Returns a list of files that belong to the user's organization.

**Endpoint:** `GET https://api.openai.com/v1/files`

| Argument Name | Type                           | Description                                               |
|---------------|--------------------------------|-----------------------------------------------------------|
| `parameters`  | [OpenAIFileListParameters](OpenAIFileListParameters.md) | Optional parameters for filtering and pagination.        |

**Returns:** [OpenAIFileListResult](OpenAIFileListResult.md)

#### Example

```4d
var $params:=cs.AIKit.OpenAIFileListParameters.new()
$params.purpose:="assistants"
$params.limit:=50
$params.order:="desc"

var $result:=$client.files.list($params)

If ($result.error=Null)
    var $files:=$result.files
    // $files.length -> 2
    
    For each ($file; $files)
        // $file.filename -> "salesOverview.pdf", "puppy.jsonl", etc.
    End for each
End if
```

### delete()

Delete a file.

**Endpoint:** `DELETE https://api.openai.com/v1/files/{file_id}`

| Argument Name | Type                           | Description                                               |
|---------------|--------------------------------|-----------------------------------------------------------|
| `fileId`      | Text                           | **Required.** The ID of the file to delete.              |
| `parameters`  | [OpenAIParameters](OpenAIParameters.md) | Optional parameters for the request.                     |

**Returns:** [OpenAIFileDeletedResult](OpenAIFileDeletedResult.md)

**Throws:** An error if `fileId` is empty.

#### Example

```4d
var $result:=$client.files.delete("file-abc123"; Null)

If ($result.error=Null)
    var $status:=$result.deleted
    
    If ($status.deleted)
        ALERT("File deleted successfully")
    End if
End if
```

## See also

- [OpenAIFile](OpenAIFile.md)
- [OpenAIFileParameters](OpenAIFileParameters.md)
- [OpenAIFileListParameters](OpenAIFileListParameters.md)
- [OpenAIFileResult](OpenAIFileResult.md)
- [OpenAIFileListResult](OpenAIFileListResult.md)
- [OpenAIFileDeletedResult](OpenAIFileDeletedResult.md)
