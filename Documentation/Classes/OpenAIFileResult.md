# OpenAIFileResult

The `OpenAIFileResult` class contains the result of a single file operation (upload or retrieve).

## Inherits

[OpenAIResult](OpenAIResult.md)

## Computed properties

| Property | Type          | Description                                                                 |
|----------|---------------|-----------------------------------------------------------------------------|
| `file`   | [OpenAIFile](OpenAIFile.md) | Returns the file object from the API response. Returns `Null` if the response doesn't contain a valid file. |

## Example Usage

```4d
// Upload a file
var $file:=File("/RESOURCES/training-data.jsonl")

var $result:=$client.files.create($file; "user_data; $params)
var $uploadedFile:=$result.file

// Retrieve file information
var $retrieveResult:=$client.files.retrieve($uploadedFile.id; Null)
```

## See also

- [OpenAIFilesAPI](OpenAIFilesAPI.md)
- [OpenAIFile](OpenAIFile.md)
