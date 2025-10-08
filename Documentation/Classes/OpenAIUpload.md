# OpenAIUpload

## Description
Represents a multipart file upload object in OpenAI. The Upload object allows you to upload large files (up to 8 GB) by breaking them into multiple parts.

## Properties

| Property | Type | Description |
| -------- | ---- | ----------- |
| `id` | Text | The Upload unique identifier, which can be referenced in API endpoints. |
| `object` | Text | The object type, which is always "upload". |
| `bytes` | Integer | The intended number of bytes to be uploaded. |
| `created_at` | Integer | The Unix timestamp (in seconds) for when the Upload was created. |
| `filename` | Text | The name of the file to be uploaded. |
| `purpose` | Text | The intended purpose of the file. Possible values: `assistants`, `batch`, `fine-tune`, `vision`, `user_data`. |
| `status` | Text | The status of the Upload. Possible values: `pending`, `completed`, `cancelled`, `expired`. |
| `expires_at` | Integer | The Unix timestamp (in seconds) for when the Upload will expire. |
| `file` | cs.AIKit.OpenAIFile | The ready File object after the Upload is completed. Only present when status is "completed". |
| `mime_type` | Text | The MIME type of the file (e.g., "text/jsonl", "image/png", "application/pdf"). Could be returned empty by API.|

## Constructor

```4d
$upload:=cs.AIKit.OpenAIUpload.new($object)
```

**Parameters:**
- `$object` (Object): Object containing upload properties

**Note:** This class is typically instantiated by the API response, not manually by users.

## Example

```4d
// After creating and completing an upload
var $result : cs.AIKit.OpenAIUploadResult
$result:=$client.uploads.complete($uploadId; $params)

If ($result.success)
    var $upload : cs.AIKit.OpenAIUpload
    $upload:=$result.upload
    
    ALERT("Upload ID: "+$upload.id)
    ALERT("Status: "+$upload.status)
    ALERT("Filename: "+$upload.filename)
    
    If ($upload.status="completed") && ($upload.file#Null)
        ALERT("File ID: "+$upload.file.id)
        ALERT("File ready for use!")
    End if 
End if 
```

## See Also
- [OpenAIUploadResult](OpenAIUploadResult.md)
- [OpenAIUploadsAPI](OpenAIUploadsAPI.md)
- [OpenAIUploadParameters](OpenAIUploadParameters.md)
- [OpenAIFile](OpenAIFile.md)
- [OpenAI Uploads API Documentation](https://platform.openai.com/docs/api-reference/uploads)
