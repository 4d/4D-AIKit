# GeminiFileResult

## Description

Result object for file operations (upload, retrieve). Contains detailed information about an uploaded file.

## Inherits

[GeminiResult](GeminiResult.md)

## Functions

### get file

**file** : cs.GeminiFile

| Property        | Type       | Description              |
|-----------------|------------|--------------------------|
| Function result | GeminiFile | The file information     |

Returns the file object with all properties.

## Examples

### Upload and Check Result

```4d
var $file:=File("/RESOURCES/document.pdf")
var $params:=cs.GeminiFileParameters.new()
$params.displayName:="My Document"

var $result:=$gemini.files.create($file; $params)

If ($result.success)
    var $fileData:=$result.file

    ALERT("Uploaded: "+$fileData.displayName)
    ALERT("URI: "+$fileData.uri)
    ALERT("Size: "+String($fileData.sizeBytes)+" bytes")
    ALERT("State: "+$fileData.state)
End if
```

### Wait for Processing

```4d
var $uploadResult:=$gemini.files.create($file; $params)

If ($uploadResult.success)
    var $fileId:=$uploadResult.file.name

    // Poll until file is ready
    var $state:=$uploadResult.file.state

    While ($state="PROCESSING")
        DELAY PROCESS(Current process; 60)  // Wait 1 second

        var $checkResult:=$gemini.files.retrieve($fileId)
        If ($checkResult.success)
            $state:=$checkResult.file.state
        Else
            break
        End if
    End while

    If ($state="ACTIVE")
        ALERT("File ready: "+$uploadResult.file.uri)
    Else if ($state="FAILED")
        ALERT("Processing failed: "+$uploadResult.file.error.message)
    End if
End if
```

### Check File Metadata

```4d
var $result:=$gemini.files.retrieve("files/abc123")

If ($result.success)
    var $file:=$result.file

    ALERT("Name: "+$file.displayName)
    ALERT("MIME type: "+$file.mimeType)
    ALERT("Size: "+String($file.sizeBytes))
    ALERT("Created: "+$file.createTime)
    ALERT("Updated: "+$file.updateTime)
    ALERT("Expires: "+$file.expirationTime)
    ALERT("Hash: "+$file.sha256Hash)
End if
```

### Use File in Content Generation

```4d
var $uploadResult:=$gemini.files.create($file; $params)

If ($uploadResult.success)
    // Check if file is ready
    If ($uploadResult.file.state="ACTIVE")
        var $fileUri:=$uploadResult.file.uri
        var $mimeType:=$uploadResult.file.mimeType

        // Use in prompt
        var $contents:=[{parts: [\
            {text: "Analyze this document"}; \
            {fileData: {fileUri: $fileUri; mimeType: $mimeType}}]}]

        var $contentResult:=$gemini.content.generate($contents; "gemini-2.0-flash-exp")

        If ($contentResult.success)
            ALERT($contentResult.candidates[0].text)
        End if
    End if
End if
```

### Handle Upload Errors

```4d
var $result:=$gemini.files.create($file; $params)

If (Not($result.success))
    For each ($error; $result.errors)
        ALERT("Upload error: "+$error.message)

        If ($error.isBadRequestError)
            ALERT("Invalid file format or parameters")
        Else if ($error.isRateLimitError)
            ALERT("Rate limit exceeded, try again later")
        Else if ($error.isAuthenticationError)
            ALERT("Check your API key")
        End if
    End for each
End if
```

### Check Video Metadata

```4d
var $videoFile:=File("/RESOURCES/video.mp4")
var $result:=$gemini.files.create($videoFile)

If ($result.success)
    var $file:=$result.file

    If ($file.videoMetadata#Null)
        ALERT("Duration: "+String($file.videoMetadata.videoDuration))
    End if
End if
```

### Delete After Use

```4d
var $uploadResult:=$gemini.files.create($file; $params)

If ($uploadResult.success)
    var $fileId:=$uploadResult.file.name

    // Use file...
    var $contentResult:=$gemini.content.generate($contents; "gemini-2.0-flash-exp")

    // Clean up
    var $deleteResult:=$gemini.files.delete($fileId)

    If ($deleteResult.success)
        ALERT("File deleted")
    End if
End if
```

### Check Expiration

```4d
var $result:=$gemini.files.retrieve("files/abc123")

If ($result.success)
    var $file:=$result.file

    // Parse expiration time
    var $expiresAt:=$file.expirationTime
    ALERT("File expires at: "+$expiresAt)

    // Calculate time remaining
    // (You would parse ISO 8601 timestamp and compare with current time)
End if
```

### Retry Failed Upload

```4d
var $result:=$gemini.files.create($file; $params)

If (Not($result.success))
    If ($result._shouldRetry())
        var $retryAfter:=$result._retryAfterValue()
        DELAY PROCESS(Current process; $retryAfter*60)

        // Retry
        $result:=$gemini.files.create($file; $params)
    End if
End if
```

## File States

The `file.state` property can be:
- `PROCESSING` - File is being processed
- `ACTIVE` - File is ready to use
- `FAILED` - Processing failed (check `file.error`)

## File Properties

- `name` - File ID (e.g., "files/abc123")
- `displayName` - Human-readable name
- `mimeType` - MIME type
- `sizeBytes` - File size
- `createTime` - Creation timestamp (ISO 8601)
- `updateTime` - Last update timestamp
- `expirationTime` - When file will be deleted
- `sha256Hash` - SHA-256 hash
- `uri` - URI for use in API calls
- `state` - Processing state
- `error` - Error details if failed
- `videoMetadata` - Video-specific metadata

## See Also

- [GeminiResult](GeminiResult.md) - Base result class
- [GeminiFile](GeminiFile.md) - File structure
- [GeminiFilesAPI](GeminiFilesAPI.md) - Files API
- [GeminiFileParameters](GeminiFileParameters.md) - Upload parameters
