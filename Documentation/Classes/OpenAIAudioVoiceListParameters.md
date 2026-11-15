# OpenAIAudioVoiceListParameters

The `OpenAIAudioVoiceListParameters` class contains the parameters to [list voices](OpenAIAudioVoicesAPI.md#list).

## Inherits

[OpenAIParameters](OpenAIParameters.md)

## Properties

| Property | Type    | Description |
|----------|---------|-------------|
| `path`   | Text    | The path of the endpoint which lists the voices, after the `baseURL`, ie. `/voices`. By default it depends on the server, see [Listing voices](../audio-voices.md). With a path the server is always requested. |
| `model`  | Text    | Only return the voices of this model. Used for the well-known voices, and sent as `model` query parameter to `/audio/voices`. |
| `query`  | Object  | Query parameters to send to the server, ie. `{limit: 50}`. |
| `custom` | Boolean | Add the [custom voices](OpenAIAudioVoicesAPI.md#custom-voices) of the client to the well-known ones. Default: `True`. |

Use `extraHeaders` for a server with its own authentication:

```4d
var $client:=cs.AIKit.OpenAI.new({baseURL: "https://api.cartesia.ai"})
var $voices:=$client.audio.voices.list({path: "/voices"; \
    extraHeaders: {Authorization: "Bearer "+$key; "Cartesia-Version": "2026-08-14"}}).voices
```

## See also

- [OpenAIAudioVoicesAPI](OpenAIAudioVoicesAPI.md)
