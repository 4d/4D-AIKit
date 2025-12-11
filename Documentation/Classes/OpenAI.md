# OpenAI

The `OpenAI` class provides a client for accessing various OpenAI API resources. It includes properties for managing API configurations and methods for performing HTTP requests to the OpenAI endpoints.

## Configuration Properties

| Property Name     | Type  | Description                       | Optional |
|-------------------|-------|-----------------------------------|----------|
| `apiKey`          | Text  | Your [OpenAI API Key](https://platform.openai.com/api-keys).              | Can be required by the provider |
| `baseURL`         | Text  | Base URL for OpenAI API requests. | Yes (if omitted = use OpenAI Platform) |
| `organization`    | Text  | Your OpenAI Organization ID.      | Yes      |
| `project`         | Text  | Your OpenAI Project ID.           | Yes      |

### Additional HTTP properties

| Property Name     | Type  | Description                       |
|-------------------|-------|-----------------------------------|
| `timeout`         | Real  | Time in seconds before timeout occurs. | 
| `maxRetries`      | Real  | Maximum number of retry attempts in case of failure. | 
| `httpAgent`      | [4D.HTTPAgent](https://developer.4d.com/docs/API/HTTPAgentClass)  | HTTP agent used for making requests. | 
| `customHeaders`      | Real  | Custom headers to be included in the HTTP requests. | 

### Class constructor

Create an instance of the OpenAI client class.

| Argument Name | Type      | Description                                               |
|---------------|-----------|-----------------------------------------------------------|
| `apiKey or configuration` | Text or Object  | apiKey if Text or configuration Object. |

#### API key

```4d
// as text
var $client:=cs.AIKit.OpenAI.new("your api key")
// as object
var $client:=cs.AIKit.OpenAI.new({apiKey: "your api key"})
```

#### Server URL

For a [compatible provider](../compatible-openai.md) API, you can configure the server URL.

```4d
var $client:=cs.AIKit.OpenAI.new({apiKey: "your api key"; baseURL: "https://server.ai"})
```

or after creating an instance

```4d
$client.baseURL:="https://server.ai"
```

## API resources

The API provides access to multiple resources that allow seamless interaction with OpenAI's services. Each resource is encapsulated within a dedicated API class, offering a structured and intuitive way to interact with different functionalities.

| Property Name     | Type                                            | Description                    |
|-------------------|-------------------------------------------------|--------------------------------|
| `models`          | [OpenAIModelsAPI](OpenAIModelsAPI.md)           | Access to the Models API.      |
| `chat`            | [OpenAIChatAPI](OpenAIChatAPI.md)               | Access to the Chat API.        |
| `images`          | [OpenAIImagesAPI](OpenAIImagesAPI.md)           | Access to the Images API.      |
| `moderations`     | [OpenAIModerationsAPI](OpenAIModerationsAPI.md) | Access to the Moderations API. |
| `embeddings`      | [OpenAIEmbeddingsAPI](OpenAIEmbeddingsAPI.md)   | Access to the Embeddings API.  |
| `files`           | [OpenAIFilesAPI](OpenAIFilesAPI.md)             | Access to the Files API.       |

### Example Usage

```4d
$client.chat.completions.create(...)
$client.images.generate(...)
$client.files.create(...)
$client.model.lists(...)
```

## Model Aliases

The OpenAI client supports model aliases, allowing you to define provider configurations in a centralized file and reference them using a simple `provider:model` syntax.

### Configuration

Create a `Resources/ai-providers.json` file (see `Resources/ai-providers.template.json` for an example).

### Usage with Model Aliases

```4d
var $client := cs.AIKit.OpenAI.new()

// Use OpenAI
var $result := $client.chat.completions.create($messages; {model: "openai:gpt-4o"})

// Use Anthropic
var $result := $client.chat.completions.create($messages; {model: "anthropic:claude-3-opus"})

// Use local Ollama
var $result := $client.chat.completions.create($messages; {model: "local:llama3"})

// Use custom alias
var $result := $client.chat.completions.create($messages; {model: "4d:mychatmodel"})
```

### Model Alias Methods

| Method | Description |
|--------|-------------|
| `setProvidersFile($path : Text)` | Set a custom path for the providers configuration file |
| `resolveModel($modelString : Text) : Object` | Resolve a model string to its configuration (baseURL, apiKey, model) |

For more details, see [Model Aliases](../model-aliases.md).

