# Listing voices

`$client.audio.voices.list()` returns the voices to use with [speech()](Classes/OpenAIAudioAPI.md#speech), as [OpenAIAudioVoice](Classes/OpenAIAudioVoice.md) with `id` and `name` always filled. See [OpenAIAudioVoicesAPI](Classes/OpenAIAudioVoicesAPI.md).

```4d
var $voices:=$client.audio.voices.list().voices
```

What is done depends on the `baseURL` of the client.

## Well-known voices, no request

These servers have no endpoint to list voices, so the list is in the component:

|Provider|baseURL contains|Voices|
|-|-|-|
|https://openai.com/|`api.openai.com`|`alloy`, `ash`, `ballad`, `cedar`, `coral`, `echo`, `fable`, `marin`, `nova`, `onyx`, `sage`, `shimmer`, `verse`. With `{model: "tts-1"}` or `tts-1-hd`: without `ballad`, `cedar`, `marin`, `verse`.|
|https://ai.azure.com/|`.openai.azure.com`|Same as OpenAI|
|https://groq.com/|`api.groq.com`|`autumn`, `diana`, `hannah`, `austin`, `daniel`, `troy` of `canopylabs/orpheus-v1-english`|

The [custom voices](Classes/OpenAIAudioVoicesAPI.md#custom-voices) of the client are added after them: OpenAI could not list the voices that you created, so they must be added again to a new client, or saved into a file.

## Requested servers

|Server|baseURL|Requested path|Tested|
|-|-|-|-|
|[VoiceStudio](https://github.com/debpalash/VoiceStudio)|http://127.0.0.1:3900/v1|`/audio/voices`|✅|
|https://mistral.ai/|https://api.mistral.ai/v1|`/audio/voices`||
|[Kokoro-FastAPI](https://github.com/remsky/Kokoro-FastAPI)|http://localhost:8880/v1|`/audio/voices`||
|[Speaches](https://github.com/speaches-ai/speaches)|http://localhost:8000/v1|`/audio/voices`||
|[LocalAI](https://localai.io/)|http://127.0.0.1:8080/v1|`/audio/voices`, by model||
|[Orpheus-FastAPI](https://github.com/Lex-au/Orpheus-FastAPI)|http://localhost:5005/v1|`/audio/voices`||
|[Chatterbox TTS API](https://github.com/travisvn/chatterbox-tts-api)|http://localhost:4123/v1|`/voices`, after a 404 on `/audio/voices`||
|https://www.together.ai/|https://api.together.ai/v1|`/voices`, by model||
|https://x.ai/|https://api.x.ai/v1|`/tts/voices`. Your own voices: `{path: "/custom-voices"}`||
|https://elevenlabs.io/|https://api.elevenlabs.io/v1|`/voices`, the key is also sent as `xi-api-key`||
|https://speechify.ai/|https://api.speechify.ai/v1|`/voices`||
|https://deepinfra.com/|https://api.deepinfra.com/v1 (not `/v1/openai`)|`/voices`, after a 404 on `/audio/voices`||

- By default `/audio/voices` is requested. If the server answers 404 or 405, `/voices` is tried. This second try is not done with an [asynchronous call](asynchronous-call.md): then give the `path`.
- Only the listing is supported for these servers: most of them do not generate speech with `speech()`, they have their own endpoint.

## Other servers

Any server with a JSON list of voices could be requested with the `path`, `query` and `extraHeaders` [parameters](Classes/OpenAIAudioVoiceListParameters.md). The paths below come from the documentation of each provider, and were not tested:

|Provider|baseURL|`path`|Authentication|
|-|-|-|-|
|https://cartesia.ai/|https://api.cartesia.ai|`/voices`|Bearer, and a `Cartesia-Version` header|
|https://deepgram.com/|https://api.deepgram.com/v1|`/models` (the `tts` list)|`Authorization: Token <key>`|
|https://azure.microsoft.com/products/ai-services/text-to-speech|https://YOUR_REGION.tts.speech.microsoft.com/cognitiveservices|`/voices/list`|`Ocp-Apim-Subscription-Key`|
|https://cloud.google.com/text-to-speech|https://texttospeech.googleapis.com/v1|`/voices`|`X-Goog-Api-Key`|
|https://fish.audio/|https://api.fish.audio|`/model`|Bearer|
|https://www.resemble.ai/|https://app.resemble.ai/api/v2|`/voices`, with `query: {page: 1}`|Bearer|
|https://inworld.ai/|https://api.inworld.ai/voices/v1|`/voices`|`Authorization: Basic <key>`|
|[Open WebUI](https://openwebui.com/)|http://localhost:3000/api/v1|`/audio/voices`|Bearer|
|[AllTalk](https://github.com/erew123/alltalk_tts)|http://localhost:7851/api|`/voices`||

```4d
var $client:=cs.AIKit.OpenAI.new({baseURL: "https://api.deepgram.com/v1"})
var $voices:=$client.audio.voices.list({path: "/models"; extraHeaders: {Authorization: "Token "+$key}}).voices
```

No endpoint, and no list in the component: Gemini, Fireworks, Ollama, LM Studio, openedai-speech.

## VoiceStudio

VoiceStudio answers in an ElevenLabs-like shape that also carries a plain `id`:

```json
{
  "voices": [
    {
      "voice_id": "alloy",
      "id": "alloy",
      "name": "Alloy",
      "type": "openai_alias",
      "description": "OpenAI 'alloy' voice — maps to the active VoiceStudio engine's default voice."
    }
  ]
}
```

- Entries with `"type": "openai_alias"` are the OpenAI voice names; they all map to the active engine's default voice.
- The other entries, with `"type": "profile"`, are the user's voice profiles (cloned or designed voices).
- On localhost no API key is needed. A remote server requires its `OMNIVOICE_API_KEY` as a Bearer token.
- Voices are created in VoiceStudio itself: it has no `/v1/audio/voices` endpoint to create or delete one.

```4d
var $client:=cs.AIKit.OpenAI.new({apiKey: "none"; baseURL: "http://127.0.0.1:3900/v1"})

var $profiles:=$client.audio.voices.list().voices.query("type = :1"; "profile")
If ($profiles.length>0)
    var $params:=cs.AIKit.OpenAIAudioSpeechParameters.new({response_format: "wav"})
    var $result:=$client.audio.speech("Hello from VoiceStudio."; "tts-1"; $profiles[0].reference; $params)

    If ($result.success)
        $result.saveAudioToDisk(Folder(fk desktop folder).file("voicestudio.wav"))
    End if
End if
```
