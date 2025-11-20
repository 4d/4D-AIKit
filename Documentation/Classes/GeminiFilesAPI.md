# GeminiFilesAPI

## Description

API for managing files in the Gemini File API. Upload and reference files for use in multimodal prompts, document processing, and other AI tasks.

## Access

```4d
var $gemini:=cs.Gemini.new($apiKey)
var $filesAPI:=$gemini.files
```

## Functions

### create()

**create**(*file* : Variant ; *parameters* : GeminiFileParameters) : GeminiFileResult

| Parameter       | Type                  | Description                          |
|-----------------|-----------------------|--------------------------------------|
| *file*          | 4D.File or Blob       | The file to upload                   |
| *parameters*    | GeminiFileParameters  | Optional upload parameters           |
| Function result | GeminiFileResult      | Upload result with file information  |

Uploads a file to the Gemini File API.

#### Example Usage

```4d
var $gemini:=cs.Gemini.new($apiKey)

var $file:=File("/RESOURCES/document.pdf")
var $params:=cs.GeminiFileParameters.new()
$params.displayName:="My Document"
$params.mimeType:="application/pdf"

var $result:=$gemini.files.create($file; $params)

If ($result.success)
    var $fileData:=$result.file
    ALERT("Uploaded: "+$fileData.uri)
End if
```

### retrieve()

**retrieve**(*fileId* : Text ; *parameters* : GeminiParameters) : GeminiFileResult

| Parameter       | Type              | Description                       |
|-----------------|-------------------|-----------------------------------|
| *fileId*        | Text              | File ID (e.g., "files/abc123")    |
| *parameters*    | GeminiParameters  | Optional request parameters       |
| Function result | GeminiFileResult  | File information                  |

Retrieves information about an uploaded file.

#### Example Usage

```4d
var $result:=$gemini.files.retrieve("files/abc123")

If ($result.success)
    var $file:=$result.file
    ALERT("File: "+$file.displayName)
    ALERT("Size: "+String($file.sizeBytes))
End if
```

### list()

**list**(*parameters* : GeminiFileListParameters) : GeminiFileListResult

| Parameter       | Type                      | Description              |
|-----------------|---------------------------|--------------------------|
| *parameters*    | GeminiFileListParameters  | Optional list parameters |
| Function result | GeminiFileListResult      | List of files            |

Lists uploaded files.

#### Example Usage

```4d
var $result:=$gemini.files.list()

If ($result.success)
    For each ($file; $result.files)
        ALERT($file.displayName)
    End for each
End if
```

### delete()

**delete**(*fileId* : Text ; *parameters* : GeminiParameters) : GeminiResult

| Parameter       | Type             | Description                    |
|-----------------|------------------|--------------------------------|
| *fileId*        | Text             | File ID to delete              |
| *parameters*    | GeminiParameters | Optional request parameters    |
| Function result | GeminiResult     | Deletion result                |

Deletes an uploaded file.

#### Example Usage

```4d
var $result:=$gemini.files.delete("files/abc123")

If ($result.success)
    ALERT("File deleted")
End if
```

## Examples

### Upload and Use File in Prompt

```4d
var $gemini:=cs.Gemini.new($apiKey)

// Upload document
var $file:=File("/RESOURCES/report.pdf")
var $uploadResult:=$gemini.files.create($file)

If ($uploadResult.success)
    var $fileUri:=$uploadResult.file.uri

    // Wait for file to be processed (check state)
    // Then use in content generation
    var $contents:=[{parts: [\
        {text: "Summarize this document"}; \
        {fileData: {fileUri: $fileUri; mimeType: "application/pdf"}}]}]

    var $result:=$gemini.content.generate($contents; "gemini-2.0-flash-exp")

    If ($result.success)
        ALERT($result.candidates[0].text)
    End if

    // Clean up
    $gemini.files.delete($uploadResult.file.name)
End if
```

### Upload Image for Vision

```4d
var $imageFile:=File("/RESOURCES/photo.jpg")
var $params:=cs.GeminiFileParameters.new()
$params.displayName:="Photo Analysis"
$params.mimeType:="image/jpeg"

var $uploadResult:=$gemini.files.create($imageFile; $params)

If ($uploadResult.success)
    var $fileUri:=$uploadResult.file.uri

    var $contents:=[{parts: [\
        {text: "What's in this image?"}; \
        {fileData: {fileUri: $fileUri; mimeType: "image/jpeg"}}]}]

    var $result:=$gemini.content.generate($contents; "gemini-2.0-flash-exp")

    If ($result.success)
        ALERT($result.candidates[0].text)
    End if
End if
```

### List and Filter Files

```4d
var $params:=cs.GeminiFileListParameters.new()
$params.pageSize:=10

var $result:=$gemini.files.list($params)

If ($result.success)
    // Filter PDF files
    var $pdfFiles:=$result.files.query("mimeType == :1"; "application/pdf")

    For each ($file; $pdfFiles)
        ALERT($file.displayName+" - "+String($file.sizeBytes)+" bytes")
    End for each

    // Check for more results
    If (Length($result.nextPageToken)>0)
        $params.pageToken:=$result.nextPageToken
        var $nextResult:=$gemini.files.list($params)
    End if
End if
```

### Check File Processing State

```4d
var $uploadResult:=$gemini.files.create($file)

If ($uploadResult.success)
    var $fileId:=$uploadResult.file.name
    var $state:=""

    // Poll until file is processed
    Repeat
        var $fileResult:=$gemini.files.retrieve($fileId)
        $state:=$fileResult.file.state

        If ($state="PROCESSING")
            DELAY PROCESS(Current process; 60)  // Wait 1 second
        End if
    Until (($state="ACTIVE") || ($state="FAILED"))

    If ($state="ACTIVE")
        ALERT("File ready to use")
    Else
        ALERT("File processing failed")
    End if
End if
```

## File Properties

Each file object contains:

| Property         | Type    | Description                              |
|------------------|---------|------------------------------------------|
| name             | Text    | File ID (e.g., "files/abc123")           |
| displayName      | Text    | Display name                             |
| mimeType         | Text    | MIME type                                |
| sizeBytes        | Integer | File size in bytes                       |
| createTime       | Text    | Creation timestamp (ISO 8601)            |
| updateTime       | Text    | Update timestamp                         |
| expirationTime   | Text    | Expiration timestamp                     |
| sha256Hash       | Text    | SHA-256 hash                             |
| uri              | Text    | File URI for use in API calls            |
| state            | Text    | Processing state (PROCESSING, ACTIVE, FAILED) |
| error            | Object  | Error details if state is FAILED         |
| videoMetadata    | Object  | Video metadata (if applicable)           |

## File States

- `PROCESSING` - File is being processed
- `ACTIVE` - File is ready to use
- `FAILED` - File processing failed

## Supported File Types

- Images: JPEG, PNG, WEBP, GIF
- Documents: PDF
- Videos: MP4, MOV, AVI, etc.
- Audio: WAV, MP3, etc.

Check Gemini documentation for complete list and size limits.

## Error Handling

```4d
var $result:=$gemini.files.create($file)

If (Not($result.success))
    For each ($error; $result.errors)
        ALERT("Upload failed: "+$error.message)
    End for each
End if
```

## See Also

- [Gemini](Gemini.md) - Main client class
- [GeminiFileParameters](GeminiFileParameters.md) - Upload parameters
- [GeminiFileResult](GeminiFileResult.md) - File result
- [GeminiFile](GeminiFile.md) - File data structure
