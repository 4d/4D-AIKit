# OpenAIAssistantListParameters

The `OpenAIAssistantListParameters` class handles parameters for listing assistants with pagination support.

## Inherits

[OpenAIParameters](OpenAIParameters.md)

## Properties

| Property Name | Type    | Required | Description                          |
|---------------|---------|----------|--------------------------------------|
| `limit`       | Integer | Optional | A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20. |
| `order`       | Text    | Optional | Sort order by the `created_at` timestamp of the objects. `asc` for ascending order and `desc` for descending order. Default is `desc`. |
| `after`       | Text    | Optional | A cursor for use in pagination. `after` is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include after=obj_foo in order to fetch the next page of the list. |
| `before`      | Text    | Optional | A cursor for use in pagination. `before` is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include before=obj_foo in order to fetch the previous page of the list. |

## Example Usage

```4d
var $params:=cs.AIKit.OpenAIAssistantListParameters.new()
$params.limit:=50
$params.order:="desc"
$params.after:="asst_abc123"

var $result:=$client.assistants.list($params)
```

## See also

- [OpenAIAssistantsAPI](OpenAIAssistantsAPI.md)
- [OpenAIAssistantListResult](OpenAIAssistantListResult.md)
