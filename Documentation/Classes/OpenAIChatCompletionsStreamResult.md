# OpenAIChatCompletionsStreamResult

## Properties

| Property  | Type                         | Description                                      |
|-----------|------------------------------|--------------------------------------------------|
| request   | HTTPRequest                  | The initial request object.                      |
| data      | Object                       | Contains the stream data sent by the server.    |

## Functions

### success

**Description**: Return True if we successfully decoded the streaming data as an object.

**Returns**: Boolean

---

### errors

**Description**: Return errors if any are found during the request.

**Returns**: Collection

---

### choice

**Description**: Return a choice data, with a delta message.

**Returns**: OpenAIChoice or Null

---

### choices

**Description**: Return choices data, with delta messages.

**Returns**: Collection
