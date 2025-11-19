# OpenAIAssistant

The `OpenAIAssistant` class represents an assistant object in the OpenAI API. Assistants can call models with specific instructions, use tools, and access knowledge to perform tasks.

## Properties

| Property Name     | Type     | Description                                                      |
|-------------------|----------|------------------------------------------------------------------|
| `id`              | Text     | The identifier, which can be referenced in API endpoints.       |
| `object`          | Text     | The object type, which is always "assistant".                   |
| `createdAt`       | Integer  | The Unix timestamp (in seconds) for when the assistant was created. |
| `name`            | Text     | The name of the assistant. The maximum length is 256 characters. |
| `description`     | Text     | The description of the assistant. The maximum length is 512 characters. |
| `model`           | Text     | ID of the model to use.                                         |
| `instructions`    | Text     | The system instructions that the assistant uses. The maximum length is 256,000 characters. |
| `tools`           | Collection | A list of tool enabled on the assistant. Tools can be of types `code_interpreter`, `file_search`, or `function`. |
| `toolResources`   | Object   | A set of resources that are used by the assistant's tools. The resources are specific to the type of tool. |
| `metadata`        | Object   | Set of 16 key-value pairs that can be attached to an object.    |
| `temperature`     | Real     | What sampling temperature to use, between 0 and 2.              |
| `topP`            | Real     | An alternative to sampling with temperature, called nucleus sampling. |
| `responseFormat`  | Object   | Specifies the format that the model must output.               |
| `reasoningEffort` | Text     | The reasoning effort to use for the assistant.                  |

## See also

- [OpenAIAssistantsResult](OpenAIAssistantsResult.md)
- [OpenAIAssistantListResult](OpenAIAssistantListResult.md)
- [OpenAIAssistantsAPI](OpenAIAssistantsAPI.md)
- [OpenAIAssistantsParameters](OpenAIAssistantsParameters.md)
