# OpenAIFineTuningJobResult

The `OpenAIFineTuningJobResult` class represents the result of a fine-tuning job operation (create, retrieve, or cancel). It extends [OpenAIResult](OpenAIResult.md).

## Functions

### job

**job** : cs.OpenAIFineTuningJob

Returns the fine-tuning job object from the API response.

| Property        | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| Function result | [OpenAIFineTuningJob](OpenAIFineTuningJob.md) | The fine-tuning job object, or Null if invalid response. |

## Example

```4d
var $result:=$client.fineTuning.create("gpt-4o-mini-2024-07-18"; "file-abc123")

If ($result.success)
    var $job:=$result.job

    // Access job properties
    ALERT("Job ID: "+$job.id)
    ALERT("Status: "+$job.status)
    ALERT("Model: "+$job.model)

    If ($job.status="succeeded")
        ALERT("Fine-tuned model: "+$job.fine_tuned_model)
    End if
Else
    // Handle error
    var $error:=$result.error
    ALERT("Error: "+$error.message)
End if
```

## See also

- [OpenAIFineTuningJob](OpenAIFineTuningJob.md)
- [OpenAIFineTuningAPI](OpenAIFineTuningAPI.md)
- [OpenAIResult](OpenAIResult.md)
