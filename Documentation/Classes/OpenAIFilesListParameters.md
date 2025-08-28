# OpenAIFilesListParameters

The `OpenAIFilesListParameters` class contains parameters for listing files.

## Properties

| Property Name | Type    | Description                                                          |
|---------------|---------|----------------------------------------------------------------------|
| `after`       | Text    | A cursor for pagination - ID of the object after which to start.    |
| `limit`       | Integer | Maximum number of objects to return (1-10,000, default 10,000).     |
| `order`       | Text    | Sort order by `created_at` timestamp ("asc" or "desc").             |
| `purpose`     | Text    | Only return files with the given purpose.                           |

Plus all properties from [OpenAIParameters](OpenAIParameters.md).

## Class constructor

Create a new instance with the specified parameters.

| Argument Name | Type   | Description                      |
|---------------|--------|----------------------------------|
| `object`      | Object | Object containing the parameters |

## Parent

[OpenAIParameters](OpenAIParameters.md)
