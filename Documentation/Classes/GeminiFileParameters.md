# GeminiFileParameters

## Description

Parameters for file upload operations. Allows specification of display name, MIME type, and filename overrides.

## Inherits

[GeminiParameters](GeminiParameters.md)

## Properties

| Property    | Type | Description                               |
|-------------|------|-------------------------------------------|
| displayName | Text | Human-readable name for the file          |
| mimeType    | Text | MIME type of the file                     |
| filename    | Text | Override filename for the upload          |

## Constructor

```4d
$params:=cs.GeminiFileParameters.new()
$params:=cs.GeminiFileParameters.new($object)
```

## Examples

### Basic File Upload

```4d
var $file:=File("/RESOURCES/document.pdf")
var $params:=cs.GeminiFileParameters.new()
$params.displayName:="My Document"
$params.mimeType:="application/pdf"

var $result:=$gemini.files.create($file; $params)
```

### Image Upload

```4d
var $image:=File("/RESOURCES/photo.jpg")
var $params:=cs.GeminiFileParameters.new()
$params.displayName:="Vacation Photo"
$params.mimeType:="image/jpeg"

var $result:=$gemini.files.create($image; $params)
```

### Video Upload

```4d
var $video:=File("/RESOURCES/tutorial.mp4")
var $params:=cs.GeminiFileParameters.new()
$params.displayName:="Tutorial Video"
$params.mimeType:="video/mp4"

var $result:=$gemini.files.create($video; $params)
```

### Blob Upload with Filename

```4d
var $blob:=...  // Your blob data
var $params:=cs.GeminiFileParameters.new()
$params.displayName:="Generated Report"
$params.mimeType:="application/pdf"
$params.filename:="report.pdf"

var $result:=$gemini.files.create($blob; $params)
```

### Upload and Use in Prompt

```4d
// Upload file
var $file:=File("/RESOURCES/contract.pdf")
var $params:=cs.GeminiFileParameters.new()
$params.displayName:="Contract Document"
$params.mimeType:="application/pdf"

var $uploadResult:=$gemini.files.create($file; $params)

If ($uploadResult.success)
    // Wait for processing
    var $fileUri:=$uploadResult.file.uri

    // Use in content generation
    var $contents:=[{parts: [\
        {text: "Summarize this contract"}; \
        {fileData: {fileUri: $fileUri; mimeType: "application/pdf"}}]}]

    var $result:=$gemini.content.generate($contents; "gemini-2.0-flash-exp")

    If ($result.success)
        ALERT($result.candidates[0].text)
    End if
End if
```

### Multiple Files

```4d
var $files:=[File("/RESOURCES/doc1.pdf"); File("/RESOURCES/doc2.pdf")]
var $uploadedFiles:=[]

For each ($file; $files)
    var $params:=cs.GeminiFileParameters.new()
    $params.displayName:=$file.name
    $params.mimeType:="application/pdf"

    var $result:=$gemini.files.create($file; $params)
    If ($result.success)
        $uploadedFiles.push($result.file)
    End if
End for each
```

### With Async Callback

```4d
var $params:=cs.GeminiFileParameters.new()
$params.displayName:="Large Video"
$params.mimeType:="video/mp4"

// Add async callback
$params.onResponse:=Formula
    var $uploadResult:=$1.value
    ALERT("Upload complete: "+$uploadResult.file.uri)
End formula

var $result:=$gemini.files.create(File("/RESOURCES/large_video.mp4"); $params)
```

## Common MIME Types

### Images
- `image/jpeg` - JPEG images
- `image/png` - PNG images
- `image/gif` - GIF images
- `image/webp` - WebP images

### Documents
- `application/pdf` - PDF documents
- `text/plain` - Text files
- `text/csv` - CSV files

### Video
- `video/mp4` - MP4 videos
- `video/mpeg` - MPEG videos
- `video/mov` - MOV videos
- `video/avi` - AVI videos

### Audio
- `audio/wav` - WAV audio
- `audio/mp3` - MP3 audio
- `audio/mpeg` - MPEG audio

## Notes

- `displayName` is shown in the Gemini console and API responses
- `mimeType` should match the actual file type
- `filename` is useful when uploading Blobs without file metadata
- Some MIME types may have size or format restrictions
- Files are automatically deleted after a period (check Gemini documentation)

## See Also

- [GeminiParameters](GeminiParameters.md) - Base parameters class
- [GeminiFilesAPI](GeminiFilesAPI.md) - Files API
- [GeminiFileResult](GeminiFileResult.md) - Upload result
- [GeminiFile](GeminiFile.md) - File data structure
