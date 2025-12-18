# OpenAIAudioTranscriptionParameters

The `OpenAIAudioTranscriptionParameters` class is designed to configure and manage the parameters used for audio transcription (speech-to-text) through the OpenAI API.

## Inherits

- [OpenAIParameters](OpenAIParameters.md)

## Properties

| Property Name              | Type       | Description                                                                                      |
|----------------------------|------------|--------------------------------------------------------------------------------------------------|
| `chunking_strategy`        | Variant    | Strategy for chunking audio. Can be `"auto"` or an object with type property.                   |
| `include`                  | Collection | Additional information to include in the response. Array can contain `"logprobs"`.              |
| `known_speaker_names`      | Collection | List of known speaker names for diarization (up to 4 speakers).                                 |
| `known_speaker_references` | Collection | Audio samples as data URLs for speaker references (2-10 seconds each).                          |
| `language`                 | Text       | The language of the input audio in ISO-639-1 format (e.g., `"en"`, `"fr"`, `"es"`).             |
| `prompt`                   | Text       | Optional text to guide the model's style or continue a previous audio segment.                  |
| `response_format`          | Text       | The format of the transcript output (see formats below). Default: `json`.                       |
| `stream`                   | Boolean    | Enable streaming of the transcription response.                                                 |
| `temperature`              | Real       | Sampling temperature between 0 and 1. Default: 0.                                               |
| `filename`                 | Text       | Filename to use for blob uploads (optional).                                                    |

### response_format

The following transcript output formats are supported:

| Format          | Description                                              | Result property to use |
|-----------------|----------------------------------------------------------|------------------------|
| `json`          | Simple JSON with transcribed text.                       | `text`                 |
| `text`          | Plain text output.                                       | `textContent`          |
| `srt`           | SubRip subtitle format with timestamps.                  | `textContent`          |
| `verbose_json`  | Detailed JSON with segments, words, and timestamps.      | `text`, `transcription`|
| `vtt`           | WebVTT subtitle format with timestamps.                  | `textContent`          |
| `diarized_json` | JSON with speaker diarization information.               | `text`, `transcription`|

### language

Providing the input language in ISO-639-1 format can improve accuracy and reduce latency.

Common language codes:
- `en` - English
- `fr` - French
- `es` - Spanish
- `de` - German
- `it` - Italian
- `pt` - Portuguese
- `zh` - Chinese
- `ja` - Japanese

### Speaker Diarization

When using the `gpt-4o-transcribe-diarize` model, you can provide speaker information:

- `known_speaker_names`: Up to 4 speaker names
- `known_speaker_references`: Audio samples (2-10 seconds) as data URLs to help identify speakers

## Example

Basic transcription:

```4d
var $params:=cs.AIKit.OpenAIAudioTranscriptionParameters.new({language: "en"})
var $result:=$client.audio.transcription($audioFile; "whisper-1"; $params)
```

Verbose JSON with timestamps:

```4d
var $params:=cs.AIKit.OpenAIAudioTranscriptionParameters.new({
    response_format: "verbose_json";
    language: "en"
})
var $result:=$client.audio.transcription($audioFile; "whisper-1"; $params)

// Access detailed transcription
var $transcription:=$result.transcription
var $duration:=$transcription.duration
var $segments:=$transcription.segments
```

Generate SRT subtitles:

```4d
var $params:=cs.AIKit.OpenAIAudioTranscriptionParameters.new({response_format: "srt"})
var $result:=$client.audio.transcription($videoAudio; "whisper-1"; $params)

var $srtContent:=$result.textContent
```

With speaker diarization:

```4d
var $params:=cs.AIKit.OpenAIAudioTranscriptionParameters.new({
    response_format: "diarized_json";
    known_speaker_names: ["Alice"; "Bob"]
})
var $result:=$client.audio.transcription($meetingAudio; "gpt-4o-transcribe-diarize"; $params)
```

## See also

- [OpenAIAudioAPI](OpenAIAudioAPI.md)
- [OpenAIAudioTranscriptionResult](OpenAIAudioTranscriptionResult.md)
- [OpenAIAudioTranscription](OpenAIAudioTranscription.md)
