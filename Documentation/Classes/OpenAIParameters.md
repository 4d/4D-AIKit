# OpenAIParameters

The `OpenAIParameters` class is designed to handle execution and request parameters for interacting with the OpenAI API.

## Properties

| Property           | Type    | Description                                                                                                           |
|-------------------|---------|-----------------------------------------------------------------------------------------------------------------------|
| `formula`         | Function| A function to be called asynchronously when finished. Ensure that the current process does not terminate.            |
| `worker`          | Variant | An optional worker/process to use to execute the HTTP request if a "formula" is defined. No result object is returned. |
| `formulaWorker`   | Variant | An optional worker/process to execute the "formula" after the HTTP request is executed. Ensure the process remains.   |
| `formulaWindow`   | Integer | An optional window reference to execute the "formula" after the HTTP request.                                        |
| `timeout`         | Real    | Overrides the client-level default timeout for the request, in seconds. Default is 0.                                 |
| `user`            | Text    | A unique identifier representing the end-user, which helps OpenAI monitor and detect abuse.                           |

