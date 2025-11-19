# OpenAIFineTuningJobParameters

The `OpenAIFineTuningJobParameters` class defines parameters for creating a fine-tuning job. It extends [OpenAIParameters](OpenAIParameters.md).

## Properties

| Property Name    | Type       | Description                                                      |
|------------------|------------|------------------------------------------------------------------|
| `hyperparameters`| Object     | **Deprecated.** The hyperparameters used for the fine-tuning job. Use `method` instead. |
| `method`         | Object     | The method configuration for fine-tuning (supervised, DPO, reinforcement). |
| `suffix`         | Text       | A string of up to 64 characters that will be added to your fine-tuned model name. |
| `validation_file`| Text       | The ID of an uploaded file that contains validation data.       |
| `seed`           | Integer    | The seed controls the reproducibility of the job. Use the same seed and parameters to get identical results. |
| `integrations`   | Collection | A list of integrations to enable for your fine-tuning job.     |
| `metadata`       | Object     | A set of 16 key-value pairs that can be attached to the fine-tuning job for organizational purposes. |

## Method Configuration

The `method` object can specify different fine-tuning approaches:

### Supervised Fine-Tuning

```4d
$params.method:={}
$params.method.type:="supervised"
$params.method.hyperparameters:={}
$params.method.hyperparameters.n_epochs:=3
$params.method.hyperparameters.batch_size:=4
$params.method.hyperparameters.learning_rate_multiplier:=0.1
```

### DPO (Direct Preference Optimization)

```4d
$params.method:={}
$params.method.type:="dpo"
$params.method.dpo:={}
$params.method.dpo.hyperparameters:={}
$params.method.dpo.hyperparameters.n_epochs:=1
```

## Example

```4d
var $params:=cs.AIKit.OpenAIFineTuningJobParameters.new()
$params.suffix:="my-model-v1"
$params.seed:=42

// Configure supervised fine-tuning method
$params.method:={}
$params.method.type:="supervised"
$params.method.hyperparameters:={}
$params.method.hyperparameters.n_epochs:=4

// Add metadata for organization
$params.metadata:={}
$params.metadata.project:="customer-support"
$params.metadata.version:="1.0"

var $result:=$client.fineTuning.create("gpt-4o-mini-2024-07-18"; "file-abc123"; $params)
```

## See also

- [OpenAIFineTuningAPI](OpenAIFineTuningAPI.md)
- [OpenAIFineTuningJobResult](OpenAIFineTuningJobResult.md)
- [OpenAIParameters](OpenAIParameters.md)
