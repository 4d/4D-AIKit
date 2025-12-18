# OpenAIAudioTranscription

The `OpenAIAudioTranscription` class represents an audio transcription or translation response object.

## Properties

| Property     | Type       | Description                                                              |
|--------------|------------|--------------------------------------------------------------------------|
| `text`       | Text       | The transcribed or translated text.                                      |
| `task`       | Text       | The type of operation: `"transcribe"` or `"translate"`.                  |
| `language`   | Text       | The language of the input audio in ISO-639-1 format.                     |
| `duration`   | Real       | The duration of the input audio in seconds.                              |
| `segments`   | Collection | Segments of the transcription with timestamps (for `verbose_json`).      |
| `words`      | Collection | Individual words with timestamps (for `verbose_json`).                   |
| `diarization`| Object     | Speaker diarization information (for `diarized_json`).                   |
| `usage`      | Object     | Usage information with token counts.                                     |

### segments

When using `verbose_json` response format, the `segments` collection contains objects with:

| Field   | Type   | Description                              |
|---------|--------|------------------------------------------|
| `id`    | Integer| Segment identifier.                      |
| `start` | Real   | Start time in seconds.                   |
| `end`   | Real   | End time in seconds.                     |
| `text`  | Text   | The transcribed text for this segment.   |

### words

When using `verbose_json` response format, the `words` collection contains objects with:

| Field   | Type   | Description                              |
|---------|--------|------------------------------------------|
| `word`  | Text   | The transcribed word.                    |
| `start` | Real   | Start time in seconds.                   |
| `end`   | Real   | End time in seconds.                     |

### diarization

When using the `gpt-4o-transcribe-diarize` model with `diarized_json` format, the `diarization` object contains speaker information.

## Example

Accessing transcription details:

```4d
var $result:=$client.audio.transcription($audioFile; "whisper-1"; {response_format: "verbose_json"})

If ($result.success)
    var $transcription:=$result.transcription
    
    // Basic info
    var $fullText:=$transcription.text
    var $lang:=$transcription.language  // e.g., "en"
    var $duration:=$transcription.duration  // e.g., 45.5 (seconds)
    
    // Process segments
    var $segment : Object
    For each ($segment; $transcription.segments)
        var $startTime:=$segment.start
        var $endTime:=$segment.end
        var $segmentText:=$segment.text
    End for each
    
    // Process words (if available)
    var $word : Object
    For each ($word; $transcription.words)
        var $wordText:=$word.word
        var $wordStart:=$word.start
        var $wordEnd:=$word.end
    End for each
End if
```

## See also

- [OpenAIAudioAPI](OpenAIAudioAPI.md)
- [OpenAIAudioTranscriptionResult](OpenAIAudioTranscriptionResult.md)
- [OpenAIAudioTranslationResult](OpenAIAudioTranslationResult.md)
