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

// MARK:- Voice consents and voices
var $client:=TestOpenAI()
If ($client=Null)
	return   // skip test
End if 

If (Position("api.openai.com"; $client.baseURL)>0)
	
	// MARK: OpenAI: read only, custom voices are limited to eligible customers
	var $consents:=$client.audio.voiceConsents.list({limit: 5})
	If ($consents.success)
		ASSERT(Value type($consents.consents)=Is collection; "Consents must be a collection")
		If ($consents.consents.length>0)
			var $first : cs.OpenAIAudioVoiceConsent:=$consents.consents[0]
			var $retrieved:=$client.audio.voiceConsents.retrieve($first.id)
			If (Asserted($retrieved.success; "Cannot retrieve consent: "+JSON Stringify($retrieved.errors)))
				ASSERT($retrieved.consent.id=$first.id; "Retrieved consent must match")
			End if 
		End if 
	End if 
	
	var $missing:=$client.audio.voices.delete("voice_does_not_exist")
	ASSERT(Not($missing.success); "Deleting an unknown voice must fail")
	ASSERT($missing.deleted=Null; "No deletion status on error")
	return 
	
End if 

// MARK: Create consent
var $audio : Blob
TEXT TO BLOB("RIFF____WAVEfmt mock audio"; $audio; UTF8 text without length)  // the file name comes from the signature

var $consentResult:=$client.audio.voiceConsents.create("Test consent"; "en-US"; $audio)
If ((Not($consentResult.success)) && ($consentResult.errors.length>0) && ([404; 405].includes(Num($consentResult.errors[0].status))))
	return   // a server without custom voices
End if 

If (Not(Asserted($consentResult.success; "Cannot create consent: "+JSON Stringify($consentResult.errors))))
	return 
End if 

var $consent:=$consentResult.consent
If (Not(Asserted($consent#Null; "Consent must not be null")))
	return 
End if 
ASSERT(Length(String($consent.id))>0; "Consent id must not be empty")
ASSERT(String($consent.object)="audio.voice_consent"; "Wrong consent object type")
ASSERT(String($consent.name)="Test consent"; "Consent name must match")
ASSERT(String($consent.language)="en-US"; "Consent language must match")

// MARK: Consent from a file
var $audioFile:=Folder(Temporary folder; fk platform path).file("OpenAI_Test_consent.wav")
$audioFile.setContent($audio)
var $fileConsent:=$client.audio.voiceConsents.create("Test consent file"; "fr-FR"; $audioFile)
ASSERT($fileConsent.success; "Cannot create consent from a file: "+JSON Stringify($fileConsent.errors))

// MARK: List consents, with pagination
var $listParams:=cs.OpenAIAudioVoiceConsentListParameters.new({limit: 1})
var $consentList:=$client.audio.voiceConsents.list($listParams)
If (Asserted($consentList.success; "Cannot list consents: "+JSON Stringify($consentList.errors)))
	ASSERT($consentList.consents.length=1; "One consent by page expected")
	ASSERT($consentList.has_more; "More consents expected")
	ASSERT($consentList.first_id=$consentList.consents[0].id; "first_id must be the first consent")
	ASSERT($consentList.last_id=$consentList.consents[0].id; "last_id must be the last consent")
	
	var $allConsents : Collection:=$consentList.consents
	var $pages:=1
	While ($consentList.success && $consentList.has_more && ($pages<1000))
		$listParams.after:=$consentList.last_id
		$consentList:=$client.audio.voiceConsents.list($listParams)
		$allConsents:=$allConsents.concat($consentList.consents)
		$pages+=1
	End while 
	ASSERT($allConsents.query("id = :1"; $consent.id).length=1; "Created consent must be listed once")
End if 

// MARK: Retrieve and update consent
var $consentRead:=$client.audio.voiceConsents.retrieve($consent.id)
If (Asserted($consentRead.success; "Cannot retrieve consent: "+JSON Stringify($consentRead.errors)))
	ASSERT($consentRead.consent.id=$consent.id; "Retrieved consent must match")
End if 

$consentRead:=$client.audio.voiceConsents.update($consent.id; "Renamed consent")
If (Asserted($consentRead.success; "Cannot update consent: "+JSON Stringify($consentRead.errors)))
	ASSERT($consentRead.consent.name="Renamed consent"; "Consent must be renamed")
End if 
ASSERT($client.audio.voiceConsents.retrieve($consent.id).consent.name="Renamed consent"; "New name must be kept")

$consentRead:=$client.audio.voiceConsents.retrieve("cons_does_not_exist")
ASSERT(Not($consentRead.success); "Retrieving an unknown consent must fail")
ASSERT($consentRead.consent=Null; "No consent on error")

// MARK: Create voice from an audio sample
var $api:=$client.audio.voices
var $voiceResult:=$api.create("Test voice"; {audio_sample: $audio; consent: $consent.id})
var $voiceId:=""
If (Asserted($voiceResult.success; "Cannot create voice: "+JSON Stringify($voiceResult.errors)))
	If (Asserted($voiceResult.voice#Null; "Voice must not be null"))
		$voiceId:=$voiceResult.voice.id
		ASSERT(Length($voiceId)>0; "Voice id must not be empty")
		ASSERT(String($voiceResult.voice.object)="audio.voice"; "Wrong voice object type")
		ASSERT(String($voiceResult.voice.name)="Test voice"; "Voice name must match")
		ASSERT(String($voiceResult.voice.type)="audio_sample"; "Voice type must be audio_sample")
		ASSERT($api.custom.query("id = :1"; $voiceId).length=1; "Created voice must be a custom voice of the client")
	End if 
End if 

$voiceResult:=$api.create("Test voice"; {audio_sample: $audioFile; consent: "cons_does_not_exist"})
ASSERT(Not($voiceResult.success); "Creating a voice with an unknown consent must fail")
ASSERT($voiceResult.voice=Null; "No voice on error")

// MARK: Create voice from a prompt
$voiceResult:=$api.create("Prompt voice"; {prompt: "A warm and calm narrator"; model: "auto"})
var $promptVoiceId:=""
If (Asserted($voiceResult.success; "Cannot create voice from a prompt: "+JSON Stringify($voiceResult.errors)))
	$promptVoiceId:=String($voiceResult.voice.id)
	ASSERT(String($voiceResult.voice.type)="prompt"; "Voice type must be prompt")
End if 

// MARK: List the voices of the server
$list:=$api.list()
If (Asserted($list.success; "Cannot list voices: "+JSON Stringify($list.errors)))
	ASSERT($list.request#Null; "The server must be requested")
	ASSERT($list.voices.length>=2; "Voices expected")
	ASSERT($list.voices.every(Formula(Length(String($1.value.id))>0)); "All voices must have an id")
	ASSERT($list.voices.every(Formula(Length(String($1.value.name))>0)); "All voices must have a name")
	If (Length($voiceId)>0)
		ASSERT($list.voices.query("id = :1"; $voiceId).length=1; "Created voice must be listed")
	End if 
End if 

// MARK: Speech with the custom voice
If (Length($voiceId)>0)
	var $speech:=$client.audio.speech("Hello"; "gpt-4o-mini-tts"; $api.custom.query("id = :1"; $voiceId).first().reference)
	ASSERT($speech.success; "Cannot generate speech with a custom voice: "+JSON Stringify($speech.errors))
End if 

// MARK: Delete voices
var $id : Text
For each ($id; [$voiceId; $promptVoiceId])
	If (Length($id)>0)
		var $deleted:=$api.delete($id)
		If (Asserted($deleted.success; "Cannot delete voice: "+JSON Stringify($deleted.errors)))
			ASSERT($deleted.deleted.id=$id; "Deleted voice id must match")
			ASSERT($deleted.deleted.deleted; "Voice must be deleted")
			ASSERT($api.custom.query("id = :1"; $id).length=0; "Deleted voice must be removed from the custom voices")
		End if 
		
		$deleted:=$api.delete($id)
		ASSERT(Not($deleted.success); "Deleting a voice twice must fail")
		ASSERT($deleted.deleted=Null; "No deletion status on error")
	End if 
End for each 

// MARK: Delete consents
For each ($id; [$consent.id; String($fileConsent.consent.id)])
	If (Length($id)>0)
		$deleted:=$client.audio.voiceConsents.delete($id)
		If (Asserted($deleted.success; "Cannot delete consent: "+JSON Stringify($deleted.errors)))
			ASSERT($deleted.deleted.id=$id; "Deleted consent id must match")
			ASSERT($deleted.deleted.deleted; "Consent must be deleted")
		End if 
		ASSERT(Not($client.audio.voiceConsents.retrieve($id).success); "Deleted consent must not be found")
	End if 
End for each 
$audioFile.delete()
