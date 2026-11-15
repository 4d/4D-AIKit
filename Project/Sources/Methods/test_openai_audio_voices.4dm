//%attributes = {"invisible":true}
// Voices and voice consents. The first parts need no server.

// MARK:- Well-known voices of OpenAI, without request
var $openAI:=cs.OpenAI.new({apiKey: "none"; baseURL: "https://api.openai.com/v1"})

var $list:=$openAI.audio.voices.list()
ASSERT($list.success; "Listing well-known voices must succeed")
ASSERT($list.request=Null; "No request expected for OpenAI")
ASSERT($list.errors.length=0; "No error expected")
ASSERT($list.voices.length=13; "13 built-in voices expected, got "+String($list.voices.length))
ASSERT($list.voices.query("id = :1"; "marin").length=1; "marin must be listed")
ASSERT($list.voices[0].reference="alloy"; "A built-in voice is referenced by its name")

$list:=$openAI.audio.voices.list({model: "tts-1"})
ASSERT($list.voices.length=9; "9 voices expected for tts-1")
ASSERT($list.voices.query("id = :1"; "marin").length=0; "marin is not a tts-1 voice")

// MARK:- Custom voices: add, list, save, load, remove
var $voices:=$openAI.audio.voices
$voices.add({id: "voice_1234"; object: "audio.voice"; name: "My voice"; created_at: 1; type: "audio_sample"})
$voices.add("voice_5678")
$voices.add("voice_5678")  // no duplicate
ASSERT($voices.custom.length=2; "2 custom voices expected")
ASSERT($voices.add({name: ""})=Null; "No voice without id")

$list:=$voices.list()
ASSERT($list.voices.length=15; "Custom voices must be listed after the built-in ones")
var $custom : cs.OpenAIAudioVoice:=$list.voices.query("id = :1"; "voice_1234").first()
If (Asserted($custom#Null; "Custom voice must be listed"))
	ASSERT($custom.custom; "Must be flagged as custom")
	ASSERT($custom.name="My voice"; "Name must be kept")
	ASSERT(Value type($custom.reference)=Is object; "A custom voice is referenced by an object")
	ASSERT(String($custom.reference.id)="voice_1234"; "Reference must have the id")
End if 
ASSERT($voices.list({custom: False}).voices.length=13; "Custom voices could be excluded")

var $file:=Folder(Temporary folder; fk platform path).file("OpenAI_Test_voices.json")
ASSERT($voices.save($file); "Custom voices must be saved")

var $other:=cs.OpenAI.new({apiKey: "none"; baseURL: "https://api.openai.com/v1"})
ASSERT($other.audio.voices.custom.length=0; "Custom voices are not shared between clients")
ASSERT($other.audio.voices.load($file); "Custom voices must be loaded")
ASSERT($other.audio.voices.custom.length=2; "2 custom voices expected after load")
ASSERT($other.audio.voices.custom[0].name="My voice"; "Name must be loaded")
ASSERT($other.audio.voices.list().voices.length=15; "Loaded voices must be listed")
$file.delete()
ASSERT(Not($other.audio.voices.load($file)); "Nothing to load from a missing file")

ASSERT($voices.remove("voice_5678"); "Custom voice must be removed")
ASSERT(Not($voices.remove("voice_5678")); "Already removed")
ASSERT($voices.custom.length=1; "1 custom voice expected")

// MARK:- Decode the formats of the servers
var $samples:=[]
$samples.push({name: "ElevenLabs-like"; count: 2; id: "a1"; body: {voices: [{voice_id: "a1"; name: "Anna"}; {voice_id: "b2"; name: "Bob"}]}})
$samples.push({name: "names"; count: 2; id: "tara"; body: {status: "ok"; voices: ["tara"; "leo"]}})
$samples.push({name: "OpenAI-like"; count: 1; id: "v1"; body: {object: "list"; data: [{id: "v1"; name: "One"}]}})
$samples.push({name: "items"; count: 1; id: "m1"; body: {items: [{id: "m1"; name: "Mistral"}]; total: 1}})
$samples.push({name: "by model"; count: 3; id: "x"; model: "kokoro"; body: {data: [{model: "kokoro"; voices: [{id: "x"; name: "X"}; "y"]}; {model: "piper"; voices: [{id: "z"}]}]}})
$samples.push({name: "array"; count: 1; id: "en-US-JennyNeural"; body: [{ShortName: "en-US-JennyNeural"; DisplayName: "Jenny"}]})
$samples.push({name: "voiceId"; count: 1; id: "Alex"; body: {voices: [{voiceId: "Alex"; displayName: "Alex D"}]}})
$samples.push({name: "none"; count: 0; body: {object: "list"}})

var $sample : Object
For each ($sample; $samples)
	var $decoded:=cs.OpenAIAudioVoiceListResult.new()
	$decoded.request:={response: {status: 200; body: $sample.body}}
	ASSERT($decoded.success; $sample.name+": must be a success")
	ASSERT($decoded.voices.length=$sample.count; $sample.name+": "+String($sample.count)+" voices expected, got "+String($decoded.voices.length))
	If ($sample.count>0)
		ASSERT($decoded.voices[0].id=$sample.id; $sample.name+": wrong id "+String($decoded.voices[0].id))
		ASSERT(Length(String($decoded.voices[0].name))>0; $sample.name+": name must be filled")
		If ($sample.model#Null)
			ASSERT($decoded.voices[0].model=$sample.model; $sample.name+": wrong model")
		End if 
	End if 
End for each 

$decoded:=cs.OpenAIAudioVoiceListResult.new()
$decoded.request:={response: {status: 404; body: {detail: "Not Found"}}}
ASSERT(Not($decoded.success); "404 is not a success")
ASSERT($decoded.voices.length=0; "No voice on error")

// MARK:- Arguments
var $thrown:=False
Try
	$openAI.audio.voices.create("name"; {})
Catch
	$thrown:=True
End try
ASSERT($thrown; "create must throw without audio_sample or prompt")

$thrown:=False
Try
	$openAI.audio.voiceConsents.create("name"; "en-US"; Null)
Catch
	$thrown:=True
End try
ASSERT($thrown; "consent create must throw without recording")

// MARK:- A server which lists its voices (VoiceStudio, Kokoro-FastAPI, Speaches...)
var $local:=cs.OpenAI.new({apiKey: "none"; baseURL: "http://127.0.0.1:3900/v1"})
$list:=$local.audio.voices.list({timeout: 5; maxRetries: 0})
If ($list.success)  // else no such server running
	ASSERT($list.voices.length>0; "The local server must list voices")
	ASSERT(Length(String($list.voices[0].id))>0; "Voice id must be filled")
	ASSERT(Length(String($list.voices[0].name))>0; "Voice name must be filled")
End if 

// MARK:- OpenAI voice consents
var $client:=TestOpenAI()
If (($client=Null) || (Position("api.openai.com"; $client.baseURL)=0) || (Length($client.apiKey)=0))
	return   // skip
End if 

var $consents:=$client.audio.voiceConsents.list({limit: 5})
If (Not($consents.success))
	return   // custom voices are limited to eligible customers
End if 

ASSERT(Value type($consents.consents)=Is collection; "Consents must be a collection")
If ($consents.consents.length>0)
	var $consent : cs.OpenAIAudioVoiceConsent:=$consents.consents[0]
	ASSERT(Length(String($consent.id))>0; "Consent id must not be empty")
	
	var $retrieved:=$client.audio.voiceConsents.retrieve($consent.id)
	If (Asserted($retrieved.success; "Cannot retrieve consent: "+JSON Stringify($retrieved.errors)))
		ASSERT($retrieved.consent.id=$consent.id; "Retrieved consent must match")
	End if 
End if 

var $missing:=$client.audio.voices.delete("voice_does_not_exist")
ASSERT(Not($missing.success); "Deleting an unknown voice must fail")
ASSERT($missing.deleted=Null; "No deletion status on error")
