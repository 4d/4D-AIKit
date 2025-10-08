# OpenAIUploadPart

## Description
Represents a chunk of bytes added to an Upload object. Each Part can be up to 64 MB in size, and multiple Parts can be uploaded in parallel.

## Properties

| Property | Type | Description |
| -------- | ---- | ----------- |
| `id` | Text | The upload Part unique identifier, which can be referenced in API endpoints. |
| `object` | Text | The object type, which is always "upload.part". |
| `created_at` | Integer | The Unix timestamp (in seconds) for when the Part was created. |
| `upload_id` | Text | The ID of the Upload object that this Part was added to. |
 
## See Also
- [OpenAIUploadPartResult](OpenAIUploadPartResult.md)
- [OpenAIUploadsAPI](OpenAIUploadsAPI.md)
- [OpenAIUpload](OpenAIUpload.md)
- [OpenAI Uploads API Documentation](https://platform.openai.com/docs/api-reference/uploads/add-part)
