# OpenAIUploadPartResult

## Description
Result class for Upload Part operations. Contains the upload part object returned by the API after adding a part to an upload, along with success/error status.

## Inherits

[OpenAIResult](OpenAIResult.md)

## Properties

| Property | Type | Description |
| -------- | ---- | ----------- |
| `part` | cs.AIKit.OpenAIUploadPart | (read-only) Returns the upload part object from the API response. Returns Null if the response is invalid. |

## See Also
- [OpenAIUploadPart](OpenAIUploadPart.md)
- [OpenAIUploadsAPI](OpenAIUploadsAPI.md)
- [OpenAI Uploads API Documentation](https://platform.openai.com/docs/api-reference/uploads/add-part)
