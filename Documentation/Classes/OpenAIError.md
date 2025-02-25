# OpenAIError Class

The `OpenAIError` class is designed to handle errors returned by the OpenAI API. It extracts relevant information from the error response and provides methods to access this information.

## Properties

| Property  | Type     | Description                                         |
|-----------|----------|-----------------------------------------------------|
| `errCode` | Integer  | The error code returned by the API or the HTTP status. |
| `message` | Text     | The error message returned by the API or the HTTP status text. |
| `body`    | Object   | The body of the error response.                     |
| `response`| Object   | The full response object.                           |
