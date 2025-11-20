# GeminiFileListParameters

## Description

Parameters for listing uploaded files with pagination support.

## Inherits

[GeminiParameters](GeminiParameters.md)

## Properties

| Property  | Type    | Description                           |
|-----------|---------|---------------------------------------|
| pageSize  | Integer | Maximum number of files to return     |
| pageToken | Text    | Token for pagination (next page)      |

## Constructor

```4d
$params:=cs.GeminiFileListParameters.new()
$params:=cs.GeminiFileListParameters.new($object)
```

## Examples

### Basic List

```4d
var $result:=$gemini.files.list()

If ($result.success)
    For each ($file; $result.files)
        ALERT($file.displayName)
    End for each
End if
```

### With Page Size

```4d
var $params:=cs.GeminiFileListParameters.new()
$params.pageSize:=10  // Get 10 files per page

var $result:=$gemini.files.list($params)

If ($result.success)
    ALERT("Retrieved "+String($result.files.length)+" files")
End if
```

### Pagination

```4d
var $params:=cs.GeminiFileListParameters.new()
$params.pageSize:=20
var $allFiles:=[]

// Get first page
var $result:=$gemini.files.list($params)

If ($result.success)
    $allFiles:=$allFiles.combine($result.files)

    // Get subsequent pages
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

### Filter Results

```4d
var $params:=cs.GeminiFileListParameters.new()
$params.pageSize:=100

var $result:=$gemini.files.list($params)

If ($result.success)
    // Filter by MIME type
    var $pdfFiles:=$result.files.query("mimeType == :1"; "application/pdf")
    ALERT("PDF files: "+String($pdfFiles.length))

    // Filter by display name
    var $recentFiles:=$result.files.query("displayName == :1"; "@2024@")
    ALERT("Recent files: "+String($recentFiles.length))
End if
```

### List with Processing

```4d
var $params:=cs.GeminiFileListParameters.new()
$params.pageSize:=50

var $result:=$gemini.files.list($params)

If ($result.success)
    For each ($file; $result.files)
        Case of
            : ($file.state="ACTIVE")
                ALERT($file.displayName+" is ready")
            : ($file.state="PROCESSING")
                ALERT($file.displayName+" is processing")
            : ($file.state="FAILED")
                ALERT($file.displayName+" failed: "+$file.error.message)
        End case
    End for each
End if
```

### Delete Old Files

```4d
var $params:=cs.GeminiFileListParameters.new()
$params.pageSize:=100

var $result:=$gemini.files.list($params)

If ($result.success)
    var $now:=Current date

    For each ($file; $result.files)
        // Parse creation time (ISO 8601)
        var $createDate:=Date($file.createTime)

        // Delete files older than 30 days
        If ($createDate<($now-30))
            $gemini.files.delete($file.name)
            ALERT("Deleted old file: "+$file.displayName)
        End if
    End for each
End if
```

### Count Files by Type

```4d
var $result:=$gemini.files.list()

If ($result.success)
    var $stats:={}

    For each ($file; $result.files)
        var $type:=$file.mimeType
        If ($stats[$type]=Null)
            $stats[$type]:=0
        End if
        $stats[$type]:=$stats[$type]+1
    End for each

    // Display statistics
    For each ($type; $stats)
        ALERT($type+": "+String($stats[$type])+" files")
    End for each
End if
```

### Search by Name

```4d
var $searchTerm:="contract"
var $params:=cs.GeminiFileListParameters.new()
$params.pageSize:=100

var $result:=$gemini.files.list($params)

If ($result.success)
    var $matches:=$result.files.query("displayName == :1"; "@"+$searchTerm+"@")

    For each ($file; $matches)
        ALERT("Found: "+$file.displayName)
    End for each
End if
```

## Pagination Best Practices

1. **Set reasonable page sizes** (10-100) to balance performance
2. **Check `nextPageToken`** to determine if more pages exist
3. **Store page tokens** if implementing back/forward navigation
4. **Handle errors** during pagination loops

## Example: Complete Pagination Loop

```4d
var $params:=cs.GeminiFileListParameters.new()
$params.pageSize:=25
var $allFiles:=[]
var $pageCount:=0

Repeat
    $pageCount+=1
    var $result:=$gemini.files.list($params)

    If ($result.success)
        $allFiles:=$allFiles.combine($result.files)
        ALERT("Page "+String($pageCount)+": "+String($result.files.length)+" files")

        If (Length($result.nextPageToken)>0)
            $params.pageToken:=$result.nextPageToken
        Else
            break  // No more pages
        End if
    Else
        ALERT("Error on page "+String($pageCount))
        break
    End if
Until (False)

ALERT("Retrieved "+String($allFiles.length)+" files in "+String($pageCount)+" pages")
```

## See Also

- [GeminiParameters](GeminiParameters.md) - Base parameters class
- [GeminiFilesAPI](GeminiFilesAPI.md) - Files API
- [GeminiFileListResult](GeminiFileListResult.md) - List result
- [GeminiFile](GeminiFile.md) - File data structure
