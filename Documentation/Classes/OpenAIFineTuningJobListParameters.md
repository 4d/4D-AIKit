# OpenAIFineTuningJobListParameters

The `OpenAIFineTuningJobListParameters` class defines parameters for listing fine-tuning jobs. It extends [OpenAIParameters](OpenAIParameters.md).

## Properties

| Property Name | Type    | Description                                                      |
|---------------|---------|------------------------------------------------------------------|
| `after`       | Text    | A cursor for use in pagination. `after` is an object ID that defines your place in the list. For example, if you make a list request and receive 20 objects ending with `ftjob-abc123`, your subsequent call can include `after=ftjob-abc123` to fetch the next page. |
| `limit`       | Integer | A limit on the number of objects to be returned. Limit can range between 1 and 10,000, and the default is 20. |
| `metadata`    | Object  | Filter by custom metadata key-value pairs. Only jobs with matching metadata will be returned. |

## Example

```4d
var $params:=cs.AIKit.OpenAIFineTuningJobListParameters.new()
$params.limit:=50

// Filter by metadata
$params.metadata:={}
$params.metadata.project:="customer-support"

var $result:=$client.fineTuning.list($params)

If ($result.success)
    var $jobs:=$result.jobs

    For each ($job; $jobs)
        // Process each job
    End for each

    // Paginate if needed
    If ($result.has_more)
        $params.after:=$result.last_id
        $result:=$client.fineTuning.list($params)
    End if
End if
```

## See also

- [OpenAIFineTuningAPI](OpenAIFineTuningAPI.md)
- [OpenAIFineTuningJobListResult](OpenAIFineTuningJobListResult.md)
- [OpenAIParameters](OpenAIParameters.md)
