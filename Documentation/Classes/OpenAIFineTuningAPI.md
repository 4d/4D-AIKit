# OpenAIFineTuningAPI

The `OpenAIFineTuningAPI` class provides functionalities to manage fine-tuning jobs using OpenAI's API. Fine-tuning lets you create custom models from your own training data to improve performance on specific tasks.

> **Note:** This API is only compatible with OpenAI. Other providers listed in the [compatible providers](../compatible-openai.md) documentation do not support fine-tuning operations.

API Reference: <https://platform.openai.com/docs/api-reference/fine-tuning>

## Overview

Fine-tuning allows you to:
- Customize models for your specific use case
- Improve model performance on domain-specific tasks
- Reduce latency and costs by using smaller, specialized models

## Functions

### create()

**create**(*model* : Text; *training_file* : Text; *parameters* : cs.OpenAIFineTuningJobParameters) : cs.OpenAIFineTuningJobResult

Creates a fine-tuning job which begins the process of creating a new model from a given dataset.

**Endpoint:** `POST https://api.openai.com/v1/fine_tuning/jobs`

| Parameter       | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| *model*         | Text                           | **Required.** The name of the model to fine-tune (e.g., "gpt-4o-mini-2024-07-18"). |
| *training_file* | Text                           | **Required.** The ID of an uploaded file that contains training data. |
| *parameters*    | [OpenAIFineTuningJobParameters](OpenAIFineTuningJobParameters.md) | Optional parameters for the fine-tuning job. |
| Function result | [OpenAIFineTuningJobResult](OpenAIFineTuningJobResult.md) | The fine-tuning job result |

**Throws:** An error if `model` or `training_file` is empty.

#### Example

```4d
// First, upload a training file
var $trainingFile:=File("/RESOURCES/training-data.jsonl")
var $uploadResult:=$client.files.create($trainingFile; "fine-tune")

If ($uploadResult.success)
    // Create fine-tuning job
    var $params:=cs.AIKit.OpenAIFineTuningJobParameters.new()
    $params.suffix:="my-custom-model"
    $params.seed:=42

    var $result:=$client.fineTuning.create("gpt-4o-mini-2024-07-18"; $uploadResult.file.id; $params)

    If ($result.success)
        var $job:=$result.job
        // $job.id -> "ftjob-abc123"
        // $job.status -> "queued"
        // $job.model -> "gpt-4o-mini-2024-07-18"
    End if
End if
```

### retrieve()

**retrieve**(*fineTuningJobId* : Text; *parameters* : cs.OpenAIParameters) : cs.OpenAIFineTuningJobResult

Get info about a fine-tuning job.

**Endpoint:** `GET https://api.openai.com/v1/fine_tuning/jobs/{fine_tuning_job_id}`

| Parameter       | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| *fineTuningJobId* | Text                         | **Required.** The ID of the fine-tuning job.             |
| *parameters*    | [OpenAIParameters](OpenAIParameters.md) | Optional parameters for the request.                     |
| Function result | [OpenAIFineTuningJobResult](OpenAIFineTuningJobResult.md) | The fine-tuning job result |

**Throws:** An error if `fineTuningJobId` is empty.

#### Example

```4d
var $result:=$client.fineTuning.retrieve("ftjob-abc123")

If ($result.success)
    var $job:=$result.job
    // $job.status -> "running", "succeeded", "failed", etc.
    // $job.fine_tuned_model -> "ft:gpt-4o-mini-2024-07-18:my-org:my-custom-model:abc123"
    // $job.trained_tokens -> 50000
End if
```

### list()

**list**(*parameters* : cs.OpenAIFineTuningJobListParameters) : cs.OpenAIFineTuningJobListResult

List your organization's fine-tuning jobs.

**Endpoint:** `GET https://api.openai.com/v1/fine_tuning/jobs`

| Parameter       | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| *parameters*    | [OpenAIFineTuningJobListParameters](OpenAIFineTuningJobListParameters.md) | Optional parameters for filtering and pagination. |
| Function result | [OpenAIFineTuningJobListResult](OpenAIFineTuningJobListResult.md) | The fine-tuning job list result |

#### Example

```4d
var $params:=cs.AIKit.OpenAIFineTuningJobListParameters.new()
$params.limit:=20

var $result:=$client.fineTuning.list($params)

If ($result.success)
    var $jobs:=$result.jobs

    For each ($job; $jobs)
        // $job.id -> "ftjob-abc123"
        // $job.status -> "succeeded"
        // $job.fine_tuned_model -> "ft:gpt-4o-mini-2024-07-18:..."
    End for each

    If ($result.has_more)
        // More jobs available
        $params.after:=$result.last_id
    End if
End if
```

### cancel()

**cancel**(*fineTuningJobId* : Text; *parameters* : cs.OpenAIParameters) : cs.OpenAIFineTuningJobResult

Immediately cancel a fine-tuning job.

**Endpoint:** `POST https://api.openai.com/v1/fine_tuning/jobs/{fine_tuning_job_id}/cancel`

| Parameter       | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| *fineTuningJobId* | Text                         | **Required.** The ID of the fine-tuning job to cancel.   |
| *parameters*    | [OpenAIParameters](OpenAIParameters.md) | Optional parameters for the request.                     |
| Function result | [OpenAIFineTuningJobResult](OpenAIFineTuningJobResult.md) | The cancelled fine-tuning job result |

**Throws:** An error if `fineTuningJobId` is empty.

#### Example

```4d
var $result:=$client.fineTuning.cancel("ftjob-abc123")

If ($result.success)
    var $job:=$result.job
    // $job.status -> "cancelled"
End if
```

### listEvents()

**listEvents**(*fineTuningJobId* : Text; *parameters* : cs.OpenAIFineTuningJobListParameters) : cs.OpenAIFineTuningEventListResult

Get status updates for a fine-tuning job.

**Endpoint:** `GET https://api.openai.com/v1/fine_tuning/jobs/{fine_tuning_job_id}/events`

| Parameter       | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| *fineTuningJobId* | Text                         | **Required.** The ID of the fine-tuning job.             |
| *parameters*    | [OpenAIFineTuningJobListParameters](OpenAIFineTuningJobListParameters.md) | Optional parameters for pagination. |
| Function result | [OpenAIFineTuningEventListResult](OpenAIFineTuningEventListResult.md) | The fine-tuning event list result |

**Throws:** An error if `fineTuningJobId` is empty.

#### Example

```4d
var $params:=cs.AIKit.OpenAIFineTuningJobListParameters.new()
$params.limit:=50

var $result:=$client.fineTuning.listEvents("ftjob-abc123"; $params)

If ($result.success)
    var $events:=$result.events

    For each ($event; $events)
        // $event.message -> "Step 100/1000: training loss=0.23"
        // $event.level -> "info"
        // $event.created_at -> 1614807352
    End for each
End if
```

## See also

- [OpenAIFineTuningJob](OpenAIFineTuningJob.md)
- [OpenAIFineTuningJobParameters](OpenAIFineTuningJobParameters.md)
- [OpenAIFineTuningJobListParameters](OpenAIFineTuningJobListParameters.md)
- [OpenAIFineTuningJobResult](OpenAIFineTuningJobResult.md)
- [OpenAIFineTuningJobListResult](OpenAIFineTuningJobListResult.md)
- [OpenAIFineTuningEvent](OpenAIFineTuningEvent.md)
- [OpenAIFineTuningEventListResult](OpenAIFineTuningEventListResult.md)
