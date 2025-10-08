# OpenAIUploadResult

## Description
Result class for Upload operations (create, complete, or cancel). Contains the upload object returned by the API along with success/error status.

## Inherits

[OpenAIResult](OpenAIResult.md)

## Properties

| Property | Type | Description |
| -------- | ---- | ----------- |
| `upload` | cs.AIKit.OpenAIUpload | Returns the upload object from the API response. Returns Null if the response is invalid. |
 
## See Also
- [OpenAIUpload](OpenAIUpload.md)
- [OpenAIUploadsAPI](OpenAIUploadsAPI.md)
- [OpenAI Uploads API Documentation](https://platform.openai.com/docs/api-reference/uploads)
