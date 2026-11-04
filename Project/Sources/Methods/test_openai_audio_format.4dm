//%attributes = {"invisible":true}
// Test what is sent and how the responses are read, without any server.
var $client:=cs:C1710.OpenAI.new("key"; "http://127.0.0.1:1/v1")

// MARK:- parameters: nothing sent by default
var $transcriptionBody:=cs:C1710.OpenAIAudioTranscriptionParameters.new().body()
ASSERT:C1129(OB Is empty:C1297($transcriptionBody); "No default transcription parameters: "+JSON Stringify:C1217($transcriptionBody))
var $speechBody:=cs:C1710.OpenAIAudioSpeechParameters.new().body()
ASSERT:C1129(OB Is empty:C1297($speechBody); "No default speech parameters: "+JSON Stringify:C1217($speechBody))

// MARK:- parameters: a zero temperature is a value
$transcriptionBody:=cs:C1710.OpenAIAudioTranscriptionParameters.new({temperature: 0}).body()
ASSERT:C1129($transcriptionBody.temperature=0; "Zero temperature must be sent")
ASSERT:C1129(OB Is defined:C1231($transcriptionBody; "temperature"); "Zero temperature must be defined")

// MARK:- parameters: no client side limit, the server knows them (a local server could have others)
var $long:="x"*5000
$speechBody:=cs:C1710.OpenAIAudioSpeechParameters.new({instructions: $long; response_format: "custom"; speed: 10}).body()
ASSERT:C1129($speechBody.instructions=$long; "Long instructions must be sent")
ASSERT:C1129($speechBody.response_format="custom"; "Unknown response_format must be sent")
ASSERT:C1129($speechBody.speed=10; "Speed is not limited on client side")

// MARK:- parameters: filename is not a body field
$transcriptionBody:=cs:C1710.OpenAIAudioTranscriptionParameters.new({filename: "a.wav"}).body()
ASSERT:C1129(Not:C34(OB Is defined:C1231($transcriptionBody; "filename")); "filename must not be sent as a field")

// MARK:- multipart encoding
$transcriptionBody:=cs:C1710.OpenAIAudioTranscriptionParameters.new({\
keywords: ["AC-42"; "é"]; languages: ["fr"]; timestamp_granularities: ["word"; "segment"]; include: ["logprobs"]; \
known_speaker_names: ["agent"]; known_speaker_references: ["data:audio/wav;base64,AAA"]; \
chunking_strategy: {type: "server_vad"; threshold: 0.5; silence_duration_ms: 200}; \
temperature: 0.25; stream: True:C214; language: "fr"}).body()

var $form:=Convert to text:C1012($client._formData($transcriptionBody; {}; "BOUNDARY"); "UTF-8")

var $field:=Formula:C1597(Position:C15("--BOUNDARY\r\nContent-Disposition: form-data; name=\""+$2+"\"\r\n\r\n"+$3+"\r\n"; $1; *)>0)
ASSERT:C1129($field.call(Null:C1517; $form; "keywords[]"; "AC-42"); "First value of collection: "+$form)
ASSERT:C1129($field.call(Null:C1517; $form; "keywords[]"; "é"); "Second value of collection, in utf8: "+$form)
ASSERT:C1129($field.call(Null:C1517; $form; "languages[]"; "fr"); "languages: "+$form)
ASSERT:C1129($field.call(Null:C1517; $form; "timestamp_granularities[]"; "word"); "timestamp_granularities word: "+$form)
ASSERT:C1129($field.call(Null:C1517; $form; "timestamp_granularities[]"; "segment"); "timestamp_granularities segment: "+$form)
ASSERT:C1129($field.call(Null:C1517; $form; "include[]"; "logprobs"); "include: "+$form)
ASSERT:C1129($field.call(Null:C1517; $form; "known_speaker_names[]"; "agent"); "known_speaker_names: "+$form)
ASSERT:C1129($field.call(Null:C1517; $form; "known_speaker_references[]"; "data:audio/wav;base64,AAA"); "known_speaker_references: "+$form)
ASSERT:C1129($field.call(Null:C1517; $form; "chunking_strategy[type]"; "server_vad"); "Nested text: "+$form)
ASSERT:C1129($field.call(Null:C1517; $form; "chunking_strategy[threshold]"; "0.5"); "Nested real, with a dot: "+$form)
ASSERT:C1129($field.call(Null:C1517; $form; "chunking_strategy[silence_duration_ms]"; "200"); "Nested integer value: "+$form)
ASSERT:C1129($field.call(Null:C1517; $form; "temperature"; "0.25"); "Real, with a dot: "+$form)
ASSERT:C1129($field.call(Null:C1517; $form; "stream"; "true"); "Boolean in lowercase: "+$form)
ASSERT:C1129($field.call(Null:C1517; $form; "language"; "fr"); "Text: "+$form)
ASSERT:C1129(Position:C15("--BOUNDARY--"; $form)>0; "Closing boundary: "+$form)

// MARK:- file name of a blob: from its signature
var $bytes : Blob
var $name:=Formula:C1597($client.audio._audioFilename($1))

TEXT TO BLOB:C554("RIFF....WAVEfmt "; $bytes; UTF8 text without length:K22:17)
ASSERT:C1129($name.call(Null:C1517; 4D:C1709.Blob.new($bytes))="audio.wav"; "wav signature")
TEXT TO BLOB:C554("OggS...."; $bytes; UTF8 text without length:K22:17)
ASSERT:C1129($name.call(Null:C1517; 4D:C1709.Blob.new($bytes))="audio.ogg"; "ogg signature")
TEXT TO BLOB:C554("fLaC...."; $bytes; UTF8 text without length:K22:17)
ASSERT:C1129($name.call(Null:C1517; 4D:C1709.Blob.new($bytes))="audio.flac"; "flac signature")
TEXT TO BLOB:C554("....ftypM4A "; $bytes; UTF8 text without length:K22:17)
ASSERT:C1129($name.call(Null:C1517; 4D:C1709.Blob.new($bytes))="audio.m4a"; "m4a signature")
TEXT TO BLOB:C554("ID3...."; $bytes; UTF8 text without length:K22:17)
ASSERT:C1129($name.call(Null:C1517; 4D:C1709.Blob.new($bytes))="audio.mp3"; "mp3 signature")
SET BLOB SIZE:C606($bytes; 4)
$bytes{0}:=0x001A
$bytes{1}:=0x0045
$bytes{2}:=0x00DF
$bytes{3}:=0x00A3
ASSERT:C1129($name.call(Null:C1517; 4D:C1709.Blob.new($bytes))="audio.webm"; "webm signature")

// MARK:- required arguments
var $thrown:=False:C215
Try
	$client.audio.speech(""; "model"; "voice")
Catch
	$thrown:=True:C214
End try
ASSERT:C1129($thrown; "Empty input must throw")

$thrown:=False:C215
Try
	$client.audio.speech("input"; "model"; {name: "no id"})
Catch
	$thrown:=True:C214
End try
ASSERT:C1129($thrown; "Custom voice without id must throw")

$thrown:=False:C215
Try
	$client.audio.transcription("not a file"; "model")
Catch
	$thrown:=True:C214
End try
ASSERT:C1129($thrown; "Bad file type must throw")

// MARK:- speech result
var $audio : Blob
TEXT TO BLOB:C554("ID3 audio"; $audio; UTF8 text without length:K22:17)

var $speech:=cs:C1710.OpenAIAudioSpeechResult.new()
var $headers:={}
$headers["content-type"]:="audio/mpeg"
$speech.request:={response: {status: 200; headers: $headers; rawHeaders: $headers; body: 4D:C1709.Blob.new($audio)}}
ASSERT:C1129($speech.asBlob().size=BLOB size:C605($audio); "Speech blob")
ASSERT:C1129($speech.mimeType="audio/mpeg"; "MIME type from a lowercase header: "+$speech.mimeType)

$speech:=cs:C1710.OpenAIAudioSpeechResult.new()
$headers:={}
$headers["content-type"]:="application/json"
$speech.request:={response: {status: 401; headers: $headers; body: {error: {message: "bad key"}}}}
ASSERT:C1129($speech.asBlob()=Null:C1517; "No blob on API error")
ASSERT:C1129(Not:C34($speech.saveAudioToDisk(Folder:C1567(Temporary folder:C486; fk platform path:K87:2).file("aikit_no_audio.mp3"))); "Nothing to save on API error")

$speech:=cs:C1710.OpenAIAudioSpeechResult.new()
ASSERT:C1129($speech.asBlob()=Null:C1517; "No blob without response")
ASSERT:C1129($speech.mimeType=""; "No MIME type without response")

// MARK:- transcription result: json
var $transcript:=cs:C1710.OpenAIAudioTranscriptionResult.new()
$transcript.request:={response: {status: 200; headers: {}; body: {text: "bonjour"; languages: [{code: "fr"}]; usage: {type: "tokens"; total_tokens: 3}}}}
ASSERT:C1129($transcript.text="bonjour"; "json text")
ASSERT:C1129($transcript.transcription.languages[0].code="fr"; "json languages")
ASSERT:C1129($transcript.usage.total_tokens=3; "json usage")

// MARK:- transcription result: plain text, in text and in blob
$transcript:=cs:C1710.OpenAIAudioTranscriptionResult.new()
$transcript.request:={response: {status: 200; headers: {}; body: "bonjour\n"}}
ASSERT:C1129($transcript.text="bonjour"; "text format, without its line feed: ["+$transcript.text+"]")
ASSERT:C1129($transcript.textContent="bonjour\n"; "raw text format")
ASSERT:C1129($transcript.transcription=Null:C1517; "No transcription object with text format")

TEXT TO BLOB:C554("1\n00:00:00,000 --> 00:00:01,000\nbonjour é\n"; $audio; UTF8 text without length:K22:17)
$transcript:=cs:C1710.OpenAIAudioTranscriptionResult.new()
$transcript.request:={response: {status: 200; headers: {}; body: 4D:C1709.Blob.new($audio)}}
ASSERT:C1129(Position:C15("bonjour é"; $transcript.text)>0; "srt in a blob: "+$transcript.text)
ASSERT:C1129($transcript.transcription=Null:C1517; "No transcription object from a blob")

// MARK:- transcription result: no data on error
$transcript:=cs:C1710.OpenAIAudioTranscriptionResult.new()
$transcript.request:={response: {status: 500; headers: {}; body: "<html>Bad gateway</html>"}}
ASSERT:C1129($transcript.text=""; "No text on API error: "+$transcript.text)
ASSERT:C1129($transcript.transcription=Null:C1517; "No transcription on API error")

$transcript:=cs:C1710.OpenAIAudioTranscriptionResult.new()
ASSERT:C1129($transcript.text=""; "No text without response")
ASSERT:C1129($transcript.textContent=""; "No text content without response")
ASSERT:C1129($transcript.transcription=Null:C1517; "No transcription without response")

// MARK:- the model of a multipart request goes through the provider resolution
TEXT TO BLOB:C554("RIFF"; $audio; UTF8 text without length:K22:17)
var $aliased:=cs:C1710.OpenAI.new("key")
$aliased.maxRetries:=0
$aliased._providers._providers:={providers: {local: {baseURL: "http://127.0.0.1:1/local/v1"; apiKey: "localkey"}}; models: {myWhisper: {provider: "local"; model: "whisper"}}}

var $aliasResult:=$aliased.audio.transcription(4D:C1709.Blob.new($audio); "local:whisper")
ASSERT:C1129($aliasResult.request.url="http://127.0.0.1:1/local/v1/audio/transcriptions"; "provider:model must use provider URL: "+$aliasResult.request.url)
ASSERT:C1129($aliasResult.request.headers.Authorization="Bearer localkey"; "provider:model must use provider key")

$aliasResult:=$aliased.audio.transcription(4D:C1709.Blob.new($audio); "myWhisper")
ASSERT:C1129($aliasResult.request.url="http://127.0.0.1:1/local/v1/audio/transcriptions"; "alias must use provider URL: "+$aliasResult.request.url)

// MARK:- no response, no crash
ASSERT:C1129(Not:C34($aliasResult.success); "Connection must fail")
ASSERT:C1129($aliasResult.text=""; "No text when connection failed")
ASSERT:C1129($aliasResult.transcription=Null:C1517; "No transcription when connection failed")
