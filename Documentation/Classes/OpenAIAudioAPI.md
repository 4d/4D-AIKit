# OpenAIAudioAPI

The `OpenAIAudioAPI` provides functionalities for audio processing using OpenAI's API, including text-to-speech generation, speech-to-text transcription, and audio translation.

https://platform.openai.com/docs/api-reference/audio

## Functions

### speech()

**speech**(*input* : Text; *model* : Text; *voice* : Text; *parameters* : OpenAIAudioSpeechParameters) : OpenAIAudioSpeechResult

Generates audio from input text (text-to-speech).

| Parameter      | Type                                                     | Description                                                        |
|----------------|----------------------------------------------------------|--------------------------------------------------------------------|
| *input*        | Text                                                     | The text to generate audio for (required, max 4096 characters).    |
| *model*        | Text                                                     | The TTS model: `tts-1`, `tts-1-hd`, or `gpt-4o-mini-tts`.          |
| *voice*        | Text                                                     | The voice to use (see available voices below).                     |
| *parameters*   | [OpenAIAudioSpeechParameters](OpenAIAudioSpeechParameters.md) | Optional parameters for speech generation.                    |
| Function result| [OpenAIAudioSpeechResult](OpenAIAudioSpeechResult.md)    | The result containing the generated audio.                         |

#### Available Voices

`alloy`, `ash`, `ballad`, `coral`, `echo`, `fable`, `onyx`, `nova`, `sage`, `shimmer`, `verse`

https://platform.openai.com/docs/api-reference/audio/createSpeech

#### Example

```4d
var $result:=$client.audio.speech("Hello, welcome to 4D AIKit!"; "tts-1"; "alloy")

If ($result.success)
    $result.saveAudioToDisk(Folder(fk desktop folder).file("welcome.mp3"))
End if
```

With parameters:

```4d
var $params:=cs.AIKit.OpenAIAudioSpeechParameters.new({response_format: "wav"; speed: 1.2})
var $result:=$client.audio.speech("Fast speech in WAV format"; "tts-1-hd"; "nova"; $params)
```

Using instructions (gpt-4o-mini-tts only):

```4d
var $params:=cs.AIKit.OpenAIAudioSpeechParameters.new({instructions: "Speak in a cheerful and enthusiastic tone"})
var $result:=$client.audio.speech("Welcome to our podcast!"; "gpt-4o-mini-tts"; "coral"; $params)
```

---

### transcription()

**transcription**(*file* : 4D.File or 4D.Blob; *model* : Text; *parameters* : OpenAIAudioTranscriptionParameters) : OpenAIAudioTranscriptionResult

Transcribes audio into the input language (speech-to-text).

| Parameter      | Type                                                               | Description                                           |
|----------------|--------------------------------------------------------------------|-------------------------------------------------------|
| *file*         | 4D.File or 4D.Blob                                                 | The audio file to transcribe.                         |
| *model*        | Text                                                               | The transcription model (see available models below). |
| *parameters*   | [OpenAIAudioTranscriptionParameters](OpenAIAudioTranscriptionParameters.md) | Optional parameters for transcription.       |
| Function result| [OpenAIAudioTranscriptionResult](OpenAIAudioTranscriptionResult.md) | The result containing the transcription.             |

#### Available Models

- `whisper-1` - Standard transcription model
- `gpt-4o-transcribe` - Advanced transcription with GPT-4o
- `gpt-4o-mini-transcribe` - Faster transcription with GPT-4o mini
- `gpt-4o-transcribe-diarize` - Transcription with speaker diarization

https://platform.openai.com/docs/api-reference/audio/createTranscription

#### Example

```4d
var $audioFile:=File("/RESOURCES/audio/meeting.mp3")
var $result:=$client.audio.transcription($audioFile; "whisper-1")

If ($result.success)
    var $text:=$result.text
End if
```

With language hint:

```4d
var $params:=cs.AIKit.OpenAIAudioTranscriptionParameters.new({language: "fr"})
var $result:=$client.audio.transcription($audioFile; "whisper-1"; $params)
```

Get verbose JSON with timestamps:

```4d
var $params:=cs.AIKit.OpenAIAudioTranscriptionParameters.new({response_format: "verbose_json"})
var $result:=$client.audio.transcription($audioFile; "whisper-1"; $params)

var $transcription:=$result.transcription
// Access segments and words with timestamps
var $segments:=$transcription.segments
var $duration:=$transcription.duration
```

---

### translation()

**translation**(*file* : 4D.File or 4D.Blob; *model* : Text; *parameters* : OpenAIAudioTranslationParameters) : OpenAIAudioTranslationResult

Translates audio into English.

| Parameter      | Type                                                             | Description                                         |
|----------------|------------------------------------------------------------------|-----------------------------------------------------|
| *file*         | 4D.File or 4D.Blob                                               | The audio file to translate.                        |
| *model*        | Text                                                             | The translation model (currently only `whisper-1`). |
| *parameters*   | [OpenAIAudioTranslationParameters](OpenAIAudioTranslationParameters.md) | Optional parameters for translation.         |
| Function result| [OpenAIAudioTranslationResult](OpenAIAudioTranslationResult.md)  | The result containing the English translation.      |

https://platform.openai.com/docs/api-reference/audio/createTranslation

#### Example

```4d
var $frenchAudio:=File("/RESOURCES/audio/french_speech.mp3")
var $result:=$client.audio.translation($frenchAudio; "whisper-1")

If ($result.success)
    var $englishText:=$result.text
End if
```

With a prompt to guide style:

```4d
var $params:=cs.AIKit.OpenAIAudioTranslationParameters.new({prompt: "This is a formal business meeting"})
var $result:=$client.audio.translation($audioFile; "whisper-1"; $params)
```

## See also

- [OpenAIAudioSpeechParameters](OpenAIAudioSpeechParameters.md)
- [OpenAIAudioSpeechResult](OpenAIAudioSpeechResult.md)
- [OpenAIAudioTranscriptionParameters](OpenAIAudioTranscriptionParameters.md)
- [OpenAIAudioTranscriptionResult](OpenAIAudioTranscriptionResult.md)
- [OpenAIAudioTranslationParameters](OpenAIAudioTranslationParameters.md)
- [OpenAIAudioTranslationResult](OpenAIAudioTranslationResult.md)
- [OpenAIAudioTranscription](OpenAIAudioTranscription.md)
