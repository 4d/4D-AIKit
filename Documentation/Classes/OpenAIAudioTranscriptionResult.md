# OpenAIAudioTranscriptionResult

The `OpenAIAudioTranscriptionResult` class handles the response from audio transcription (speech-to-text) requests.

## Inherits

- [OpenAIResult](OpenAIResult.md)

## Computed properties

| Property       | Type                                                     | Description                                                         |
|----------------|----------------------------------------------------------|---------------------------------------------------------------------|
| `transcription`| [OpenAIAudioTranscription](OpenAIAudioTranscription.md)  | Returns the transcription object with full details. `Null` if the request fails, or with the non-JSON formats (`text`, `srt`, `vtt`). |
| `text`         | Text                                                     | The transcribed text, whatever the `response_format`. Without the trailing line feeds for the non-JSON formats. Empty if the request fails. |
| `textContent`  | Text                                                     | Returns the raw text content for non-JSON formats (`text`, `srt`, `vtt`). |

### transcription

The `transcription` property returns an [OpenAIAudioTranscription](OpenAIAudioTranscription.md) object containing:

- `text` - The transcribed text
- `language` - The language of the audio (for `verbose_json`)
- `languages` - The detected languages (with `gpt-transcribe`)
- `duration` - The audio duration in seconds (for `verbose_json` and `diarized_json`)
- `segments` - Segments with timestamps (for `verbose_json`), and speaker (for `diarized_json`)
- `words` - Individual words with timestamps (for `verbose_json`)
- `logprobs` - The log probabilities of the tokens (with `logprobs` in `include`)

### textContent

Use `textContent` when you need the exact response body of non-JSON response formats like `text`, `srt`, or `vtt`.

## Example

Basic usage:

```4d
var $audioFile:=File("/RESOURCES/audio/speech.mp3")
var $result:=$client.audio.transcription($audioFile; "whisper-1")

If ($result.success)
    var $text:=$result.text
    ALERT($text)
End if
```

With verbose JSON format:

```4d
var $params:=cs.AIKit.OpenAIAudioTranscriptionParameters.new({response_format: "verbose_json"})
var $result:=$client.audio.transcription($audioFile; "whisper-1"; $params)

If ($result.success)
    var $transcription:=$result.transcription
    
    // Get duration
    var $duration:=$transcription.duration  // in seconds
    
    // Iterate over segments
    var $segment : Object
    For each ($segment; $transcription.segments)
        // $segment.start, $segment.end, $segment.text
    End for each
End if
```

Get SRT subtitles:

```4d
var $params:=cs.AIKit.OpenAIAudioTranscriptionParameters.new({response_format: "srt"})
var $result:=$client.audio.transcription($audioFile; "whisper-1"; $params)

If ($result.success)
    // Save to file
    Folder(fk desktop folder).file("subtitles.srt").setText($result.textContent)
End if
```

Get VTT subtitles:

```4d
var $params:=cs.AIKit.OpenAIAudioTranscriptionParameters.new({response_format: "vtt"})
var $result:=$client.audio.transcription($audioFile; "whisper-1"; $params)

var $vttContent:=$result.textContent
```

## See also

- [OpenAIAudioAPI](OpenAIAudioAPI.md)
- [OpenAIAudioTranscriptionParameters](OpenAIAudioTranscriptionParameters.md)
- [OpenAIAudioTranscription](OpenAIAudioTranscription.md)
