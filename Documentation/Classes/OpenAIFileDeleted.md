# OpenAIFileDeleted

The `OpenAIFileDeleted` class represents the result of a file deletion operation.

## Properties

| Property Name | Type    | Description                                    |
|---------------|---------|------------------------------------------------|
| `id`          | Text    | The ID of the deleted file.                   |
| `deleted`     | Boolean | Whether the file was successfully deleted.     |
| `object`      | Text    | The object type, which is always "file".      |

## Class constructor

Create a new instance from a deletion result object.

| Argument Name | Type   | Description                                     |
|---------------|--------|-------------------------------------------------|
| `object`      | Object | The deletion result object data from the API.  |

## Parent

None (base class)

## Used by

- [OpenAIFilesDeletedResult](OpenAIFilesDeletedResult.md)
