# OpenAIAudioAPI

The `OpenAIAudioAPI` provides functionalities for audio processing using OpenAI's API, including text-to-speech generation and speech-to-text transcription.

https://developers.openai.com/api/reference/resources/audio

> [!WARNING]
> OpenAI has announced the shutdown of these models:
>
> | Shutdown date | Deprecated | OpenAI replacement |
> |---------------|------------|--------------------|
> | January 6, 2027 | `tts-1`, `tts-1-hd`, `gpt-4o-mini-tts` | `gpt-realtime-2.1-mini`, through the Realtime API (not available with `speech()`) |
> | February 26, 2027 | `whisper-1`, `gpt-4o-transcribe`, `gpt-4o-mini-transcribe`, `gpt-4o-transcribe-diarize` | `gpt-transcribe`, or `gpt-live-transcribe` through the Realtime API |
>
> The Realtime API is not available in this component. See the [deprecations page](https://developers.openai.com/api/docs/deprecations).
> These dates only concern OpenAI: the same functions keep working with a [local server](#local-servers).

## Functions

### speech()

**speech**(*input* : Text; *model* : Text; *voice* : Text or Object; *parameters* : OpenAIAudioSpeechParameters) : OpenAIAudioSpeechResult

Generates audio from input text (text-to-speech).

| Parameter      | Type                                                     | Description                                                        |
|----------------|----------------------------------------------------------|--------------------------------------------------------------------|
| *input*        | Text                                                     | The text to generate audio for. OpenAI accepts up to 4096 characters. |
| *model*        | Text                                                     | The TTS model, ie. `gpt-4o-mini-tts`, `tts-1` or `tts-1-hd`.       |
| *voice*        | Text or Object                                           | The name of the voice, or a custom voice as `{id: "voice_1234"}`.  |
| *parameters*   | [OpenAIAudioSpeechParameters](OpenAIAudioSpeechParameters.md) | Optional parameters for speech generation.                    |
| Function result| [OpenAIAudioSpeechResult](OpenAIAudioSpeechResult.md)    | The result containing the generated audio.                         |

An error is thrown if *input*, *model* or *voice* is empty. The other limits are checked by the server, which then returns an [error](OpenAIError.md) in the result: they depend on the model and on the server.

#### Available Voices

`alloy`, `ash`, `ballad`, `cedar`, `coral`, `echo`, `fable`, `marin`, `nova`, `onyx`, `sage`, `shimmer`, `verse`

https://developers.openai.com/api/reference/resources/audio/subresources/speech/methods/create

#### Example

```4d
var $result:=$client.audio.speech("Hello, welcome to 4D AIKit!"; "gpt-4o-mini-tts"; "alloy")

If ($result.success)
    $result.saveAudioToDisk(Folder(fk desktop folder).file("welcome.mp3"))
End if
```

With parameters:

```4d
var $params:=cs.AIKit.OpenAIAudioSpeechParameters.new({response_format: "wav"; speed: 1.2})
var $result:=$client.audio.speech("Fast speech in WAV format"; "tts-1-hd"; "nova"; $params)
```

Using instructions (not available with `tts-1` and `tts-1-hd`):

```4d
var $params:=cs.AIKit.OpenAIAudioSpeechParameters.new({instructions: "Speak in a cheerful and enthusiastic tone"})
var $result:=$client.audio.speech("Welcome to our podcast!"; "gpt-4o-mini-tts"; "coral"; $params)
```

Using a [custom voice](https://developers.openai.com/api/docs/guides/custom-voices) that you already created:

```4d
var $result:=$client.audio.speech("Hello"; "gpt-4o-mini-tts"; {id: "voice_1234"})
```

---

### transcription()

**transcription**(*file* : 4D.File or 4D.Blob; *model* : Text; *parameters* : OpenAIAudioTranscriptionParameters) : OpenAIAudioTranscriptionResult

Transcribes audio into the input language (speech-to-text).

| Parameter      | Type                                                               | Description                                           |
|----------------|--------------------------------------------------------------------|-------------------------------------------------------|
| *file*         | 4D.File or 4D.Blob                                                 | The audio file to transcribe. OpenAI accepts files up to 25 MB, in `flac`, `mp3`, `mp4`, `mpeg`, `mpga`, `m4a`, `ogg`, `wav` or `webm` format. |
| *model*        | Text                                                               | The transcription model (see available models below). |
| *parameters*   | [OpenAIAudioTranscriptionParameters](OpenAIAudioTranscriptionParameters.md) | Optional parameters for transcription.       |
| Function result| [OpenAIAudioTranscriptionResult](OpenAIAudioTranscriptionResult.md) | The result containing the transcription.             |

An error is thrown if *file* is not a file or a blob, or if *model* is empty.

The server identifies the format of the audio with the extension of the file name. With a blob you could provide it with the `filename` parameter, otherwise it is deduced from the signature of the content.

#### Available Models

| Model                       | Description                                                       |
|-----------------------------|-------------------------------------------------------------------|
| `gpt-transcribe`            | Recommended by OpenAI. Supports `keywords` and `languages`. Only `json` and `text` formats. |
| `gpt-4o-transcribe`         | Transcription with GPT-4o. Supports `logprobs`. Only `json` format. |
| `gpt-4o-mini-transcribe`    | Faster transcription with GPT-4o mini. Supports `logprobs`. Only `json` format. |
| `gpt-4o-transcribe-diarize` | Transcription with speaker labels, using the `diarized_json` format. |
| `whisper-1`                 | Whisper V2. All text formats and timestamps, but no streaming.    |

https://developers.openai.com/api/reference/resources/audio/subresources/transcriptions/methods/create

#### Example

```4d
var $audioFile:=File("/RESOURCES/audio/meeting.mp3")
var $result:=$client.audio.transcription($audioFile; "gpt-transcribe")

If ($result.success)
    var $text:=$result.text
End if
```

With language hint:

```4d
var $params:=cs.AIKit.OpenAIAudioTranscriptionParameters.new({language: "fr"})
var $result:=$client.audio.transcription($audioFile; "gpt-transcribe"; $params)
```

With words to expect:

```4d
var $params:=cs.AIKit.OpenAIAudioTranscriptionParameters.new({keywords: ["4D"; "AIKit"]; languages: ["en"; "fr"]})
var $result:=$client.audio.transcription($audioFile; "gpt-transcribe"; $params)
```

Get verbose JSON with timestamps of words and segments:

```4d
var $params:=cs.AIKit.OpenAIAudioTranscriptionParameters.new({response_format: "verbose_json"; timestamp_granularities: ["word"; "segment"]})
var $result:=$client.audio.transcription($audioFile; "whisper-1"; $params)

var $transcription:=$result.transcription
var $words:=$transcription.words
var $segments:=$transcription.segments
var $duration:=$transcription.duration
```

Transcribe a blob:

```4d
var $result:=$client.audio.transcription($audioBlob; "gpt-transcribe"; {filename: "meeting.m4a"})
```

Stream the text while it is transcribed (see [asynchronous call](../asynchronous-call.md)):

```4d
$client.audio.transcription($audioFile; "gpt-transcribe"; {stream: True; \
    onData: Formula(MyDelta($1)); \
    onTerminate: Formula(MyEnd($1))})
```

The callbacks receive an [OpenAIChatCompletionsStreamResult](OpenAIChatCompletionsStreamResult.md), with the event in its `data` property:

```4d
// MyDelta
#DECLARE($result : cs.AIKit.OpenAIChatCompletionsStreamResult)
If (String($result.data.type)="transcript.text.delta")
    Form.text+=String($result.data.delta)
End if
```

```4d
// MyEnd: `data` is the last event, with the full text
#DECLARE($result : cs.AIKit.OpenAIChatCompletionsStreamResult)
If ($result.success)
    Form.text:=String($result.data.text)
End if
```

> [!NOTE]
> A server that ignores `stream`, like `whisper-1` or whisper.cpp, calls `onTerminate` only: still read the text from `$result.data.text`.

## Local servers

Set the `baseURL` of the client, or use the [provider and model aliases](../provider-model-aliases.md), to use another server. Tested with:

| Server | baseURL | `transcription()` | `speech()` |
|--------|---------|-------------------|------------|
| [Ollama](https://docs.ollama.com/api/openai-compatibility) | http://127.0.0.1:11434/v1 | ✅ | ✅ |
| [whisper.cpp](https://github.com/ggml-org/whisper.cpp/tree/master/examples/server) | http://127.0.0.1:8080/v1 | ✅ | ❌ |

Start `whisper-server` with `--inference-path /v1/audio/transcriptions`, otherwise this URL returns a 404.

```4d
var $client:=cs.AIKit.OpenAI.new({baseURL: "http://127.0.0.1:11434/v1"})  // ollama
var $result:=$client.audio.speech("Hello"; "phonon"; "Zoey"; {response_format: "wav"})
```

## See also

- [OpenAIAudioSpeechParameters](OpenAIAudioSpeechParameters.md)
- [OpenAIAudioSpeechResult](OpenAIAudioSpeechResult.md)
- [OpenAIAudioTranscriptionParameters](OpenAIAudioTranscriptionParameters.md)
- [OpenAIAudioTranscriptionResult](OpenAIAudioTranscriptionResult.md)
- [OpenAIAudioTranscription](OpenAIAudioTranscription.md)
