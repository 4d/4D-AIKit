# OpenAIUploadParameters

## Description
Optional parameters for creating an Upload object in OpenAI.

## Inherits

[OpenAIParameters](OpenAIParameters.md)

## Properties

| Property | Type | Required | Default | Description |
| -------- | ---- | -------- | ------- | ----------- |
| `expires_after` | Object | No | `Null` | The expiration policy for a file. By default, files with `purpose=batch` expire after 30 days and all other files are persisted until they are manually deleted. Object structure: `{anchor: "created_at", seconds: 3600}` where `seconds` must be between 3600 (1 hour) and 2592000 (30 days). |


## Example 

```4d
var $params:=cs.AIKit.OpenAIUploadParameters.new({\
    expires_after: {\
        anchor: "created_at"; \
        seconds: 7200\
    }\
})

// Mandatory parameters are passed to the function
$result:=$client.uploads.create("large_dataset.jsonl"; 2147483648; "batch"; "text/jsonl"; $params)
```

## See Also
- [OpenAIUpload](OpenAIUpload.md)
- [OpenAIUploadResult](OpenAIUploadResult.md)
- [OpenAIUploadsAPI](OpenAIUploadsAPI.md)
- [OpenAIParameters](OpenAIParameters.md)
- [OpenAI Uploads API Documentation](https://platform.openai.com/docs/api-reference/uploads/create)
