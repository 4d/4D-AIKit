# OpenAIParameters

The `OpenAIParameters` class is designed to handle execution and request parameters for interacting with the OpenAI API.

## Properties

### Properties of Asynchronous Programming

| Property           | Type    | Description                                                                                                           |
|-------------------|---------|-----------------------------------------------------------------------------------------------------------------------|
| `formula`         | Function| A function to be called asynchronously when finished. Ensure that the current process does not terminate.            |

See [documentation about asynchronous code](../AsynchronousCall.md)

### Network properties

| Property           | Type    | Description                                                                                                           |
|-------------------|---------|-----------------------------------------------------------------------------------------------------------------------|
| `timeout`         | Real    | Overrides the client-level default timeout for the request, in seconds. Default is 0.                                 |

### OpenAPI properties

| Property           | Type    | Description                                                                                                           |
|-------------------|---------|-----------------------------------------------------------------------------------------------------------------------|
| `user`            | Text    | A unique identifier representing the end-user, which helps OpenAI monitor and detect abuse.                           |

## Inherited Classes

Several classes inherit from `OpenAIParameters` to extend its functionality for specific use cases. Below are some of the classes that extend `OpenAIParameters`:

- [OpenAIChatCompletionsParameters](OpenAIChatCompletionsParameters.md)
- [OpenAIChatCompletionsMessagesParameters](OpenAIChatCompletionsMessagesParameters.md)
- [OpenAIImageParameters](OpenAIImageParameters.md)
- [OpenAIModerationParameters](OpenAIModerationParameters.md)
- [OpenAIEmbeddingsParameters](OpenAIEmbeddingsParameters.md)
