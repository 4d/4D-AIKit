# OpenAIAssistantsAPI

The `OpenAIAssistantsAPI` class provides functionalities to create and manage AI assistants using OpenAI's Assistants API. Assistants can call models with specific instructions, use tools, and access knowledge to perform tasks.

> **Note:** This API is only compatible with OpenAI. Other providers listed in the [compatible providers](../compatible-openai.md) documentation do not support the Assistants API.

API Reference: <https://platform.openai.com/docs/api-reference/assistants>

## Functions

### create()

**create**(*parameters* : cs.OpenAIAssistantsParameters) : cs.OpenAIAssistantsResult

Create an assistant with a model and instructions.

**Endpoint:** `POST https://api.openai.com/v1/assistants`

| Parameter       | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| *parameters*    | [OpenAIAssistantsParameters](OpenAIAssistantsParameters.md) | **Required.** Parameters for creating the assistant including model and optional instructions. |
| Function result | [OpenAIAssistantsResult](OpenAIAssistantsResult.md) | The assistant result |

**Throws:** An error if `parameters` is null or if `parameters.model` is empty.

#### Example

```4d
var $params:=cs.AIKit.OpenAIAssistantsParameters.new()
$params.model:="gpt-4o"
$params.name:="Math Tutor"
$params.instructions:="You are a personal math tutor. Write and run code to answer math questions."
$params.tools:=[]
$params.tools.push({type: "code_interpreter"})

var $result:=$client.assistants.create($params)

If ($result.success)
    var $assistant:=$result.assistant
    // $assistant.id -> "asst_abc123"
    // $assistant.name -> "Math Tutor"
End if
```

### retrieve()

**retrieve**(*assistantId* : Text; *parameters* : cs.OpenAIParameters) : cs.OpenAIAssistantsResult

Retrieves an assistant by its ID.

**Endpoint:** `GET https://api.openai.com/v1/assistants/{assistant_id}`

| Parameter       | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| *assistantId*   | Text                           | **Required.** The ID of the assistant to retrieve.       |
| *parameters*    | [OpenAIParameters](OpenAIParameters.md) | Optional parameters for the request.                     |
| Function result | [OpenAIAssistantsResult](OpenAIAssistantsResult.md) | The assistant result |

**Throws:** An error if `assistantId` is empty.

#### Example

```4d
var $result:=$client.assistants.retrieve("asst_abc123")

If ($result.success)
    var $assistant:=$result.assistant
    // $assistant.name -> "Math Tutor"
    // $assistant.model -> "gpt-4o"
End if
```

### modify()

**modify**(*assistantId* : Text; *parameters* : cs.OpenAIAssistantsParameters) : cs.OpenAIAssistantsResult

Modifies an existing assistant.

**Endpoint:** `POST https://api.openai.com/v1/assistants/{assistant_id}`

| Parameter       | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| *assistantId*   | Text                           | **Required.** The ID of the assistant to modify.         |
| *parameters*    | [OpenAIAssistantsParameters](OpenAIAssistantsParameters.md) | **Required.** Parameters to update on the assistant.     |
| Function result | [OpenAIAssistantsResult](OpenAIAssistantsResult.md) | The updated assistant result |

**Throws:** An error if `assistantId` is empty or if `parameters` is null.

#### Example

```4d
var $params:=cs.AIKit.OpenAIAssistantsParameters.new()
$params.name:="Physics Tutor"
$params.instructions:="You are a personal physics tutor. Explain concepts clearly with examples."

var $result:=$client.assistants.modify("asst_abc123"; $params)

If ($result.success)
    var $assistant:=$result.assistant
    // $assistant.name -> "Physics Tutor"
End if
```

### list()

**list**(*parameters* : cs.OpenAIAssistantListParameters) : cs.OpenAIAssistantListResult

Returns a list of assistants.

**Endpoint:** `GET https://api.openai.com/v1/assistants`

| Parameter       | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| *parameters*    | [OpenAIAssistantListParameters](OpenAIAssistantListParameters.md) | Optional parameters for filtering and pagination.        |
| Function result | [OpenAIAssistantListResult](OpenAIAssistantListResult.md) | The assistant list result |

#### Example

```4d
var $params:=cs.AIKit.OpenAIAssistantListParameters.new()
$params.limit:=20
$params.order:="desc"

var $result:=$client.assistants.list($params)

If ($result.success)
    var $assistants:=$result.assistants

    For each ($assistant; $assistants)
        // $assistant.name -> "Math Tutor", "Physics Tutor", etc.
    End for each

    If ($result.hasMore)
        // More assistants available
        var $lastId:=$result.lastId
    End if
End if
```

### delete()

**delete**(*assistantId* : Text; *parameters* : cs.OpenAIParameters) : cs.OpenAIAssistantDeletedResult

Delete an assistant.

**Endpoint:** `DELETE https://api.openai.com/v1/assistants/{assistant_id}`

| Parameter       | Type                           | Description                                               |
|-----------------|--------------------------------|-----------------------------------------------------------|
| *assistantId*   | Text                           | **Required.** The ID of the assistant to delete.         |
| *parameters*    | [OpenAIParameters](OpenAIParameters.md) | Optional parameters for the request.                     |
| Function result | [OpenAIAssistantDeletedResult](OpenAIAssistantDeletedResult.md) | The assistant deletion result |

**Throws:** An error if `assistantId` is empty.

#### Example

```4d
var $result:=$client.assistants.delete("asst_abc123")

If ($result.success)
    var $status:=$result.deleted

    If ($status.deleted)
        ALERT("Assistant deleted successfully")
    End if
End if
```

## See also

- [OpenAIAssistant](OpenAIAssistant.md)
- [OpenAIAssistantsParameters](OpenAIAssistantsParameters.md)
- [OpenAIAssistantListParameters](OpenAIAssistantListParameters.md)
- [OpenAIAssistantsResult](OpenAIAssistantsResult.md)
- [OpenAIAssistantListResult](OpenAIAssistantListResult.md)
- [OpenAIAssistantDeletedResult](OpenAIAssistantDeletedResult.md)
- [OpenAIAssistantDeleted](OpenAIAssistantDeleted.md)
