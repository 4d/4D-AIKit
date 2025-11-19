# OpenAIResponsesStreamResult

The `OpenAIResponsesStreamResult` class represents a single Server-Sent Event (SSE) chunk returned by the Responses API when `stream` is enabled.

## Properties

### event
**Type**: Text

The SSE event name (for example `response.output_text.delta`). If not provided, it falls back to `data.type` when available.

### data
**Type**: Object

The parsed JSON payload for the event.

### terminated
**Type**: Boolean

True when this result represents the final streamed event.

## Functions

### success

**get success** : Boolean

Returns True when the event data was parsed successfully.

### errors

**get errors** : Collection

Returns any parsing or HTTP errors associated with this event.

## Example Usage

```4d
var $params:=cs.AIKit.OpenAIResponsesParameters.new()
$params.model:="gpt-4o"
$params.stream:=True
$params.onData:=Formula(_handleResponsesStream($1))

// _handleResponsesStream($event)
// If ($event.event="response.output_text.delta")
//     LOG EVENT(Into system standard outputs; $event.data.delta; Information message)
// End if

$client.responses.create("Tell me a story"; $params)
```
