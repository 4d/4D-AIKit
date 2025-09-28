# OpenAIMessage

The `OpenAIMessage` class represents a structured message containing a role, content, and an optional user. This class provides methods to manipulate and retrieve the text and other content of the message.

## Properties

| Property | Type    | Description                        |
|----------|---------|------------------------------------|
| `role`     | Text    | The role of the message (e.g., "user", "assistant", "system", "tool"). |
| `content`  | Variant | The content of the message, which can be a text or a collection of objects. |
| `user`     | Text    | An optional property representing the user associated with the message. |
| `tool_calls` | Collection | A collection of tool calls requested by the assistant. Each tool call contains an `id`, `type`, and a `function` object. |
| `tool_call_id` | Text | The ID of the tool call that this message is responding to (used when `role` is "tool"). |

## Computed properties

| Property | Type    | Description                        |
|----------|---------|------------------------------------|
| `text`     | Text    | A property representing the text message. |

## Functions

### addImageURL()

**addImageURL**(*imageURL* : Text; *detail* : Text)

| Parameter        | Type  | Description                                |
|------------------|-------|--------------------------------------------|
| *imageURL*       | Text | The URL of the image to add to the message.|
| *detail*         | Text | Additional details about the image.        |

Adds an image URL to the content of the message.

## Example Usage

### Create a simple message and attach an image

```4d
// Create an instance of OpenAIMessage
var $message:=cs.AIKit.OpenAIMessage({role: "user"; content: "Hello!"})

// Add an image URL with details
$message.addImageURL("http://example.com/image.jpg"; "high")
```

### Respond to a tool call message

The tool call from server:

```json
{
  "role": "assistant",
  "tool_calls": [
    {
      "id": "call_12345",
      "type": "function",
      "function": {
        "name": "get_database_table",
        "arguments": "{}"
      }
    }
  ]
}
```

Tool response message:

```4d
var $tableNames: Text := OB Keys(ds).join(", ")
var $toolResponse:=cs.AIKit.OpenAIMessage.new({\
  role: "tool"; \
  tool_call_id: "call_12345"; \
  content: $tableNames \
})
// add it to the conversation and push
```
