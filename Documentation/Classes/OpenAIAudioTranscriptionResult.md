# OpenAIAudioTranscriptionResult

The `OpenAIAudioTranscriptionResult` class handles the response from audio transcription (speech-to-text) requests.

## Inherits

- [OpenAIResult](OpenAIResult.md)

## Computed properties

| Property       | Type                                                     | Description                                                         |
|----------------|----------------------------------------------------------|---------------------------------------------------------------------|
| `transcription`| [OpenAIAudioTranscription](OpenAIAudioTranscription.md)  | Returns the transcription object with full details.                 |
| `text`         | Text                                                     | Convenience getter for the transcribed text.                        |
| `textContent`  | Text                                                     | Returns raw text content for non-JSON formats (`text`, `srt`, `vtt`). |

> **Important:** The property to use depends on the `response_format` parameter:
> - For `json` or `verbose_json` formats → use `text` or `transcription`
> - For `text`, `srt`, or `vtt` formats → use `textContent`

### transcription

The `transcription` property returns an [OpenAIAudioTranscription](OpenAIAudioTranscription.md) object containing:

- `text` - The transcribed text
- `language` - The detected or specified language
- `duration` - The audio duration in seconds
- `segments` - Segments with timestamps (for `verbose_json`)
- `words` - Individual words with timestamps (for `verbose_json`)
- `diarization` - Speaker information (for `diarized_json`)

### textContent

Use `textContent` when you request non-JSON response formats like `text`, `srt`, or `vtt`. This returns the raw text content from the response body.

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
    var $srtContent:=$result.textContent
    // Save to file
    File(Folder(fk desktop folder).file("subtitles.srt")).setText($srtContent)
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
