# OpenAIFineTuningJobListResult

The `OpenAIFineTuningJobListResult` class represents the result of a list fine-tuning jobs operation. It extends [OpenAIResult](OpenAIResult.md).

## Functions

### jobs

**jobs** : Collection

Returns a collection of fine-tuning job objects from the API response.

| Property        | Type       | Description                                               |
|-----------------|------------|-----------------------------------------------------------|
| Function result | Collection | Collection of [OpenAIFineTuningJob](OpenAIFineTuningJob.md) objects, or empty collection if none found. |

### first_id

**first_id** : Text

Returns the ID of the first job in the list.

| Property        | Type | Description                                               |
|-----------------|------|-----------------------------------------------------------|
| Function result | Text | The first job ID, or empty string if not available.      |

### last_id

**last_id** : Text

Returns the ID of the last job in the list.

| Property        | Type | Description                                               |
|-----------------|------|-----------------------------------------------------------|
| Function result | Text | The last job ID, or empty string if not available.       |

### has_more

**has_more** : Boolean

Indicates if there are more jobs beyond this page.

| Property        | Type    | Description                                               |
|-----------------|---------|-----------------------------------------------------------|
| Function result | Boolean | True if there are more jobs to fetch.                    |

## Example

```4d
var $params:=cs.AIKit.OpenAIFineTuningJobListParameters.new()
$params.limit:=20

var $result:=$client.fineTuning.list($params)

If ($result.success)
    var $jobs:=$result.jobs

    For each ($job; $jobs)
        ALERT("Job: "+$job.id+" - Status: "+$job.status)

        If ($job.status="succeeded")
            ALERT("Model: "+$job.fine_tuned_model)
        End if
    End for each

    // Handle pagination
    While ($result.has_more)
        $params.after:=$result.last_id
        $result:=$client.fineTuning.list($params)

        If ($result.success)
            $jobs:=$result.jobs
            // Process next page...
        End if
    End while
Else
    var $error:=$result.error
    ALERT("Error: "+$error.message)
End if
```

## See also

- [OpenAIFineTuningJob](OpenAIFineTuningJob.md)
- [OpenAIFineTuningAPI](OpenAIFineTuningAPI.md)
- [OpenAIFineTuningJobListParameters](OpenAIFineTuningJobListParameters.md)
- [OpenAIResult](OpenAIResult.md)
