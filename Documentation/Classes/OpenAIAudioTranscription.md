# OpenAIAudioTranscription

The `OpenAIAudioTranscription` class represents an audio transcription response object.

## Properties

| Property     | Type       | Description                                                              |
|--------------|------------|--------------------------------------------------------------------------|
| `text`       | Text       | The transcribed text.                                      |
| `task`       | Text       | The type of operation, ie. `"transcribe"` (for `verbose_json` and `diarized_json`). |
| `language`   | Text       | The language of the input audio (for `verbose_json`).                    |
| `languages`  | Collection | The languages detected in the audio, as objects with a `code` (with `gpt-transcribe`). |
| `duration`   | Real       | The duration of the input audio in seconds (for `verbose_json` and `diarized_json`). |
| `segments`   | Collection | Segments of the transcription with timestamps (for `verbose_json` and `diarized_json`). |
| `words`      | Collection | Individual words with timestamps (for `verbose_json`, with `word` in `timestamp_granularities`). |
| `logprobs`   | Collection | The log probabilities of the tokens (with `logprobs` in `include`).      |
| `usage`      | Object     | Usage information, with token counts or duration.                        |

### segments

When using `verbose_json` or `diarized_json` response format, the `segments` collection contains objects with:

| Field     | Type   | Description                              |
|-----------|--------|------------------------------------------|
| `id`      | Integer or Text | Segment identifier.             |
| `start`   | Real   | Start time in seconds.                   |
| `end`     | Real   | End time in seconds.                     |
| `text`    | Text   | The transcribed text for this segment.   |
| `speaker` | Text   | The speaker label (for `diarized_json`). |

### words

When using `verbose_json` response format with `word` in `timestamp_granularities`, the `words` collection contains objects with:

| Field   | Type   | Description                              |
|---------|--------|------------------------------------------|
| `word`  | Text   | The transcribed word.                    |
| `start` | Real   | Start time in seconds.                   |
| `end`   | Real   | End time in seconds.                     |

## Example

Accessing transcription details:

```4d
var $result:=$client.audio.transcription($audioFile; "whisper-1"; {response_format: "verbose_json"; timestamp_granularities: ["word"; "segment"]})

If ($result.success)
    var $transcription:=$result.transcription
    
    // Basic info
    var $fullText:=$transcription.text
    var $lang:=$transcription.language  // e.g., "english"
    var $duration:=$transcription.duration  // e.g., 45.5 (seconds)
    
    // Process segments
    var $segment : Object
    For each ($segment; $transcription.segments)
        var $startTime:=$segment.start
        var $endTime:=$segment.end
        var $segmentText:=$segment.text
    End for each
    
    // Process words
    var $word : Object
    For each ($word; $transcription.words)
        var $wordText:=$word.word
        var $wordStart:=$word.start
        var $wordEnd:=$word.end
    End for each
End if
```

Speaker of each segment:

```4d
var $result:=$client.audio.transcription($audioFile; "gpt-4o-transcribe-diarize"; {response_format: "diarized_json"; chunking_strategy: "auto"})

If ($result.success)
    var $segment : Object
    For each ($segment; $result.transcription.segments)
        // $segment.speaker, $segment.text
    End for each
End if
```

## See also

- [OpenAIAudioAPI](OpenAIAudioAPI.md)
- [OpenAIAudioTranscriptionResult](OpenAIAudioTranscriptionResult.md)
