# OpenAIAudioSpeechParameters

The `OpenAIAudioSpeechParameters` class is designed to configure and manage the parameters used for text-to-speech generation through the OpenAI API.

## Inherits

- [OpenAIParameters](OpenAIParameters.md)

## Properties

| Property Name     | Type    | Default Value | Description                                                                                      |
|-------------------|---------|---------------|--------------------------------------------------------------------------------------------------|
| `instructions`    | Text    |               | Additional instructions for the voice. Does not work with `tts-1` and `tts-1-hd`. OpenAI accepts up to 4096 characters. |
| `response_format` | Text    | `mp3`         | The audio format to generate: `mp3`, `opus`, `aac`, `flac`, `wav`, `pcm`.                        |
| `speed`           | Real    | 1.0           | The speed of the generated audio. OpenAI accepts from 0.25 to 4.0.                               |
| `stream_format`   | Text    | `audio`       | The stream format: `audio` or `sse`. With `sse`, the response is a text of events, not an audio: `asBlob()` returns `Null`. |

### response_format

The following audio formats are supported by OpenAI. The values are not checked before sending: a compatible server could support other ones, or only some of them (ie. Ollama only supports `wav` and `pcm`, and has `wav` as default).

| Format | Description                                                      |
|--------|------------------------------------------------------------------|
| `mp3`  | MPEG Audio Layer III - widely supported, good compression.      |
| `opus` | Opus codec - excellent for streaming and low latency.            |
| `aac`  | Advanced Audio Coding - good quality, widely supported.          |
| `flac` | Free Lossless Audio Codec - lossless compression.               |
| `wav`  | Waveform Audio - uncompressed, large file size.                  |
| `pcm`  | Pulse-Code Modulation - raw audio data, no headers.              |

### instructions

The `instructions` property allows you to provide additional guidance to the TTS model about how to deliver the speech. This feature is **not available with the `tts-1` and `tts-1-hd` models**.

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
