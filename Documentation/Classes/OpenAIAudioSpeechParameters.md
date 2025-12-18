# OpenAIAudioSpeechParameters

The `OpenAIAudioSpeechParameters` class is designed to configure and manage the parameters used for text-to-speech generation through the OpenAI API.

## Inherits

- [OpenAIParameters](OpenAIParameters.md)

## Properties

| Property Name     | Type    | Default Value | Description                                                                                      |
|-------------------|---------|---------------|--------------------------------------------------------------------------------------------------|
| `instructions`    | Text    |               | Additional instructions for the voice (only works with `gpt-4o-mini-tts` model). Max 500 characters. |
| `response_format` | Text    | `mp3`         | The audio format to generate: `mp3`, `opus`, `aac`, `flac`, `wav`, `pcm`.                        |
| `speed`           | Real    | 1.0           | The playback speed of the generated audio. Range: 0.25 to 4.0.                                   |
| `stream_format`   | Text    | `audio`       | The stream format for streaming responses: `sse` or `audio`.                                     |

### response_format

The following audio formats are supported:

| Format | Description                                                      |
|--------|------------------------------------------------------------------|
| `mp3`  | MPEG Audio Layer III - widely supported, good compression.      |
| `opus` | Opus codec - excellent for streaming and low latency.            |
| `aac`  | Advanced Audio Coding - good quality, widely supported.          |
| `flac` | Free Lossless Audio Codec - lossless compression.               |
| `wav`  | Waveform Audio - uncompressed, large file size.                  |
| `pcm`  | Pulse-Code Modulation - raw audio data, no headers.              |

### instructions

The `instructions` property allows you to provide additional guidance to the TTS model about how to deliver the speech. This feature is **only available with the `gpt-4o-mini-tts` model**.

Examples of instructions:
- "Speak in a cheerful and enthusiastic tone"
- "Use a calm and professional voice"
- "Speak slowly and clearly, as if teaching"

## Example

```4d
var $params:=cs.AIKit.OpenAIAudioSpeechParameters.new()
$params.response_format:="wav"
$params.speed:=0.9

var $result:=$client.audio.speech("Hello world"; "tts-1"; "alloy"; $params)
```

With instructions (gpt-4o-mini-tts):

```4d
var $params:=cs.AIKit.OpenAIAudioSpeechParameters.new({
    instructions: "Speak with excitement and energy";
    response_format: "mp3"
})

var $result:=$client.audio.speech("Great news everyone!"; "gpt-4o-mini-tts"; "coral"; $params)
```

## See also

- [OpenAIAudioAPI](OpenAIAudioAPI.md)
- [OpenAIAudioSpeechResult](OpenAIAudioSpeechResult.md)
