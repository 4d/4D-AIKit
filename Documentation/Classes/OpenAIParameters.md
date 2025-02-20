# OpenAIParameters

The `OpenAIParameters` class is designed to handle execution and request parameters for interacting with the OpenAI API.

## Properties

### Properties of Asynchronous Programming

| Property           | Type    | Description                                                                                                           |
|-------------------|---------|-----------------------------------------------------------------------------------------------------------------------|
| `formula`         | Function| A function to be called asynchronously when finished. Ensure that the current process does not terminate.            |

### Network properties

| Property           | Type    | Description                                                                                                           |
|-------------------|---------|-----------------------------------------------------------------------------------------------------------------------|
| `timeout`         | Real    | Overrides the client-level default timeout for the request, in seconds. Default is 0.                                 |

### OpenAPI properties

| Property           | Type    | Description                                                                                                           |
|-------------------|---------|-----------------------------------------------------------------------------------------------------------------------|
| `user`            | Text    | A unique identifier representing the end-user, which helps OpenAI monitor and detect abuse.                           |
