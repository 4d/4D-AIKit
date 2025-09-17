# OpenAIChatCompletionsParameters

The `OpenAIChatCompletionsParameters` class is designed to handle the parameters required for chat completions using the OpenAI API.

## Inherits

- [OpenAIParameters](OpenAIParameters.md)

## Properties

| Property                | Type       | Default Value   | Description                                                                                                                                              |
| ----------------------- | ---------- | --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `model`                 | Text       | `"gpt-4o-mini"` | ID of the model to use.                                                                                                                                  |
| `stream`                | Boolean    | `False`         | Whether to stream back partial progress. If set, tokens will be sent as data-only. Callback formula required.                                            |
| `stream_options`        | Object     | `Null`          | Property for stream=True. For example: `{include_usage: True}`                                                                                           |
| `max_completion_tokens` | Integer    | `0`             | The maximum number of tokens that can be generated in the completion.                                                                                    |
| `n`                     | Integer    | `1`             | How many completions to generate for each prompt.                                                                                                        |
| `temperature`           | Real       | `-1`            | What sampling temperature to use, between 0 and 2. Higher values make the output more random, while lower values make it more focused and deterministic. |
| `store`                 | Boolean    | `False`         | Whether or not to store the output of this chat completion request.                                                                                      |
| `reasoning_effort`      | Text       | `Null`          | Constrains effort on reasoning for reasoning models. Currently supported values are `"low"`, `"medium"`, and `"high"`.                                   |
| `response_format`       | Object     | `Null`          | An object specifying the format that the model must output. Compatible with structured outputs.                                                          |
| `tools`                 | Collection | `Null`          | A list of tools the model may call. Currently, only functions are supported as tools.                                                                    |
| `tool_choice`           | Variant    | `Null`          | Controls which (if any) tool is called by the model. Can be `"none"`, `"auto"`, `"required"`, or specify a particular tool.                              |
| `prediction`            | Object     | `Null`          | Static predicted output content, such as the content of a text file that is being regenerated.                                                           |

### Asynchronous Callback Properties

| Property                   | Type    | Description                                                                                       |
|---------------------------|---------|-------------------------|---------------------------------------------------------------------------------------------------|
| `onData`<br>(or `formula`)   | 4D.Function | A function to be called asynchronously when receiving data chunk.<br>*Ensure that the current process does not terminate.* |

`onData` will receive as argument a [OpenAIChatCompletionsStreamResult](OpenAIChatCompletionsStreamResult.md)

See [OpenAIParameters](OpenAIParameters.md) for other callback properties.


### tools

The `tools` property allows you to define functions that the model can call during the conversation.

#### Tool Structure:

```json
[
  {
    "type": "function",
    "function": {
      "name": "function_name",
      "description": "A description of what the function does. This helps the LLM identify which tool to use.",
      "parameters": {
        "type": "object",
        "properties": {
          "param1": {
            "type": "string",
            "description": "Parameter description"
          }
        },
        "required": ["param1"]
      }
    },
    "strict": true
  }
]
```

#### Example:

```4d
$tool:={\
  "type": "function"; \
  "function": {\
    "name": "get_database_table"; \
    "description": "Get the database table list."; \
    "parameters": {}; \
    "required": []; \
    "additionalProperties": False\
  }; \
  "strict": True\
}

$parameters.tools:=[$tool] 
```

See [OpenAIMessage](OpenAIMessage.md) to see how to responds to a tool call.

## See also

- [OpenAIChatCompletionsAPI](OpenAIChatCompletionsAPI.md)
- [OpenAIMessage](OpenAIMessage.md)
