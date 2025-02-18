# OpenAIVisionHelper

## Class Constructor

### OpenAIVisionHelper constructor

| Argument          | Type                                   |
|-------------------|----------------------------------------|
| `$chat`           | [OpenAIChatAPI](OpenAIChatAPI)              |
| `$imageURL`       | `Text`                                 |

### Description
Initializes an instance of the OpenAIVisionHelper class with the specified OpenAIChatAPI and image URL.

## Functions

### prompt

| Argument     | Type                                         |
|--------------|----------------------------------------------|
| `$prompt`    | `Text`                                       |
| `$parameters`| `cs.OpenAIChatCompletionParameters`    |

### Description

Sends a prompt to the OpenAI chat API along with an associated image URL, and optionally accepts parameters for the chat completion.

### Example Usage

```4d
var $helper := $client.chat.vision.create($imageURL)

$result := $helper.prompt($prompt; $parameters)
```