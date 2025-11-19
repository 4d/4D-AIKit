# OpenAIFineTuningJob

The `OpenAIFineTuningJob` class represents a fine-tuning job object in the OpenAI API. Fine-tuning jobs are used to create custom models from training data.

## Properties

| Property Name      | Type       | Description                                                      |
|--------------------|------------|------------------------------------------------------------------|
| `id`               | Text       | The fine-tuning job identifier, which can be referenced in the API endpoints. |
| `object`           | Text       | The object type, which is always "fine_tuning.job".             |
| `created_at`       | Integer    | The Unix timestamp (in seconds) for when the fine-tuning job was created. |
| `finished_at`      | Integer    | The Unix timestamp (in seconds) for when the fine-tuning job was finished. Null if not finished. |
| `error`            | Object     | For fine-tuning jobs that have failed, this will contain more information on the cause of the failure. |
| `fine_tuned_model` | Text       | The name of the fine-tuned model that is being created. Null if the fine-tuning job is still running. |
| `hyperparameters`  | Object     | The hyperparameters used for the fine-tuning job.              |
| `model`            | Text       | The base model that is being fine-tuned.                        |
| `organization_id`  | Text       | The organization that owns the fine-tuning job.                 |
| `result_files`     | Collection | The compiled results file ID(s) for the fine-tuning job.        |
| `status`           | Text       | The current status of the fine-tuning job. Can be: `queued`, `running`, `succeeded`, `failed`, or `cancelled`. |
| `trained_tokens`   | Integer    | The total number of billable tokens processed by this fine-tuning job. Null if not yet calculated. |
| `training_file`    | Text       | The file ID used for training.                                  |
| `validation_file`  | Text       | The file ID used for validation. Null if not provided.          |
| `integrations`     | Collection | A list of integrations to enable for this fine-tuning job.     |
| `seed`             | Integer    | The seed used for the fine-tuning job.                          |
| `metadata`         | Object     | A set of 16 key-value pairs that can be attached to the fine-tuning job. |
| `method`           | Object     | The method configuration used for fine-tuning (supervised, DPO, reinforcement). |

## Status Values

The `status` property can have the following values:

- `queued`: The job is waiting to start
- `running`: The job is currently processing
- `succeeded`: The job completed successfully
- `failed`: The job failed (see `error` property for details)
- `cancelled`: The job was cancelled

## See also

- [OpenAIFineTuningJobResult](OpenAIFineTuningJobResult.md)
- [OpenAIFineTuningJobListResult](OpenAIFineTuningJobListResult.md)
- [OpenAIFineTuningAPI](OpenAIFineTuningAPI.md)
- [OpenAIFineTuningJobParameters](OpenAIFineTuningJobParameters.md)
