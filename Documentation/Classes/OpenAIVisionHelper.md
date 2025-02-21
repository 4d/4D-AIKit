# OpenAIVisionHelper

## Functions

### prompt

| Argument     | Type                                         |
|--------------|----------------------------------------------|
| `$prompt`    | `Text`                                       |
| `$parameters`| [`OpenAIChatCompletionParameters`](OpenAIChatCompletionParameters.md)    |

### Description

Sends a prompt to the OpenAI chat API along with an associated image URL, and optionally accepts parameters for the chat completion.

### Example Usage

```4d
var $helper:=$client.chat.vision.create($imageURL)

var $result:=$helper.prompt($prompt; $parameters)
```