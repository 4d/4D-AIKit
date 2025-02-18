# OpenAIModerationsAPI

The `OpenAIModerationsAPI` class extends `OpenAIAPIResource` and is responsible for classifying if text and/or image inputs are potentially harmful.
 
## Functions

### create

Classifies whether the input is potentially harmful. 

#### Arguments

| Argument   | Type                     | Description                                                   |
|------------|--------------------------|---------------------------------------------------------------|
| `$input`     | Variant                  | Input (or inputs) to classify. Can be a single text or a collection of texts. |
| `$model`     | Text                     | The content moderation model you would like to use.          |
| `$parameters` | cs.OpenAIParameters     | Additional parameters for the request.                       |

#### Returns

This function returns an instance of [OpenAIModerationResult](OpenAIModerationResult).

## Example Usage

```4d
$result := $client;moderation..create("Some text to classify"; "text-moderation-model"; $parameters)
```