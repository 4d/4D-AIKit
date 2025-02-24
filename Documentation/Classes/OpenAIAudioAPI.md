# OpenAIAudioAPI

The `OpenAIAudioAPI` class provides functionalities to handle audio-related operations using the OpenAI API.

## Inherits

- [OpenAIAPIResource](OpenAIAPIResource.md)

## Functions

### `transcribe`

Transcribes the provided audio data using the specified parameters.

| Argument     | Type                                  | Description                                      |
|--------------|---------------------------------------|--------------------------------------------------|
| `$audioData` | Blob                                  | The audio data to transcribe.                    |
| `$parameters`| [OpenAIAudioParameters](OpenAIAudioParameters.md) | The parameters to customize the transcription request. |

**Returns**: [OpenAIAudioResult](OpenAIAudioResult.md)

### `translate`

Translates the provided audio data using the specified parameters.

| Argument     | Type                                  | Description                                      |
|--------------|---------------------------------------|--------------------------------------------------|
| `$audioData` | Blob                                  | The audio data to translate.                     |
| `$parameters`| [OpenAIAudioParameters](OpenAIAudioParameters.md) | The parameters to customize the translation request. |

**Returns**: [OpenAIAudioResult](OpenAIAudioResult.md)

#### Example Usage

```4d
var $audioData : Blob:=$file.getContent()
var $result:=$client.audio.transcribe($audioData; $parameters)
```