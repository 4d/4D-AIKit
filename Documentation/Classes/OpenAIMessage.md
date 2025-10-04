# OpenAIMessage

The `OpenAIMessage` class represents a structured message containing a role, content, and an optional user. This class provides methods to manipulate and retrieve the text and other content of the message.

## Properties

| Property | Type    | Description                        |
|----------|---------|------------------------------------|
| `role`     | Text    | The role of the message (e.g., "user", "assistant"). |
| `content`  | Variant | The content of the message, which can be a text or a collection of objects. |
| `user`     | Text    | An optional property representing the user associated with the message. |

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
| *detail*         | Text | The detail level of the image: "auto", "low", or "high". |

Adds an image URL to the content of the message. If the content is currently text, it will be converted to a collection format.

### addFile()

**addFile**(*file* : [OpenAIFile](OpenAIFile.md))

| Parameter        | Type  | Description                                |
|------------------|-------|--------------------------------------------|
| *file*           | [OpenAIFile](OpenAIFile.md) | The file object to add to the message. Must have `purpose` set to `"user_data"`. |

**Throws:** An error if:
- The file parameter is `Null`
- The file is not an `OpenAIFile` instance
- The file's `purpose` is not `"user_data"`

Adds a file reference to the content of the message. Only files with the purpose `"user_data"` can be attached to messages. If the content is currently text, it will be converted to a collection format.

## Example Usage

### Basic Text Message

```4d
// Create an instance of OpenAIMessage
var $message:=cs.OpenAIMessage.new({role: "user"; content: "Hello!"})
```

### Adding Images

```4d
var $message:=cs.OpenAIMessage.new({role: "user"; content: "Please analyze this image:"})

// Add an image URL with details
$message.addImageURL("http://example.com/image.jpg"; "high")
```

### Adding Files

```4d
// Upload a file with user_data purpose
var $file:=File("/RESOURCES/document.pdf")
var $uploadResult:=$client.files.create($file; "user_data"; Null)

If ($uploadResult.success)
    var $uploadedFile:=$uploadResult.file
    
    // Create message and attach the file
    var $message:=cs.OpenAIMessage.new({role: "user"; content: "Please analyze this document:"})
    $message.addFile($uploadedFile)
    
    // $message.content -> [{type: "text"; text: "Please analyze this document:"}; {type: "file"; file_id: "file-abc123"}]
End if
```