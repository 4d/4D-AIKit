# OpenAIAudioTranslationResult

The `OpenAIAudioTranslationResult` class handles the response from audio translation (to English) requests.

## Inherits

- [OpenAIResult](OpenAIResult.md)

## Computed properties

| Property     | Type                                                     | Description                                                         |
|--------------|----------------------------------------------------------|---------------------------------------------------------------------|
| `translation`| [OpenAIAudioTranscription](OpenAIAudioTranscription.md)  | Returns the translation object with full details.                   |
| `text`       | Text                                                     | Convenience getter for the translated text.                         |
| `textContent`| Text                                                     | Returns raw text content for non-JSON formats (`text`, `srt`, `vtt`). |

> **Important:** The property to use depends on the `response_format` parameter:
> - For `json` or `verbose_json` formats → use `text` or `translation`
> - For `text`, `srt`, or `vtt` formats → use `textContent`

### translation

The `translation` property returns an [OpenAIAudioTranscription](OpenAIAudioTranscription.md) object containing:

- `text` - The translated English text
- `language` - The detected source language
- `duration` - The audio duration in seconds
- `segments` - Segments with timestamps (for `verbose_json`)
- `words` - Individual words with timestamps (for `verbose_json`)

### textContent

Use `textContent` when you request non-JSON response formats like `text`, `srt`, or `vtt`. This returns the raw text content from the response body.

## Example

Basic usage:

```4d
var $audioFile:=File("/RESOURCES/audio/spanish_speech.mp3")
var $result:=$client.audio.translation($audioFile; "whisper-1")

If ($result.success)
    var $englishText:=$result.text
    ALERT($englishText)
End if
```

With verbose JSON format:

```4d
var $params:=cs.AIKit.OpenAIAudioTranslationParameters.new({response_format: "verbose_json"})
var $result:=$client.audio.translation($audioFile; "whisper-1"; $params)

If ($result.success)
    var $translation:=$result.translation
    
    // Get source language (detected)
    var $sourceLanguage:=$translation.language  // e.g., "es" for Spanish
    
    // Get duration
    var $duration:=$translation.duration
    
    // Iterate over segments
    var $segment : Object
    For each ($segment; $translation.segments)
        // $segment.start, $segment.end, $segment.text (in English)
    End for each
End if
```

Generate VTT subtitles in English:

```4d
var $params:=cs.AIKit.OpenAIAudioTranslationParameters.new({response_format: "vtt"})
var $result:=$client.audio.translation($foreignAudio; "whisper-1"; $params)

If ($result.success)
    var $vttContent:=$result.textContent
    // Save to file
    File(Folder(fk desktop folder).file("english_subtitles.vtt")).setText($vttContent)
End if
```

## See also

- [OpenAIAudioAPI](OpenAIAudioAPI.md)
- [OpenAIAudioTranslationParameters](OpenAIAudioTranslationParameters.md)
- [OpenAIAudioTranscription](OpenAIAudioTranscription.md)
