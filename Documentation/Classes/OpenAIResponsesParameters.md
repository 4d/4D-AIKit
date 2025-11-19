# OpenAIResponsesParameters

The `OpenAIResponsesParameters` class extends [OpenAIParameters](OpenAIParameters.md) and provides configuration options for OpenAI Responses API requests.

## Properties

### model
**Type**: Text

The ID of the model to use (optional). Examples: "gpt-4o", "o3", "gpt-4o-mini"

```4d
$params.model:="gpt-4o"
```

### instructions
**Type**: Text

System/developer message for providing context and instructions to the model.

```4d
$params.instructions:="You are a helpful assistant specializing in programming."
```

### conversation
**Type**: Variant (string or object)

Associates the response with a conversation. Can be a conversation ID string or a conversation object.

```4d
$params.conversation:="conv_abc123"
```

### previous_response_id
**Type**: Text

ID of a previous response to enable multi-turn conversations. The model will have access to the context from the previous response.

```4d
$params.previous_response_id:="resp_xyz789"
```

### text
**Type**: Object

Output configuration for plain text or structured JSON data.

```4d
$params.text:={type: "json_schema"; json_schema: {...}}
```

### stream
**Type**: Boolean (default: False)

Whether to stream back partial progress via server-sent events. When enabled, requires `onData` callback function.

```4d
$params.stream:=True
$params.onData:=Formula(TRACE($1.value.text))
```

### stream_options
**Type**: Object

Options for streaming mode. Example: `{include_usage: True}`

```4d
$params.stream_options:={include_usage: True}
```

### max_output_tokens
**Type**: Integer (default: 0)

Upper bound for the number of tokens that can be generated.

```4d
$params.max_output_tokens:=1000
```

### tools
**Type**: Collection

A list of tools the model may call. Can be built-in tools, MCP tools, or custom functions.

```4d
$params.tools:=[{type: "function"; function: {name: "get_weather"; parameters: {...}}}]
```

### tool_choice
**Type**: Variant

Controls which (if any) tool is called by the model. Can be "none", "auto", "required", or a specific tool.

```4d
$params.tool_choice:="auto"
```

### max_tool_calls
**Type**: Integer (default: 0)

Maximum total number of tool calls allowed per response.

```4d
$params.max_tool_calls:=5
```

### parallel_tool_calls
**Type**: Boolean (default: True)

Enable parallel execution of tool calls.

```4d
$params.parallel_tool_calls:=True
```

### temperature
**Type**: Real (default: -1)

What sampling temperature to use, between 0 and 2. Higher values (e.g., 0.8) make output more random, while lower values (e.g., 0.2) make it more focused and deterministic.

```4d
$params.temperature:=0.7
```

### top_p
**Type**: Real (default: -1)

Nucleus sampling parameter. Alternative to temperature sampling.

```4d
$params.top_p:=0.9
```

### top_logprobs
**Type**: Integer (default: 0)

Number of most likely tokens to return at each token position, along with their log probabilities.

```4d
$params.top_logprobs:=5
```

### reasoning
**Type**: Object

Configuration for o-series models' reasoning capabilities.

```4d
$params.reasoning:={effort: "high"}
```

### metadata
**Type**: Object

Key-value pairs for metadata. Maximum 16 pairs, with keys up to 64 characters and values up to 512 characters.

```4d
$params.metadata:={user_id: "user123"; session: "session456"}
```

### background
**Type**: Boolean (default: False)

Enable background processing mode for long-running responses.

```4d
$params.background:=True
```

### store
**Type**: Boolean (default: True)

Enable response storage for later retrieval and updates.

```4d
$params.store:=True
```

### truncation
**Type**: Text

Context overflow handling strategy. Can be "auto" or "disabled".

```4d
$params.truncation:="auto"
```

### onData
**Type**: 4D.Function

Function to call asynchronously when receiving streaming data. Only used when `stream` is True.

```4d
$params.onData:=Formula(TRACE($1.value.text))
```

## Example Usage

Basic usage:

```4d
var $params:=cs.OpenAIResponsesParameters.new()
$params.model:="gpt-4o"
$params.instructions:="You are a helpful assistant."
$params.temperature:=0.7
$params.max_output_tokens:=500
```

With streaming:

```4d
var $params:=cs.OpenAIResponsesParameters.new({
    model: "gpt-4o";
    stream: True;
    onData: Formula(TRACE($1.value.text))
})
```

With tools:

```4d
var $params:=cs.OpenAIResponsesParameters.new()
$params.model:="gpt-4o"
$params.tools:=[
    {type: "function"; function: {
        name: "get_weather";
        description: "Get the weather for a location";
        parameters: {
            type: "object";
            properties: {location: {type: "string"}};
            required: ["location"]
        }
    }}
]
$params.tool_choice:="auto"
```

Multi-turn conversation:

```4d
var $params:=cs.OpenAIResponsesParameters.new()
$params.model:="gpt-4o"
$params.conversation:="my-conversation"
$params.previous_response_id:="resp_abc123"
```
