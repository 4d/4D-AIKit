# OpenAI

The `OpenAI` class provides a client for accessing various OpenAI API resources. It includes properties for managing API configurations and methods for performing HTTP requests to the OpenAI endpoints.

## Configuration Properties

| Property Name     | Type  | Description                       |
|-------------------|-------|-----------------------------------|
| `apiKey`          | Text  | Your OpenAI API Key.              |
| `baseURL`         | Text  | Base URL for OpenAI API requests. |
| `organization`    | Text  | Your OpenAI Organization ID.      |
| `project`         | Text  | Your OpenAI Project ID.           |
| `timeout`         | Real  | Time in seconds before timeout occurs. |

### Class constructor

Create an instance of the OpenAI class.

| Argument Name | Type     | Description                                           |
|---------------|----------|-------------------------------------------------------|
| `...`         | Text or Object  | apiKey if Text as first argument and the second can be an Object of parameters. |

#### API key

as text

```4d
var $client:=cs.AIKit.OpenAI.new("your api key")
```

as object

```4d
var $client:=cs.AIKit.OpenAI.new({apiKey: "your api key"})
```

#### Server URL

For a [compatible provider](../CompatibleOpenAI.md) API, you can configure the server URL.

```4d
var $client:=cs.AIKit.OpenAI.new({apiKey: "your api key"; baseURL: "https://server.ai"})
```

or after creating an instance

```4d
$client.baseURL:="https://server.ai"
```

## API resources

The API provides access to multiple resources that allow seamless interaction with OpenAI's services. Each resource is encapsulated within a dedicated API class, offering a structured and intuitive way to interact with different functionalities.

| Property Name     | Type                                           | Description                    |
|-------------------|------------------------------------------------|--------------------------------|
| `models`          | [OpenAIModelsAPI](OpenAIModelsAPI.md)             | Access to the Models API.      |
| `chat`            | [OpenAIChatAPI](OpenAIChatAPI.md)                 | Access to the Chat API.        |
| `images`          | [OpenAIImagesAPI](OpenAIImagesAPI.md)             | Access to the Images API.      |
| `moderations`     | [OpenAIModerationsAPI](OpenAIModerationsAPI.md)   | Access to the Moderations API. |


### Example Usage

```4d
$client.images.generate(...)
```