# OpenAIModelsAPI

## Class Description
`OpenAIModelsAPI` is a class that allows interaction with OpenAI models through various functions, such as retrieving model information, listing available models, and (optionally) deleting fine-tuned models.

## Functions

### `retrieve`

Retrieves a model instance to provide basic information.

| Parameter   | Type                      | Description                                   |
|-------------|---------------------------|-----------------------------------------------|
| `$model`    | Text                      | The identifier of the model to retrieve.     |
| `$parameters` | [OpenAIParameters](OpenAIParameters)     | Additional parameters for the request.       |

#### Return: [OpenAIModelResult](OpenAIModelResult)

#### Example usage:

```4d
var $result:=$client.model.retrieve("text-davinci-003"; $parameters)
// $result.model
```

### `list`

Lists the currently available models.

| Parameter   | Type                      | Description                                   |
|-------------|---------------------------|-----------------------------------------------|
| `$parameters` | [OpenAIParameters](OpenAIParameters) | Additional parameters for the request.       |

#### Return: [OpenAIModelListResult](OpenAIModelListResult)

#### Example usage:

```4d 
var $result:=$client.model.list($parameters)
// $result.models
```