# GeminiFileListResult

## Description

Result object for listing files. Contains a collection of uploaded files and pagination information.

## Inherits

[GeminiResult](GeminiResult.md)

## Functions

### get files

**files** : Collection

| Property        | Type       | Description                      |
|-----------------|------------|----------------------------------|
| Function result | Collection | Collection of GeminiFile objects |

Returns collection of files.

### get nextPageToken

**nextPageToken** : Text

| Property        | Type | Description                           |
|-----------------|------|---------------------------------------|
| Function result | Text | Token for retrieving the next page    |

Returns pagination token for next page (empty if no more pages).

## Examples

### Basic List

```4d
var $result:=$gemini.files.list()

If ($result.success)
    ALERT("Found "+String($result.files.length)+" files")

    For each ($file; $result.files)
        ALERT($file.displayName+" ("+$file.mimeType+")")
    End for each
End if
```

### Pagination

```4d
var $params:=cs.GeminiFileListParameters.new()
$params.pageSize:=10

var $result:=$gemini.files.list($params)

If ($result.success)
    ALERT("Page 1: "+String($result.files.length)+" files")

    // Check for more pages
    If (Length($result.nextPageToken)>0)
        $params.pageToken:=$result.nextPageToken
        var $nextResult:=$gemini.files.list($params)

        If ($nextResult.success)
            ALERT("Page 2: "+String($nextResult.files.length)+" files")
        End if
    End if
End if
```

### Get All Files

```4d
var $params:=cs.GeminiFileListParameters.new()
$params.pageSize:=50
var $allFiles:=[]

// Get first page
var $result:=$gemini.files.list($params)

If ($result.success)
    $allFiles:=$result.files

    // Get remaining pages
    While (Length($result.nextPageToken)>0)
        $params.pageToken:=$result.nextPageToken
        $result:=$gemini.files.list($params)

        If ($result.success)
            $allFiles:=$allFiles.combine($result.files)
        Else
            break
        End if
    End while

    ALERT("Total files: "+String($allFiles.length))
End if
```

### Filter by Type

```4d
var $result:=$gemini.files.list()

If ($result.success)
    // Get PDF files
    var $pdfFiles:=[]

    For each ($file; $result.files)
        If ($file.mimeType="application/pdf")
            $pdfFiles.push($file)
        End if
    End for each

    ALERT("PDF files: "+String($pdfFiles.length))
End if
```

### Filter by State

```4d
var $result:=$gemini.files.list()

If ($result.success)
    var $activeFiles:=[]
    var $processingFiles:=[]
    var $failedFiles:=[]

    For each ($file; $result.files)
        Case of
            : ($file.state="ACTIVE")
                $activeFiles.push($file)
            : ($file.state="PROCESSING")
                $processingFiles.push($file)
            : ($file.state="FAILED")
                $failedFiles.push($file)
        End case
    End for each

    ALERT("Active: "+String($activeFiles.length))
    ALERT("Processing: "+String($processingFiles.length))
    ALERT("Failed: "+String($failedFiles.length))
End if
```

### Delete Old Files

```4d
var $result:=$gemini.files.list()

If ($result.success)
    var $now:=Current date
    var $deleted:=0

    For each ($file; $result.files)
        // Parse creation date (simplified - use proper ISO 8601 parsing)
        var $createdDate:=Date($file.createTime)

        // Delete files older than 30 days
        If ($createdDate<($now-30))
            var $deleteResult:=$gemini.files.delete($file.name)
            If ($deleteResult.success)
                $deleted+=1
            End if
        End if
    End for each

    ALERT("Deleted "+String($deleted)+" old files")
End if
```

### Search by Name

```4d
var $searchTerm:="invoice"
var $result:=$gemini.files.list()

If ($result.success)
    var $matches:=[]

    For each ($file; $result.files)
        If (Position($searchTerm; Lowercase($file.displayName))>0)
            $matches.push($file)
        End if
    End for each

    ALERT("Found "+String($matches.length)+" matches")

    For each ($file; $matches)
        ALERT($file.displayName)
    End for each
End if
```

### Calculate Storage Usage

```4d
var $result:=$gemini.files.list()

If ($result.success)
    var $totalSize:=0

    For each ($file; $result.files)
        $totalSize+:=$file.sizeBytes
    End for each

    var $sizeMB:=$totalSize / (1024 * 1024)
    ALERT("Total storage: "+String($sizeMB; "###,##0.00")+" MB")
End if
```

### Group by MIME Type

```4d
var $result:=$gemini.files.list()

If ($result.success)
    var $byType:={}

    For each ($file; $result.files)
        var $type:=$file.mimeType

        If ($byType[$type]=Null)
            $byType[$type]:={count: 0; size: 0}
        End if

        $byType[$type].count+=1
        $byType[$type].size+:=$file.sizeBytes
    End for each

    // Display statistics
    For each ($type; $byType)
        var $sizeMB:=$byType[$type].size / (1024 * 1024)
        ALERT($type+": "+String($byType[$type].count)+" files, "+String($sizeMB; "##0.00")+" MB")
    End for each
End if
```

### Export File List

```4d
var $result:=$gemini.files.list()

If ($result.success)
    var $export:=[]

    For each ($file; $result.files)
        $export.push({\
            name: $file.displayName; \
            mimeType: $file.mimeType; \
            size: $file.sizeBytes; \
            state: $file.state; \
            created: $file.createTime; \
            uri: $file.uri})
    End for each

    // Save to file
    var $file:=File("/PACKAGE/file_list.json")
    $file.setText(JSON Stringify($export; *))

    ALERT("Exported "+String($export.length)+" files")
End if
```

### Find Specific File

```4d
var $fileName:="contract.pdf"
var $result:=$gemini.files.list()

If ($result.success)
    var $found:=Null

    For each ($file; $result.files)
        If ($file.displayName=$fileName)
            $found:=$file
            break
        End if
    End for each

    If ($found#Null)
        ALERT("Found: "+$found.uri)
    Else
        ALERT("File not found")
    End if
End if
```

## Pagination Pattern

```4d
var $params:=cs.GeminiFileListParameters.new()
$params.pageSize:=25
var $allFiles:=[]

Repeat
    var $result:=$gemini.files.list($params)

    If ($result.success)
        $allFiles:=$allFiles.combine($result.files)

        If (Length($result.nextPageToken)>0)
            $params.pageToken:=$result.nextPageToken
        Else
            break  // No more pages
        End if
    Else
        break  // Error occurred
    End if
Until (False)
```

## See Also

- [GeminiResult](GeminiResult.md) - Base result class
- [GeminiFile](GeminiFile.md) - File structure
- [GeminiFilesAPI](GeminiFilesAPI.md) - Files API
- [GeminiFileListParameters](GeminiFileListParameters.md) - List parameters
