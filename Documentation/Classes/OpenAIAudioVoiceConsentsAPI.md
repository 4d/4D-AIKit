# OpenAIAudioVoiceConsentsAPI

The `OpenAIAudioVoiceConsentsAPI` manages the consent recordings. A consent recording is the audio of a person reading a consent phrase: it authorizes the creation of a [custom voice](OpenAIAudioVoicesAPI.md) from an audio sample of this person.

It is available with `$client.audio.voiceConsents`.

https://developers.openai.com/api/reference/resources/audio/subresources/voice_consents

> [!NOTE]
> Custom voices are limited to eligible OpenAI customers: otherwise the server answers "Endpoint not found". The phrase to read for each language is in the [custom voices guide](https://developers.openai.com/api/docs/guides/custom-voices).

## Functions

### create()

**create**(*name* : Text; *language* : Text; *recording* : 4D.File or 4D.Blob; *parameters* : OpenAIParameters) : OpenAIAudioVoiceConsentResult

Uploads a consent recording.

| Parameter       | Type                                                              | Description |
|-----------------|-------------------------------------------------------------------|-------------|
| *name*          | Text                                                              | The label of the consent recording. |
| *language*      | Text                                                              | The BCP 47 language tag of the consent phrase, ie. `en-US`. |
| *recording*     | 4D.File or 4D.Blob                                                | The audio of the consent phrase. OpenAI accepts up to 10 MiB, in `mp3`, `wav`, `ogg`, `aac`, `flac`, `webm` or `mp4` format. |
| *parameters*    | [OpenAIParameters](OpenAIParameters.md)                           | Optional parameters. `filename` gives the file name of a blob, otherwise it is deduced from the signature of the content. |
| Function result | [OpenAIAudioVoiceConsentResult](OpenAIAudioVoiceConsentResult.md) | The result containing the consent recording. |

An error is thrown if *name* or *language* is empty, or if *recording* is not a file or a blob.

```4d
var $result:=$client.audio.voiceConsents.create("John Doe"; "en-US"; File("/RESOURCES/audio/consent.wav"))
If ($result.success)
    var $consentId:=$result.consent.id  // cons_1234
End if
```

### list()

**list**(*parameters* : OpenAIAudioVoiceConsentListParameters) : OpenAIAudioVoiceConsentListResult

Returns the consent recordings of the organization.

| Parameter       | Type                                                                              | Description |
|-----------------|-----------------------------------------------------------------------------------|-------------|
| *parameters*    | [OpenAIAudioVoiceConsentListParameters](OpenAIAudioVoiceConsentListParameters.md) | Optional parameters for pagination: `after`, `limit`. |
| Function result | [OpenAIAudioVoiceConsentListResult](OpenAIAudioVoiceConsentListResult.md)         | The result containing the consent recordings. |

```4d
var $params:=cs.AIKit.OpenAIAudioVoiceConsentListParameters.new({limit: 100})
var $result:=$client.audio.voiceConsents.list($params)
var $consents:=$result.consents

While ($result.has_more)
    $params.after:=$result.last_id
    $result:=$client.audio.voiceConsents.list($params)
    $consents:=$consents.concat($result.consents)
End while
```

### retrieve()

**retrieve**(*consentId* : Text; *parameters* : OpenAIParameters) : OpenAIAudioVoiceConsentResult

Returns a consent recording.

### update()

**update**(*consentId* : Text; *name* : Text; *parameters* : OpenAIParameters) : OpenAIAudioVoiceConsentResult

Renames a consent recording. The recording itself could not be changed.

```4d
var $result:=$client.audio.voiceConsents.update("cons_1234"; "John Doe (2026)")
```

### delete()

**delete**(*consentId* : Text; *parameters* : OpenAIParameters) : OpenAIAudioVoiceDeletedResult

Deletes a consent recording. See [OpenAIAudioVoiceDeletedResult](OpenAIAudioVoiceDeletedResult.md).

```4d
var $result:=$client.audio.voiceConsents.delete("cons_1234")
```

An error is thrown by `retrieve()`, `update()` and `delete()` if *consentId* is empty, and by `update()` if *name* is empty.

## See also

- [OpenAIAudioVoicesAPI](OpenAIAudioVoicesAPI.md)
- [OpenAIAudioVoiceConsent](OpenAIAudioVoiceConsent.md)
