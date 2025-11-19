# OpenAIAssistantsParameters

The `OpenAIAssistantsParameters` class handles parameters for assistant create and modify operations.

## Inherits

[OpenAIParameters](OpenAIParameters.md)

## Properties

| Property Name     | Type       | Required | Description                          |
|------------------|------------|----------|--------------------------------------|
| `model`          | Text       | Required (for create) | ID of the model to use. You can use the List models API to see all available models, or see Model overview for descriptions of them. |
| `name`           | Text       | Optional | The name of the assistant. The maximum length is 256 characters. |
| `description`    | Text       | Optional | The description of the assistant. The maximum length is 512 characters. |
| `instructions`   | Text       | Optional | The system instructions that the assistant uses. The maximum length is 256,000 characters. |
| `tools`          | Collection | Optional | A list of tool enabled on the assistant. There can be a maximum of 128 tools per assistant. Tools can be of types `code_interpreter`, `file_search`, or `function`. |
| `toolResources`  | Object     | Optional | A set of resources that are used by the assistant's tools. The resources are specific to the type of tool. For example, the `code_interpreter` tool requires a list of file IDs, while the `file_search` tool requires a list of vector store IDs. |
| `metadata`       | Object     | Optional | Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maximum of 512 characters long. |
| `temperature`    | Real       | Optional | What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. |
| `topP`           | Real       | Optional | An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered. We generally recommend altering this or temperature but not both. |
| `responseFormat` | Object/Text | Optional | Specifies the format that the model must output. Compatible with GPT-4o, GPT-4 Turbo, and all GPT-3.5 Turbo models since gpt-3.5-turbo-1106. Setting to `{ "type": "json_schema", "json_schema": {...} }` enables Structured Outputs which ensures the model will match your supplied JSON schema. Setting to `{ "type": "json_object" }` enables JSON mode, which ensures the message the model generates is valid JSON. Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a system or user message. Without this, the model may generate an unending stream of whitespace until the generation reaches the token limit, resulting in a long-running and seemingly "stuck" request. Also note that the message content may be partially cut off if `finish_reason="length"`, which indicates the generation exceeded max_tokens or the conversation exceeded the max context length. |
| `reasoningEffort`| Text       | Optional | The reasoning effort to use for the assistant. Allowed values: `low`, `medium`, `high`. |

## Example Usage

```4d
var $params:=cs.AIKit.OpenAIAssistantsParameters.new()
$params.model:="gpt-4o"
$params.name:="Data visualizer"
$params.description:="An assistant that creates data visualizations"
$params.instructions:="You are great at creating beautiful data visualizations. You analyze data present in files and create visualizations."
$params.tools:=[]
$params.tools.push({type: "code_interpreter"})
$params.metadata:={project: "analytics"; version: "1.0"}
```

## See also

- [OpenAIAssistantsAPI](OpenAIAssistantsAPI.md)
- [OpenAIAssistantsResult](OpenAIAssistantsResult.md)
