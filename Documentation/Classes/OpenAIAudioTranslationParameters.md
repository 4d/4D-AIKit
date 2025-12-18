# OpenAIAudioTranslationParameters

The `OpenAIAudioTranslationParameters` class is designed to configure and manage the parameters used for audio translation (to English) through the OpenAI API.

## Inherits

- [OpenAIParameters](OpenAIParameters.md)

## Properties

| Property Name     | Type    | Description                                                                                      |
|-------------------|---------|--------------------------------------------------------------------------------------------------|
| `prompt`          | Text    | Optional text to guide the model's style (should be in English).                                 |
| `response_format` | Text    | The format of the translation output (see formats below). Default: `json`.                       |
| `temperature`     | Real    | Sampling temperature between 0 and 1. Default: 0.                                               |
| `filename`        | Text    | Filename to use for blob uploads (optional).                                                    |

### response_format

The following translation output formats are supported:

| Format         | Description                                              | Result property to use |
|----------------|----------------------------------------------------------|------------------------|
| `json`         | Simple JSON with translated text.                        | `text`                 |
| `text`         | Plain text output.                                       | `textContent`          |
| `srt`          | SubRip subtitle format with timestamps.                  | `textContent`          |
| `verbose_json` | Detailed JSON with segments, words, and timestamps.      | `text`, `translation`  |
| `vtt`          | WebVTT subtitle format with timestamps.                  | `textContent`          |

### prompt

The `prompt` property allows you to provide context or guide the translation style. The prompt should be in English since translations are always to English.

Examples:
- "This is a formal business presentation"
- "Technical discussion about software development"
- "Casual conversation between friends"

### temperature

The `temperature` controls the randomness of the translation:
- `0` - More deterministic, focused output
- `1` - More varied, creative output

## Example

Basic translation:

```4d
var $frenchAudio:=File("/RESOURCES/audio/french.mp3")
var $result:=$client.audio.translation($frenchAudio; "whisper-1")

If ($result.success)
    var $englishText:=$result.text
End if
```

With prompt guidance:

```4d
var $params:=cs.AIKit.OpenAIAudioTranslationParameters.new({
    prompt: "This is a technical presentation about database architecture"
})
var $result:=$client.audio.translation($audioFile; "whisper-1"; $params)
```

Generate SRT subtitles:

```4d
var $params:=cs.AIKit.OpenAIAudioTranslationParameters.new({response_format: "srt"})
var $result:=$client.audio.translation($foreignAudio; "whisper-1"; $params)

var $srtContent:=$result.textContent
```

Verbose JSON with timestamps:

```4d
var $params:=cs.AIKit.OpenAIAudioTranslationParameters.new({response_format: "verbose_json"})
var $result:=$client.audio.translation($audioFile; "whisper-1"; $params)

var $translation:=$result.translation
var $duration:=$translation.duration
var $segments:=$translation.segments
```

## See also

- [OpenAIAudioAPI](OpenAIAudioAPI.md)
- [OpenAIAudioTranslationResult](OpenAIAudioTranslationResult.md)
- [OpenAIAudioTranscription](OpenAIAudioTranscription.md)
