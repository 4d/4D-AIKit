# GeminiFile

## Description

Represents metadata about an uploaded file in the Gemini File API. Contains file information, processing state, and URI for use in prompts.

## Properties

| Property         | Type    | Description                          |
|------------------|---------|--------------------------------------|
| name             | Text    | File ID (e.g., "files/abc123")       |
| displayName      | Text    | Human-readable name                  |
| mimeType         | Text    | MIME type                            |
| sizeBytes        | Integer | File size in bytes                   |
| createTime       | Text    | Creation timestamp (ISO 8601)        |
| updateTime       | Text    | Update timestamp                     |
| expirationTime   | Text    | Expiration timestamp                 |
| sha256Hash       | Text    | SHA-256 hash                         |
| uri              | Text    | URI for API calls                    |
| state            | Text    | Processing state                     |
| error            | Object  | Error details if failed              |
| videoMetadata    | Object  | Video metadata (if applicable)       |

## Constructor

```4d
$file:=cs.GeminiFile.new($data)
```

## Examples

### Access File Properties

```4d
var $result:=$gemini.files.retrieve("files/abc123")

If ($result.success)
    var $file:=$result.file

    ALERT("Name: "+$file.displayName)
    ALERT("Type: "+$file.mimeType)
    ALERT("Size: "+String($file.sizeBytes)+" bytes")
    ALERT("State: "+$file.state)
    ALERT("URI: "+$file.uri)
End if
```

### Check Processing State

```4d
var $uploadResult:=$gemini.files.create($file; $params)

If ($uploadResult.success)
    var $fileData:=$uploadResult.file

    Case of
        : ($fileData.state="PROCESSING")
            ALERT("File is being processed...")
        : ($fileData.state="ACTIVE")
            ALERT("File is ready to use")
        : ($fileData.state="FAILED")
            ALERT("Processing failed: "+$fileData.error.message)
    End case
End if
```

### Wait for Processing

```4d
var $uploadResult:=$gemini.files.create($file; $params)

If ($uploadResult.success)
    var $fileId:=$uploadResult.file.name
    var $state:=$uploadResult.file.state

    // Poll until ready
    While ($state="PROCESSING")
        DELAY PROCESS(Current process; 60)

        var $checkResult:=$gemini.files.retrieve($fileId)
        If ($checkResult.success)
            $state:=$checkResult.file.state
        Else
            break
        End if
    End while

    If ($state="ACTIVE")
        var $fileUri:=$uploadResult.file.uri
        ALERT("File ready: "+$fileUri)
    End if
End if
```

### Use File in Prompt

```4d
var $uploadResult:=$gemini.files.create($file; $params)

If ($uploadResult.success && ($uploadResult.file.state="ACTIVE"))
    var $fileData:=$uploadResult.file

    // Create content with file
    var $contents:=[{parts: [\
        {text: "Summarize this document"}; \
        {fileData: {fileUri: $fileData.uri; mimeType: $fileData.mimeType}}]}]

    var $result:=$gemini.content.generate($contents; "gemini-2.0-flash-exp")
End if
```

### Check Timestamps

```4d
var $result:=$gemini.files.retrieve("files/abc123")

If ($result.success)
    var $file:=$result.file

    ALERT("Created: "+$file.createTime)
    ALERT("Updated: "+$file.updateTime)
    ALERT("Expires: "+$file.expirationTime)

    // Calculate age (simplified)
    // In real code, parse ISO 8601 timestamps
End if
```

### Check Video Metadata

```4d
var $uploadResult:=$gemini.files.create($videoFile; $params)

If ($uploadResult.success)
    var $file:=$uploadResult.file

    If ($file.videoMetadata#Null)
        ALERT("Video duration: "+String($file.videoMetadata.videoDuration)+" seconds")
    End if
End if
```

### Verify File Hash

```4d
var $uploadResult:=$gemini.files.create($file; $params)

If ($uploadResult.success)
    var $fileData:=$uploadResult.file

    ALERT("SHA-256: "+$fileData.sha256Hash)

    // Could verify against local hash
End if
```

### List File Details

```4d
var $result:=$gemini.files.list()

If ($result.success)
    For each ($file; $result.files)
        var $sizeMB:=$file.sizeBytes / (1024 * 1024)

        ALERT($file.displayName)
        ALERT("  Type: "+$file.mimeType)
        ALERT("  Size: "+String($sizeMB; "##0.00")+" MB")
        ALERT("  State: "+$file.state)
        ALERT("  ID: "+$file.name)
    End for each
End if
```

### Handle Failed Upload

```4d
var $uploadResult:=$gemini.files.create($file; $params)

If ($uploadResult.success)
    var $fileData:=$uploadResult.file

    If ($fileData.state="FAILED")
        If ($fileData.error#Null)
            ALERT("Upload failed:")
            ALERT("Code: "+String($fileData.error.code))
            ALERT("Message: "+$fileData.error.message)
        End if
    End if
End if
```

### Delete After Expiration Check

```4d
var $result:=$gemini.files.retrieve("files/abc123")

If ($result.success)
    var $file:=$result.file

    // Parse expiration time
    var $expiresAt:=$file.expirationTime

    // If expired or about to expire, delete
    // (Simplified - use proper date parsing)
    var $deleteResult:=$gemini.files.delete($file.name)
End if
```

## File States

| State      | Description                              |
|------------|------------------------------------------|
| PROCESSING | File is being processed                  |
| ACTIVE     | File is ready to use                     |
| FAILED     | Processing failed (check error property) |

## MIME Types

Common MIME types:
- `image/jpeg`, `image/png` - Images
- `video/mp4`, `video/mov` - Videos
- `application/pdf` - PDF documents
- `audio/wav`, `audio/mp3` - Audio files

## Time Format

Timestamps are in ISO 8601 format:
```
2024-01-15T10:30:00.123456Z
```

## Error Structure

If `state` is `FAILED`, the `error` property contains:

```json
{
    "code": 400,
    "message": "Error description"
}
```

## See Also

- [GeminiFileResult](GeminiFileResult.md) - File result
- [GeminiFileListResult](GeminiFileListResult.md) - File list result
- [GeminiFilesAPI](GeminiFilesAPI.md) - Files API
- [GeminiFileParameters](GeminiFileParameters.md) - Upload parameters
