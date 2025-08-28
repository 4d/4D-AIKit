# OpenAIFileListParameters

The `OpenAIFileListParameters` class contains parameters for listing files.

## Inherits

[OpenAIParameters](OpenAIParameters.md)

## Properties

| Property Name | Type    | Description                                                         |
|---------------|---------|---------------------------------------------------------------------|
| `after`       | Text    | A cursor for pagination - ID of the object after which to start.    |
| `limit`       | Integer | Maximum number of objects to return (1-10,000, default 10,000).     |
| `order`       | Text    | Sort order by `created_at` timestamp ("asc" or "desc").             |
| `purpose`     | Text    | Only return files with the given purpose.                           |
