# OpenAIFineTuningEvent

The `OpenAIFineTuningEvent` class represents an event in a fine-tuning job's lifecycle. Events provide status updates and progress information during the fine-tuning process.

## Properties

| Property Name | Type    | Description                                                      |
|---------------|---------|------------------------------------------------------------------|
| `id`          | Text    | The event identifier.                                            |
| `object`      | Text    | The object type, which is always "fine_tuning.job.event".       |
| `created_at`  | Integer | The Unix timestamp (in seconds) for when the event was created. |
| `level`       | Text    | The severity level of the event: `info`, `warn`, or `error`.    |
| `message`     | Text    | The event message describing what happened.                      |
| `data`        | Object  | Additional data associated with the event.                       |
| `type`        | Text    | The type of event.                                               |

## Event Levels

The `level` property indicates the severity:

- `info`: Informational messages (e.g., progress updates, step completions)
- `warn`: Warning messages (e.g., potential issues that don't stop the job)
- `error`: Error messages (e.g., failures that caused the job to fail)

## See also

- [OpenAIFineTuningEventListResult](OpenAIFineTuningEventListResult.md)
- [OpenAIFineTuningAPI](OpenAIFineTuningAPI.md)
