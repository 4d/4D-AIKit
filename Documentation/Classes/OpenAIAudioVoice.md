# OpenAIAudioVoice

The `OpenAIAudioVoice` class is a text-to-speech voice: a built-in one, a custom one, or one listed by a compatible server.

## Properties

| Property     | Type    | Description |
|--------------|---------|-------------|
| `id`         | Text    | The voice identifier. |
| `name`       | Text    | The name of the voice. |
| `object`     | Text    | The object type, `audio.voice` for an OpenAI custom voice. |
| `created_at` | Integer | The Unix timestamp (in seconds) for when the voice was created. |
| `type`       | Text    | How the voice was created: `audio_sample` or `prompt` for OpenAI, `builtin` for a well-known voice. Other servers have their own values. |
| `prompt`     | Text    | The prompt used to create the voice, if any. |
| `model`      | Text    | The model of the voice, when the server groups its voices by model. |
| `custom`     | Boolean | `True` if it is one of the [custom voices](OpenAIAudioVoicesAPI.md#custom-voices) of the client. |

The other properties sent by the server are kept as is: `description`, `language`, `gender`...

Servers do not agree on the name of the identifier. `id` is filled with the first found of: `id`, `voice_id`, `voiceId`, `ShortName`, `_id`, `canonical_name`, `name`. `name` falls back to `display_name`, `displayName`, `DisplayName`, `title`, then to the `id`.

## Computed properties

| Property    | Type           | Description |
|-------------|----------------|-------------|
| `reference` | Text or Object | The value to pass as *voice* of [speech()](OpenAIAudioAPI.md#speech): `{id: "voice_1234"}` for an OpenAI custom voice, otherwise the `id`. |

## See also

- [OpenAIAudioVoicesAPI](OpenAIAudioVoicesAPI.md)
