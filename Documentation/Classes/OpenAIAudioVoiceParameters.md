# OpenAIAudioVoiceParameters

The `OpenAIAudioVoiceParameters` class contains the parameters to [create a voice](OpenAIAudioVoicesAPI.md#create).

## Inherits

[OpenAIParameters](OpenAIParameters.md)

## Properties

To create the voice from an audio sample:

| Property       | Type               | Description |
|----------------|--------------------|-------------|
| `audio_sample` | 4D.File or 4D.Blob | The audio sample of the voice. OpenAI accepts at most 60 seconds and 10 MiB, in `mp3`, `wav`, `ogg`, `aac`, `flac`, `webm` or `mp4` format. |
| `consent`      | Text               | The ID of the [consent recording](OpenAIAudioVoiceConsentsAPI.md) that authorizes it, ie. `cons_1234`. |
| `filename`     | Text               | The file name of `audio_sample` when it is a blob. By default it is deduced from the signature of the content. |

To create the voice from a description:

| Property      | Type | Description |
|---------------|------|-------------|
| `prompt`      | Text | A description of the desired voice, up to 2000 characters. |
| `model`       | Text | The model that creates the voice. Default: `auto`. |
| `script_hint` | Text | A text for the voice to speak during its creation. |

| Property | Type | Description |
|----------|------|-------------|
| `type`   | Text | `audio_sample` or `prompt`. By default deduced from the other parameters. |

## See also

- [OpenAIAudioVoicesAPI](OpenAIAudioVoicesAPI.md)
