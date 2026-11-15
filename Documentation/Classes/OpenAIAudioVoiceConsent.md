# OpenAIAudioVoiceConsent

The `OpenAIAudioVoiceConsent` class is a consent recording, which authorizes the creation of a voice from an audio sample.

## Properties

| Property     | Type    | Description |
|--------------|---------|-------------|
| `id`         | Text    | The consent recording identifier, ie. `cons_1234`. |
| `object`     | Text    | The object type, which is always `audio.voice_consent`. |
| `name`       | Text    | The label of the consent recording. |
| `language`   | Text    | The BCP 47 language tag of the consent phrase, ie. `en-US`. |
| `created_at` | Integer | The Unix timestamp (in seconds) for when the consent recording was created. |

## See also

- [OpenAIAudioVoiceConsentsAPI](OpenAIAudioVoiceConsentsAPI.md)
