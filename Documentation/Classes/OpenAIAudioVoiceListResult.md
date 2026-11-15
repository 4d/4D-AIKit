# OpenAIAudioVoiceListResult

The `OpenAIAudioVoiceListResult` class contains the result of [listing voices](OpenAIAudioVoicesAPI.md#list).

## Inherits

[OpenAIResult](OpenAIResult.md)

## Computed properties

| Property  | Type       | Description |
|-----------|------------|-------------|
| `voices`  | Collection | A collection of [OpenAIAudioVoice](OpenAIAudioVoice.md), or an empty collection if none found. |
| `success` | Boolean    | `True` if the voices are available. When the server has no endpoint to list voices there is no `request`, and it is always a success. |

The voices are decoded whatever the format of the server: a list under `voices`, `data` or `items`, or the response itself; voices as objects or as plain names; and voices grouped by model.

The result has no pagination property, they are not standard: read them from `request.response.body` and send the next page with the `query` parameter.

## See also

- [OpenAIAudioVoicesAPI](OpenAIAudioVoicesAPI.md)
- [OpenAIAudioVoiceListParameters](OpenAIAudioVoiceListParameters.md)
