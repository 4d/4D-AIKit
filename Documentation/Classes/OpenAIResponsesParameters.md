# OpenAIResponsesParameters

## Description

Parameters class for configuring OpenAI Responses API requests. Provides options for controlling model behavior, tools, streaming, and more.

## Inherits

[OpenAIParameters](OpenAIParameters.md)

## Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| model | Text | ID of the model to use | "gpt-4o" |
| stream | Boolean | Whether to stream back partial progress | False |
| stream_options | Object | Options for streaming (e.g., {include_usage: True}) | Null |
| instructions | Text | Instructions or system prompt for the model | "" |
| tools | Collection | Array of tools the model may call | Null |
| tool_choice | Variant | Controls which tool is called by the model | Null |
| reasoning | Object | Reasoning configuration with effort control (low, medium, high) | Null |
| background | Boolean | Whether to run the response in the background | False |
| previous_response_id | Text | ID of a previous response for stateful interactions | "" |
| max_tokens | Integer | Maximum number of tokens to generate | 0 |
| temperature | Real | Sampling temperature between 0 and 2 | -1 |
| store | Boolean | Whether to store the output of this response | False |
| response_format | Object | Format specification for the model output | Null |
| metadata | Object | Metadata to associate with the response | Null |
| onData | 4D.Function | Callback function for streaming data | Null |

## Functions

### body()

**body**() : Object

| Parameter       | Type        | Description                    |
|-----------------|-------------|--------------------------------|
| Function result | Object      | The request body as an object |

Constructs the request body from the parameter properties, excluding properties with default or null values.

## Examples

### Basic Usage

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.model:="gpt-4o"
$params.temperature:=0.7
```

### With Tools

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.model:="gpt-4o"
$params.tools:=[{type: "web_search"}]
```

### With Web Search Tool

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.model:="gpt-4o"
$params.tools:=[{type: "web_search"}]
$params.instructions:="Use web search to find current information"
```

### With File Search Tool

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.model:="gpt-4o"
$params.tools:=[{type: "file_search"; vector_store_ids: ["vs_abc123"]}]
```

### With Function Tool

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.model:="gpt-4o"
$params.tools:=[{\
    type: "function"; \
    function: {\
        name: "get_weather"; \
        description: "Get the current weather"; \
        parameters: {\
            type: "object"; \
            properties: {\
                location: {type: "string"; description: "The city name"}\
            }; \
            required: ["location"]\
        }\
    }\
}]
```

### Streaming

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.stream:=True
$params.stream_options:={include_usage: True}
$params.onData:=Formula($this.handleStreamData($1))
```

### Reasoning Control

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.model:="o3-mini"
$params.reasoning:={effort: "high"}
```

### Stateful Interactions

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.previous_response_id:="response_abc123"
```

### Response Format

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.response_format:={type: "json_object"}
```

### With Metadata

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.metadata:={user_id: "123"; session_id: "session_abc"}
$params.store:=True
```

### Background Execution

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.background:=True
```

### Creating from Object

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new({\
    model: "gpt-4o"; \
    temperature: 0.8; \
    max_tokens: 1000; \
    tools: [{type: "web_search"}]\
})
```

## See Also

- [OpenAIResponsesAPI](OpenAIResponsesAPI.md)
- [OpenAIResponsesResult](OpenAIResponsesResult.md)
- [OpenAIParameters](OpenAIParameters.md)
- [OpenAITool](OpenAITool.md)
