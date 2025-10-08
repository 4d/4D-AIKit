# OpenAIUploadsAPI

API Reference: <https://platform.openai.com/docs/api-reference/uploads>

## Description
API resource for managing large file uploads in OpenAI. The Uploads API allows you to upload files in multiple parts, supporting files up to 8 GB in size. This is particularly useful for handling large training datasets, batch files, or other large file uploads.

## Inherits

[OpenAIAPIResource](OpenAIAPIResource.md)

## Overview
The Uploads API workflow consists of three main steps:
1. **Create** an Upload object with metadata about the file
2. **Add Parts** to the Upload (chunks of up to 64 MB each)
3. **Complete** or **Cancel** the Upload

Once completed, the Upload creates a usable File object that can be used across the OpenAI platform.

## Key Features
- Upload files up to 8 GB in total size
- Each part can be up to 64 MB
- Supports parallel part uploads
- Custom ordering of parts when completing
- Automatic expiration after 1 hour if not completed
- Optional MD5 checksum verification

 
## Methods

### create

Creates an intermediate Upload object that you can add Parts to.

**create**(*filename* : Text ; *bytes* : Integer ; *purpose* : Text ; *mimeType* : Text ; *parameters* : [OpenAIUploadParameters](OpenAIUploadParameters.md)) : [OpenAIUploadResult](OpenAIUploadResult.md)

| Parameter       | Type                                      | Description                               |
|-----------------|-------------------------------------------|-------------------------------------------|
| *filename*      | Text                                      | **Required.** The name of the file to upload |
| *bytes*         | Integer                                   | **Required.** The number of bytes in the file you are uploading |
| *purpose*       | Text                                      | **Required.** The intended purpose of the uploaded file |
| *mimeType*      | Text                                      | **Required.** The MIME type of the file   |
| *parameters*    | [OpenAIUploadParameters](OpenAIUploadParameters.md) | Optional parameters including expires_after |
| Function result | [OpenAIUploadResult](OpenAIUploadResult.md) | Result containing the Upload object with status "pending" |

**Throws:** An error if `filename` is empty, `bytes` is not positive, `purpose` is empty, or `mimeType` is empty.

**Example:**
```4d
var $client : cs.AIKit.OpenAI
var $params : cs.AIKit.OpenAIUploadParameters
var $result : cs.AIKit.OpenAIUploadResult

$client:=cs.AIKit.OpenAI.new()

// Optional: Set expiration policy
$params:=cs.AIKit.OpenAIUploadParameters.new()
$params.expires_after:={}
$params.expires_after.anchor:="created_at"
$params.expires_after.seconds:=3600  // Expire after 1 hour

// Create the upload
$result:=$client.uploads.create("training_data.jsonl"; 2147483648; "fine-tune"; "text/jsonl"; $params)

If ($result.success)
    $upload:=$result.upload
    ALERT("Upload created: "+$upload.id)
Else 
    ALERT("Error: "+$result.error.message)
End if 
```

---

### addPart

Adds a Part (chunk of bytes) to an Upload object.

**addPart**(*uploadId* : Text ; *data* : [4D.File](https://developer.4d.com/docs/API/FileClass) or [4D.Blob](https://developer.4d.com/docs/API/BlobClass) ; *parameters* : [OpenAIParameters](OpenAIParameters.md)) : [OpenAIUploadPartResult](OpenAIUploadPartResult.md)

| Parameter       | Type                                      | Description                               |
|-----------------|-------------------------------------------|-------------------------------------------|
| *uploadId*      | Text                                      | **Required.** The ID of the Upload       |
| *data*          | [4D.File](https://developer.4d.com/docs/API/FileClass) or [4D.Blob](https://developer.4d.com/docs/API/BlobClass) | **Required.** The chunk of bytes for this Part |
| *parameters*    | [OpenAIParameters](OpenAIParameters.md)   | Optional parameters                       |
| Function result | [OpenAIUploadPartResult](OpenAIUploadPartResult.md) | Result containing the upload Part object |

**Throws:** An error if `uploadId` is empty or if `data` is not a 4D.File or 4D.Blob.

**Notes:**
- Each Part can be at most 64 MB
- Parts can be added in parallel
- The order is specified when completing the upload

**Example:**
```4d
var $uploadId:="upload_abc123"
var $partIds:=[]

// Add first part
var $partFile:=Folder(fk desktop folder).file("part1.bin")
$result:=$client.uploads.addPart($uploadId; $partFile)

If ($result.success)
    $part:=$result.part
    $partIds.push($part.id)
End if 

// Add second part
$partFile:=Folder(fk desktop folder).file("part2.bin")
var $result:=$client.uploads.addPart($uploadId; $partFile)

If ($result.success)
    $part:=$result.part
    $partIds.push($part.id)
End if 
```

---

### complete

Completes the Upload and creates a usable File object.

**complete**(*uploadId* : Text ; *part_ids* : Collection ; *parameters* : [OpenAIUploadCompleteParameters](OpenAIUploadCompleteParameters.md)) : [OpenAIUploadResult](OpenAIUploadResult.md)

| Parameter       | Type                                      | Description                               |
|-----------------|-------------------------------------------|-------------------------------------------|
| *uploadId*      | Text                                      | **Required.** The ID of the Upload       |
| *part_ids*      | Collection                                | **Required.** The ordered list of Part IDs |
| *parameters*    | [OpenAIUploadCompleteParameters](OpenAIUploadCompleteParameters.md) | Optional parameters including md5 checksum |
| Function result | [OpenAIUploadResult](OpenAIUploadResult.md) | Result with status "completed" and a file property |

**Throws:** An error if `uploadId` is empty or if `part_ids` is null or empty.

**Notes:**
- Must specify the ordered list of Part IDs
- Total bytes must match the initially specified amount
- No Parts may be added after completion

**Example:**
```4d
var $result : cs.AIKit.OpenAIUploadResult
var $params : cs.AIKit.OpenAIUploadCompleteParameters

// Optional: Add MD5 checksum for verification
$params:=cs.AIKit.OpenAIUploadCompleteParameters.new()
$params.md5:="d41d8cd98f00b204e9800998ecf8427e"

$result:=$client.uploads.complete($uploadId; $partIds; $params)

If ($result.success)
    $upload:=$result.upload
    If ($upload.status="completed")
        $file:=$upload.file
        ALERT("File ready: "+$file.id)
    End if 
End if 
```

---

### cancel

Cancels the Upload. No Parts may be added after cancellation.

**cancel**(*uploadId* : Text ; *parameters* : [OpenAIParameters](OpenAIParameters.md)) : [OpenAIUploadResult](OpenAIUploadResult.md)

| Parameter       | Type                                      | Description                               |
|-----------------|-------------------------------------------|-------------------------------------------|
| *uploadId*      | Text                                      | **Required.** The ID of the Upload       |
| *parameters*    | [OpenAIParameters](OpenAIParameters.md)   | Optional parameters                       |
| Function result | [OpenAIUploadResult](OpenAIUploadResult.md) | Result containing the Upload object with status "cancelled" |

**Throws:** An error if `uploadId` is empty.

**Example:**
```4d
var $result:=$client.uploads.cancel($uploadId)

If ($result.success)
    $upload:=$result.upload
    ASSERT($upload.status="cancelled")
End if 
```

---

## Complete Upload Workflow Example

```4d
// 1. Create the upload

var $params:=cs.AIKit.OpenAIUploadParameters.new()
$params.expires_after:={}
$params.expires_after.anchor:="created_at"
$params.expires_after.seconds:=3600  // Expire after 1 hour

var $result: cs.AIKit.OpenAIUploadResult:=$client.uploads.create("large_dataset.jsonl"; 134217728; "fine-tune"; "text/jsonl"; $params)
If (Not($result.success))
    // Handle error
    return 
End if 

var $uploadId:=$result.upload.id
var $partIds:=[]

// 2. Split file and upload parts
var $sourceFile : 4D.File:=Folder(fk desktop folder).file("large_dataset.jsonl")
var $chunkSize : Integer:=67108864  // 64 MB chunks
var $offset : Integer:=0
var $partNumber : Integer:=1

While ($offset<$sourceFile.size)
    // Read chunk from file
    var $blob : 4D.Blob:=4D.Blob.new()
    var $bytesToRead : Integer:=Min($chunkSize; $sourceFile.size-$offset)
    
    // In real implementation, you would read a chunk of the file here
    // For example using File.getContent() or BLOB operations
    
    // Upload the part
    var $partResult : cs.AIKit.OpenAIUploadPartResult
    $partResult:=$client.uploads.addPart($uploadId; $blob)
    
    If ($partResult.success)
        $partIds.push($partResult.part.id)
        $offset:=$offset+$bytesToRead
        $partNumber:=$partNumber+1
    Else 
        // Handle error - maybe cancel the upload
        $client.uploads.cancel($uploadId)
        return 
    End if 
End while 

// 3. Complete the upload
var $completeParams:=cs.AIKit.OpenAIUploadCompleteParameters.new()
$result:=$client.uploads.complete($uploadId; $partIds; $completeParams)

If ($result.success && ($result.upload.status="completed"))
    var $file : cs.AIKit.OpenAIFile:=$result.upload.file
    ALERT("Upload completed! File ID: "+$file.id)
    
    // Now you can use this file for fine-tuning or other purposes
Else 
    ALERT("Upload failed to complete")
End if 
```

## Supported MIME Types by Purpose

| Purpose | Supported MIME Types |
|---------|---------------------|
| assistants | text/*, application/json, application/pdf, image/*, etc. |
| batch | application/jsonl (max 200 MB) |
| fine-tune | application/jsonl, text/jsonl |
| vision | image/jpeg, image/png, image/gif, image/webp |

## Important Notes

1. **Upload Expiration**: Uploads expire after 1 hour of creation if not completed
2. **Size Limits**: 
   - Maximum upload size: 8 GB
   - Maximum part size: 64 MB
   - Batch API: 200 MB maximum for .jsonl files
3. **Parallel Uploads**: Parts can be uploaded in parallel for faster processing
4. **Byte Count**: The total bytes uploaded must exactly match the `bytes` specified when creating the upload
5. **Part Ordering**: Specify the correct order of parts when completing the upload

## See Also
- [OpenAIUpload](OpenAIUpload.md) - The Upload object model
- [OpenAIUploadPart](OpenAIUploadPart.md) - The Upload Part object model
- [OpenAIUploadParameters](OpenAIUploadParameters.md) - Create upload parameters
- [OpenAIUploadCompleteParameters](OpenAIUploadCompleteParameters.md) - Complete upload parameters
- [OpenAIUploadResult](OpenAIUploadResult.md) - Upload result class
- [OpenAIFilesAPI](OpenAIFilesAPI.md) - Regular file upload API
- [OpenAI Platform Documentation](https://platform.openai.com/docs/api-reference/uploads)
