# OpenAIFile

The `OpenAIFile` class represents a file object in the OpenAI API.

## Properties

| Property Name    | Type     | Description                                                      |
|------------------|----------|------------------------------------------------------------------|
| `id`             | Text     | The file identifier, which can be referenced in the API endpoints. |
| `bytes`          | Integer  | The size of the file, in bytes.                                 |
| `created_at`     | Integer  | The Unix timestamp (in seconds) for when the file was created.  |
| `filename`       | Text     | The name of the file.                                           |
| `object`         | Text     | The object type, which is always "file".                        |
| `purpose`        | Text     | The intended purpose of the file.                               |
| `status`         | Text     | The current status of the file.                                 |
| `expires_at`     | Integer  | The Unix timestamp (in seconds) for when the file will expire.  |
| `status_details` | Text     | Additional details about the file status.                       |

## See also

- [OpenAIFileResult](OpenAIFileResult.md)
- [OpenAIFileListResult](OpenAIFileListResult.md)
