# OpenAIFineTuningEventListResult

The `OpenAIFineTuningEventListResult` class represents the result of a list fine-tuning events operation. It extends [OpenAIResult](OpenAIResult.md).

## Functions

### events

**events** : Collection

Returns a collection of fine-tuning event objects from the API response.

| Property        | Type       | Description                                               |
|-----------------|------------|-----------------------------------------------------------|
| Function result | Collection | Collection of [OpenAIFineTuningEvent](OpenAIFineTuningEvent.md) objects, or empty collection if none found. |

### has_more

**has_more** : Boolean

Indicates if there are more events beyond this page.

| Property        | Type    | Description                                               |
|-----------------|---------|-----------------------------------------------------------|
| Function result | Boolean | True if there are more events to fetch.                  |

## Example

```4d
var $params:=cs.AIKit.OpenAIFineTuningJobListParameters.new()
$params.limit:=50

var $result:=$client.fineTuning.listEvents("ftjob-abc123"; $params)

If ($result.success)
    var $events:=$result.events

    For each ($event; $events)
        var $timestamp:=String(Timestamp to date($event.created_at))
        var $message:=$event.message
        var $level:=$event.level

        ALERT("[$timestamp] [$level] $message")
    End for each

    // Handle pagination
    If ($result.has_more)
        // Fetch next page of events...
    End if
Else
    var $error:=$result.error
    ALERT("Error: "+$error.message)
End if
```

## See also

- [OpenAIFineTuningEvent](OpenAIFineTuningEvent.md)
- [OpenAIFineTuningAPI](OpenAIFineTuningAPI.md)
- [OpenAIResult](OpenAIResult.md)
