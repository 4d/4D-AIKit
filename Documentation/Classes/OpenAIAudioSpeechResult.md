# OpenAIAudioSpeechResult

The `OpenAIAudioSpeechResult` class handles the response from text-to-speech generation requests.

## Inherits

- [OpenAIResult](OpenAIResult.md)

## Computed properties

| Property   | Type   | Description                                                  |
|------------|--------|--------------------------------------------------------------|
| `mimeType` | Text   | Returns the MIME type of the audio content from response headers. |

## Functions

### asBlob()

**asBlob**() : 4D.Blob

Returns the generated audio as a blob.

| Parameter      | Type     | Description                    |
|----------------|----------|--------------------------------|
| Function result| 4D.Blob  | The audio data as a blob.      |

#### Example

```4d
var $result:=$client.audio.speech("Hello world"; "tts-1"; "alloy")

var $blob:=$result.asBlob()
```

---

### saveAudioToDisk()

**saveAudioToDisk**(*file* : 4D.File) : Boolean

Saves the generated audio to disk.

| Parameter      | Type      | Description                                    |
|----------------|-----------|------------------------------------------------|
| *file*         | 4D.File   | The file where the audio will be saved.        |
| Function result| Boolean   | Returns `True` if the audio is successfully saved. |

#### Example

```4d
var $result:=$client.audio.speech("Welcome to our application"; "tts-1-hd"; "nova")

If ($result.success)
    var $saved:=$result.saveAudioToDisk(Folder(fk desktop folder).file("welcome.mp3"))
    If ($saved)
        ALERT("Audio saved successfully!")
    End if
End if
```

With custom format:

```4d
var $params:=cs.AIKit.OpenAIAudioSpeechParameters.new({response_format: "wav"})
var $result:=$client.audio.speech("Test audio"; "tts-1"; "echo"; $params)

$result.saveAudioToDisk(Folder(fk desktop folder).file("test.wav"))
```

## See also

- [OpenAIAudioAPI](OpenAIAudioAPI.md)
- [OpenAIAudioSpeechParameters](OpenAIAudioSpeechParameters.md)
