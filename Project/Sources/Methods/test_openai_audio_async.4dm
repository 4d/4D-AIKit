//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// MARK:- Test Speech Generation (async)
cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.audio.speech("Hello, this is an async test."; "tts-1"; "alloy"; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))

cs:C1710._TestSignal.me.wait(15*1000)

var $result : cs:C1710.OpenAIAudioSpeechResult:=cs:C1710._TestSignal.me.result
If (Asserted:C1132(Bool:C1537($result.success); "Cannot generate speech (async): "+JSON Stringify:C1217($result)))
	
	// Verify we got audio data back
	var $audioBlob:=$result.asBlob()
	If (Asserted:C1132($audioBlob#Null:C1517; "Async audio blob must not be null"))
		ASSERT:C1129($audioBlob.size>0; "Async audio blob must have data")
	End if 
	
	// Verify MIME type
	var $mimeType:=$result.mimeType
	ASSERT:C1129(Length:C16($mimeType)>0; "MIME type must be present")
	
End if 

cs:C1710._TestSignal.me.reset()

// MARK:- Test Speech with parameters (async)
cs:C1710._TestSignal.me.init()

var $params:=cs:C1710.OpenAIAudioSpeechParameters.new()
$params.response_format:="opus"
$params.speed:=1.5
$params.formula:=Formula:C1597(cs:C1710._TestSignal.me.trigger($1))

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.audio.speech("Faster async speech."; "tts-1"; "nova"; $params)))

cs:C1710._TestSignal.me.wait(15*1000)

$result:=cs:C1710._TestSignal.me.result
If (Asserted:C1132(Bool:C1537($result.success); "Cannot generate speech with params (async)"))
	$audioBlob:=$result.asBlob()
	ASSERT:C1129($audioBlob#Null:C1517; "Async audio blob must not be null")
	ASSERT:C1129($audioBlob.size>0; "Async audio blob must have data")
End if 

cs:C1710._TestSignal.me.reset()

// MARK:- Create test audio file for transcription/translation tests
var $testDataFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder("OpenAI_Test_Audio_Async")
If (Not:C34($testDataFolder.exists))
	$testDataFolder.create()
End if 

// Generate an audio file synchronously for testing transcription/translation
var $audioFile:=$testDataFolder.file("test_async_speech.mp3")
var $syncResult:=$client.audio.speech("This audio will be transcribed asynchronously."; "tts-1"; "alloy")
If (Bool:C1537($syncResult.success))
	$syncResult.saveAudioToDisk($audioFile)
End if 

// MARK:- Test Transcription (async)
If ($audioFile.exists)
	
	cs:C1710._TestSignal.me.init()
	
	CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.audio.transcription($audioFile; "whisper-1"; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))
	
	cs:C1710._TestSignal.me.wait(30*1000)  // Transcription may take longer
	
	var $transcriptResult : cs:C1710.OpenAIAudioTranscriptionResult:=cs:C1710._TestSignal.me.result
	If (Asserted:C1132(Bool:C1537($transcriptResult.success); "Cannot transcribe audio (async): "+JSON Stringify:C1217($transcriptResult)))
		
		// Verify transcription text
		var $text:=$transcriptResult.text
		ASSERT:C1129(Length:C16($text)>0; "Async transcription text must not be empty")
		
		// Verify transcription object
		var $transcription:=$transcriptResult.transcription
		If (Asserted:C1132($transcription#Null:C1517; "Async transcription object must not be null"))
			ASSERT:C1129(Length:C16($transcription.text)>0; "Async transcription text in object must not be empty")
		End if 
		
	End if 
	
	cs:C1710._TestSignal.me.reset()
	
End if 

// MARK:- Test Transcription with parameters (async)
If ($audioFile.exists)
	
	cs:C1710._TestSignal.me.init()
	
	var $transcriptParams:=cs:C1710.OpenAIAudioTranscriptionParameters.new()
	$transcriptParams.language:="en"
	$transcriptParams.response_format:="json"
	$transcriptParams.formula:=Formula:C1597(cs:C1710._TestSignal.me.trigger($1))
	
	CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.audio.transcription($audioFile; "whisper-1"; $transcriptParams)))
	
	cs:C1710._TestSignal.me.wait(30*1000)
	
	$transcriptResult:=cs:C1710._TestSignal.me.result
	If (Asserted:C1132(Bool:C1537($transcriptResult.success); "Cannot transcribe with params (async)"))
		ASSERT:C1129(Length:C16($transcriptResult.text)>0; "Async transcription text must not be empty")
	End if 
	
	cs:C1710._TestSignal.me.reset()
	
End if 

// MARK:- Test Translation (async)
If ($audioFile.exists)
	
	cs:C1710._TestSignal.me.init()
	
	CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.audio.translation($audioFile; "whisper-1"; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))
	
	cs:C1710._TestSignal.me.wait(30*1000)
	
	var $translationResult : cs:C1710.OpenAIAudioTranslationResult:=cs:C1710._TestSignal.me.result
	If (Asserted:C1132(Bool:C1537($translationResult.success); "Cannot translate audio (async): "+JSON Stringify:C1217($translationResult)))
		
		// Verify translation text
		$text:=$translationResult.text
		ASSERT:C1129(Length:C16($text)>0; "Async translation text must not be empty")
		
		// Verify translation object
		var $translation:=$translationResult.translation
		If (Asserted:C1132($translation#Null:C1517; "Async translation object must not be null"))
			ASSERT:C1129(Length:C16($translation.text)>0; "Async translation text in object must not be empty")
		End if 
		
	End if 
	
	cs:C1710._TestSignal.me.reset()
	
End if 

// MARK:- Clean up test files
If ($audioFile.exists)
	$audioFile.delete()
End if 
If ($testDataFolder.exists)
	$testDataFolder.delete(fk recursive:K87:7)
End if 
