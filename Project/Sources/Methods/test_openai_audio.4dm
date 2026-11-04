//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// MARK:- Test Speech Generation (Text-to-Speech)
var $result:=$client.audio.speech("Hello, this is a test of the text to speech API."; "tts-1"; "alloy")

If (Asserted:C1132(Bool:C1537($result.success); "Cannot generate speech: "+JSON Stringify:C1217($result.errors)))
	
	// Verify we got audio data back
	var $audioBlob:=$result.asBlob()
	If (Asserted:C1132($audioBlob#Null:C1517; "Audio blob must not be null"))
		ASSERT:C1129($audioBlob.size>0; "Audio blob must have data")
	End if 
	
	// Verify MIME type
	var $mimeType:=$result.mimeType
	ASSERT:C1129(Length:C16($mimeType)>0; "MIME type must be present")
	ASSERT:C1129(Position:C15("audio"; $mimeType)>0; "MIME type should contain 'audio'")
	
End if 

// MARK:- Test Speech with different voice
$result:=$client.audio.speech("Testing different voices."; "tts-1"; "echo")

If (Asserted:C1132(Bool:C1537($result.success); "Cannot generate speech with echo voice"))
	$audioBlob:=$result.asBlob()
	ASSERT:C1129($audioBlob#Null:C1517; "Audio blob must not be null")
	ASSERT:C1129($audioBlob.size>0; "Audio blob must have data")
End if 

// MARK:- Test Speech with parameters (response format and speed)
var $params:=cs:C1710.OpenAIAudioSpeechParameters.new()
$params.response_format:="opus"
$params.speed:=1.25

$result:=$client.audio.speech("This is faster speech in opus format."; "tts-1"; "nova"; $params)

If (Asserted:C1132(Bool:C1537($result.success); "Cannot generate speech with parameters"))
	$audioBlob:=$result.asBlob()
	ASSERT:C1129($audioBlob#Null:C1517; "Audio blob must not be null")
	ASSERT:C1129($audioBlob.size>0; "Audio blob must have data")
End if 

// MARK:- Test saving audio to disk
var $testDataFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder("OpenAI_Test_Audio")
If (Not:C34($testDataFolder.exists))
	$testDataFolder.create()
End if 

var $audioFile:=$testDataFolder.file("test_speech.mp3")
$result:=$client.audio.speech("Save this audio to disk."; "tts-1"; "alloy")

If (Asserted:C1132(Bool:C1537($result.success); "Cannot generate speech for save test"))
	var $saved:=$result.saveAudioToDisk($audioFile)
	ASSERT:C1129($saved; "Audio should be saved successfully")
	ASSERT:C1129($audioFile.exists; "Audio file should exist")
	ASSERT:C1129($audioFile.size>0; "Saved audio file should have data")
End if 

/*// MARK:- Test invalid voice (should fail)
Try
$result:=$client.audio.speech("Invalid voice test"; "tts-1"; "invalid_voice")
ASSERT(False; "Should have thrown error for invalid voice")
Catch
ASSERT(True; "Correctly throws error for invalid voice")
End try*/

// MARK:- Test Transcription (if we have audio file)
// Note: We'll use the audio file we just created for transcription
If ($audioFile.exists)
	
	var $resultTranscription:=$client.audio.transcription($audioFile; "gpt-transcribe")
	
	If (Asserted:C1132(Bool:C1537($resultTranscription.success); "Cannot transcribe audio: "+JSON Stringify:C1217($resultTranscription.errors)))
		
		// Verify transcription text
		var $text:=$resultTranscription.text
		ASSERT:C1129(Length:C16($text)>0; "Transcription text must not be empty")
		
		// Verify transcription object
		var $transcription:=$resultTranscription.transcription
		If (Asserted:C1132($transcription#Null:C1517; "Transcription object must not be null"))
			ASSERT:C1129(Length:C16($transcription.text)>0; "Transcription text in object must not be empty")
		End if 
		
	End if 
	
End if 

// MARK:- Test Transcription with language parameter
If ($audioFile.exists)
	
	var $transcriptParams:=cs:C1710.OpenAIAudioTranscriptionParameters.new()
	$transcriptParams.language:="en"
	$transcriptParams.response_format:="json"
	
	$resultTranscription:=$client.audio.transcription($audioFile; "whisper-1"; $transcriptParams)
	
	If (Asserted:C1132(Bool:C1537($resultTranscription.success); "Cannot transcribe with language parameter"))
		ASSERT:C1129(Length:C16($resultTranscription.text)>0; "Transcription text must not be empty")
	End if 
	
End if 

// MARK:- Test Transcription with text response format (textContent)
If ($audioFile.exists)
	
	$transcriptParams:=cs:C1710.OpenAIAudioTranscriptionParameters.new()
	$transcriptParams.response_format:="text"
	
	$resultTranscription:=$client.audio.transcription($audioFile; "whisper-1"; $transcriptParams)
	
	If (Asserted:C1132(Bool:C1537($resultTranscription.success); "Cannot transcribe with text format"))
		var $textContent:=$resultTranscription.textContent
		ASSERT:C1129(Length:C16($textContent)>0; "textContent must not be empty for text format")
		ASSERT:C1129(Length:C16($resultTranscription.text)>0; "text must not be empty for text format")
		ASSERT:C1129($resultTranscription.transcription=Null:C1517; "No transcription object for text format")
	End if 
	
End if 

// MARK:- Test Transcription with SRT response format (textContent)
If ($audioFile.exists)
	
	$transcriptParams:=cs:C1710.OpenAIAudioTranscriptionParameters.new()
	$transcriptParams.response_format:="srt"
	
	$resultTranscription:=$client.audio.transcription($audioFile; "whisper-1"; $transcriptParams)
	
	If (Asserted:C1132(Bool:C1537($resultTranscription.success); "Cannot transcribe with srt format"))
		// For SRT format, use textContent
		$textContent:=$resultTranscription.textContent
		ASSERT:C1129(Length:C16($textContent)>0; "textContent must not be empty for srt format")
		// SRT format should contain timestamp markers like "00:00:00"
		ASSERT:C1129(Position:C15("-->"; $textContent)>0; "SRT content should contain timestamp markers")
	End if 
	
End if 

// MARK:- Test Transcription with VTT response format (textContent)
If ($audioFile.exists)
	
	$transcriptParams:=cs:C1710.OpenAIAudioTranscriptionParameters.new()
	$transcriptParams.response_format:="vtt"
	
	$resultTranscription:=$client.audio.transcription($audioFile; "whisper-1"; $transcriptParams)
	
	If (Asserted:C1132(Bool:C1537($resultTranscription.success); "Cannot transcribe with vtt format"))
		// For VTT format, use textContent
		$textContent:=$resultTranscription.textContent
		ASSERT:C1129(Length:C16($textContent)>0; "textContent must not be empty for vtt format")
		// VTT format should start with WEBVTT header
		ASSERT:C1129(Position:C15("WEBVTT"; $textContent)>0; "VTT content should contain WEBVTT header")
	End if 
	
End if 

// MARK:- Test Transcription with word timestamps (collection parameter)
If ($audioFile.exists)
	
	$transcriptParams:=cs:C1710.OpenAIAudioTranscriptionParameters.new()
	$transcriptParams.response_format:="verbose_json"
	$transcriptParams.timestamp_granularities:=["word"; "segment"]
	$transcriptParams.temperature:=0.2
	
	$resultTranscription:=$client.audio.transcription($audioFile; "whisper-1"; $transcriptParams)
	
	If (Asserted:C1132(Bool:C1537($resultTranscription.success); "Cannot transcribe with timestamps: "+JSON Stringify:C1217($resultTranscription.errors)))
		$transcription:=$resultTranscription.transcription
		If (Asserted:C1132($transcription#Null:C1517; "Transcription object must not be null"))
			ASSERT:C1129($transcription.words.length>0; "Words must be returned")
			ASSERT:C1129($transcription.segments.length>0; "Segments must be returned")
			ASSERT:C1129($transcription.duration>0; "Duration must be returned")
		End if 
	End if 
	
End if 

// MARK:- Test Transcription with keywords and languages (collection parameters)
If ($audioFile.exists)
	
	$transcriptParams:=cs:C1710.OpenAIAudioTranscriptionParameters.new()
	$transcriptParams.keywords:=["audio"; "disk"]
	$transcriptParams.languages:=["en"]
	
	$resultTranscription:=$client.audio.transcription($audioFile; "gpt-transcribe"; $transcriptParams)
	
	If (Asserted:C1132(Bool:C1537($resultTranscription.success); "Cannot transcribe with keywords: "+JSON Stringify:C1217($resultTranscription.errors)))
		ASSERT:C1129(Length:C16($resultTranscription.text)>0; "Transcription text must not be empty")
	End if 
	
End if 

// MARK:- Test Transcription of a blob without file name
If ($audioFile.exists)
	
	$resultTranscription:=$client.audio.transcription($audioFile.getContent(); "gpt-transcribe")
	
	If (Asserted:C1132(Bool:C1537($resultTranscription.success); "Cannot transcribe a blob: "+JSON Stringify:C1217($resultTranscription.errors)))
		ASSERT:C1129(Length:C16($resultTranscription.text)>0; "Transcription text must not be empty")
	End if 
	
End if 

// MARK:- Test API error
var $badResult:=$client.audio.speech("Hello"; "bad"; "alloy")
If (Asserted:C1132(Not:C34($badResult.success); "A bad model must fail"))
	ASSERT:C1129($badResult.errors.length>0; "A bad model must give errors")
	ASSERT:C1129($badResult.asBlob()=Null:C1517; "No blob on API error")
End if 

// MARK:- Clean up test files
If ($audioFile.exists)
	$audioFile.delete()
End if 
If ($testDataFolder.exists)
	$testDataFolder.delete(fk recursive:K87:7)
End if 
