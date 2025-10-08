# OpenAIUploadCompleteParameters

## Description
Optional parameters for completing an Upload.

## Inherits

[OpenAIParameters](OpenAIParameters.md)

## Properties

| Property | Type | Required | Default | Description |
| -------- | ---- | -------- | ------- | ----------- |
| `md5` | Text | No | `Null` | The optional MD5 checksum for the file contents to verify if the bytes uploaded matches what you expect. This provides an additional verification step to ensure file integrity. |

## Example

```4d
VAR $uploadId:="upload_abc123"
VAR $partIds:=["part_def456"; "part_ghi789"; "part_jkl012"]

$md5Hash:="5d41402abc4b2a76b9719d911017c592"  // Example MD5
var $completeParams:=cs.AIKit.OpenAIUploadCompleteParameters.new()
$completeParams.md5:=$md5Hash  // Optional verification

// Complete the upload - part_ids is passed as explicit parameter
$result:=$client.uploads.complete($uploadId; $partIds; $completeParams)
```

## See Also
- [OpenAIUpload](OpenAIUpload.md)
- [OpenAIUploadResult](OpenAIUploadResult.md)
- [OpenAIUploadPart](OpenAIUploadPart.md)
- [OpenAIUploadsAPI](OpenAIUploadsAPI.md)
- [OpenAI Uploads API Documentation](https://platform.openai.com/docs/api-reference/uploads/complete)
