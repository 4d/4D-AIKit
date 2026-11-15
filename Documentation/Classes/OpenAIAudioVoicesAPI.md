# OpenAIAudioVoicesAPI

The `OpenAIAudioVoicesAPI` manages the text-to-speech voices: create or delete a custom voice, and list the voices to use with [speech()](OpenAIAudioAPI.md#speech).

It is available with `$client.audio.voices`.

https://developers.openai.com/api/reference/resources/audio/subresources/voices

> [!NOTE]
> With OpenAI, a voice created from an audio sample is limited to eligible customers, and requires a [consent recording](OpenAIAudioVoiceConsentsAPI.md). A voice created from a prompt works only with GPT-Live, not with `speech()`.

## Properties

| Property | Type       | Description |
|----------|------------|-------------|
| `custom` | Collection | The custom voices known by this client, as [OpenAIAudioVoice](OpenAIAudioVoice.md). See [custom voices](#custom-voices). |

## Functions

### create()

**create**(*name* : Text; *parameters* : OpenAIAudioVoiceParameters) : OpenAIAudioVoiceResult

Creates a custom voice, from an audio sample with its consent recording, or from a prompt.

| Parameter       | Type                                                        | Description |
|-----------------|-------------------------------------------------------------|-------------|
| *name*          | Text                                                        | The name of the voice. |
| *parameters*    | [OpenAIAudioVoiceParameters](OpenAIAudioVoiceParameters.md) | `audio_sample` and `consent`, or `prompt`. |
| Function result | [OpenAIAudioVoiceResult](OpenAIAudioVoiceResult.md)         | The result containing the voice. |

An error is thrown if *name* is empty, or without valid `audio_sample` or `prompt`.

If success, the voice is added to the [custom voices](#custom-voices) of the client. With an [asynchronous call](../asynchronous-call.md), do it in your callback with `add()`.

```4d
// a consent recording, then the voice
var $consent:=$client.audio.voiceConsents.create("John Doe"; "en-US"; File("/RESOURCES/audio/consent.wav")).consent

var $result:=$client.audio.voices.create("John"; {audio_sample: File("/RESOURCES/audio/sample.wav"); consent: $consent.id})
If ($result.success)
    var $speech:=$client.audio.speech("Hello"; "gpt-4o-mini-tts"; $result.voice.reference)  // {id: "voice_1234"}
End if
```

From a prompt:

```4d
var $result:=$client.audio.voices.create("Warm narrator"; {prompt: "A warm, calm narrator with a low voice"})
```

### delete()

**delete**(*voiceId* : Text; *parameters* : OpenAIParameters) : OpenAIAudioVoiceDeletedResult

Deletes a custom voice. Its consent recording is not deleted.

| Parameter       | Type                                                              | Description |
|-----------------|-------------------------------------------------------------------|-------------|
| *voiceId*       | Text                                                              | The ID of the voice to delete. |
| *parameters*    | [OpenAIParameters](OpenAIParameters.md)                           | Optional parameters for the request. |
| Function result | [OpenAIAudioVoiceDeletedResult](OpenAIAudioVoiceDeletedResult.md) | The result containing the deletion status. |

If success, the voice is removed from the custom voices of the client.

```4d
var $result:=$client.audio.voices.delete("voice_1234")
If ($result.success)
    // $result.deleted.deleted -> True
End if
```

### list()

**list**(*parameters* : OpenAIAudioVoiceListParameters) : OpenAIAudioVoiceListResult

Lists the voices to use with `speech()`.

| Parameter       | Type                                                                | Description |
|-----------------|---------------------------------------------------------------------|-------------|
| *parameters*    | [OpenAIAudioVoiceListParameters](OpenAIAudioVoiceListParameters.md) | Optional parameters: `path`, `model`, `query`, `custom`. |
| Function result | [OpenAIAudioVoiceListResult](OpenAIAudioVoiceListResult.md)         | The result containing the voices. |

What is done depends on the `baseURL` of the client:

- OpenAI has no endpoint to list voices. The result is its well-known voices, followed by the [custom voices](#custom-voices) of the client. No request is sent: the result is a success, without `request`. It is the same for Azure OpenAI and Groq.
- Otherwise the server is requested, and its response decoded whatever its format: the `id` and the `name` of each [OpenAIAudioVoice](OpenAIAudioVoice.md) are always filled.

See [Listing voices](../audio-voices.md) for the servers.

```4d
var $voices:=$client.audio.voices.list().voices

var $voice : cs.AIKit.OpenAIAudioVoice
For each ($voice; $voices)
    // $voice.id -> "alloy", $voice.name -> "Alloy"
End for each

var $result:=$client.audio.speech("Hello"; "gpt-4o-mini-tts"; $voices[0].reference)
```

Only the voices of a model:

```4d
var $voices:=$client.audio.voices.list({model: "tts-1"}).voices  // 9 voices, instead of 13
```

Another server, with its own endpoint:

```4d
var $client:=cs.AIKit.OpenAI.new({apiKey: $key; baseURL: "https://api.x.ai/v1"})
var $voices:=$client.audio.voices.list().voices  // GET /tts/voices
var $myVoices:=$client.audio.voices.list({path: "/custom-voices"; query: {limit: 100}}).voices
```

## Custom voices

OpenAI could not list the voices that you created. So the client keeps them in its `custom` collection, to return them with `list()`:

- `create()` adds the new voice, and `delete()` removes it.
- The collection lives with the client: it is not persisted. Save it into a file, or keep the IDs in your database and add them again.

### add()

**add**(*voice* : Text or Object) : OpenAIAudioVoice

Adds a voice to the custom voices of the client: its ID, or an object like the voice returned by `create()`. A voice with the same ID is replaced. Returns the voice added, or `Null` without ID.

```4d
$client.audio.voices.add("voice_1234")
$client.audio.voices.add({id: "voice_5678"; name: "John"})
```

### remove()

**remove**(*voiceId* : Text) : Boolean

Removes a voice from the custom voices of the client, without deleting it on the server. Returns `True` if the voice was found.

### save()

**save**(*file* : 4D.File) : Boolean

Saves the custom voices of the client into a JSON file. Returns `True` if saved.

### load()

**load**(*file* : 4D.File) : Boolean

Adds the custom voices saved into a JSON file. Returns `True` if loaded, `False` if the file does not exist or is not valid.

```4d
var $file:=Folder(fk user preferences folder).file("voices.json")

var $client:=cs.AIKit.OpenAI.new()
$client.audio.voices.load($file)

var $result:=$client.audio.voices.create("John"; {audio_sample: $sample; consent: $consentId})
If ($result.success)
    $client.audio.voices.save($file)
End if
```

## See also

- [OpenAIAudioAPI](OpenAIAudioAPI.md)
- [OpenAIAudioVoiceConsentsAPI](OpenAIAudioVoiceConsentsAPI.md)
- [OpenAIAudioVoice](OpenAIAudioVoice.md)
- [Listing voices](../audio-voices.md)
