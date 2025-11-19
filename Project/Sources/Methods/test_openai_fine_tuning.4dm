//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if

// MARK:- Create test training file for fine-tuning
var $testDataFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder("OpenAI_FineTuning_Test")
If (Not:C34($testDataFolder.exists))
	$testDataFolder.create()
End if

var $trainingFile:=$testDataFolder.file("training_data.jsonl")
var $trainingContent:=""
$trainingContent:=$trainingContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Marv is a factual chatbot that is also sarcastic.\"}, {\"role\": \"user\", \"content\": \"What's the capital of France?\"}, {\"role\": \"assistant\", \"content\": \"Paris, as if everyone doesn't know that already.\"}]}"+Char:C90(Line feed:K15:40)
$trainingContent:=$trainingContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Marv is a factual chatbot that is also sarcastic.\"}, {\"role\": \"user\", \"content\": \"Who wrote 'Romeo and Juliet'?\"}, {\"role\": \"assistant\", \"content\": \"Oh, just William Shakespeare. Ever heard of him?\"}]}"+Char:C90(Line feed:K15:40)
$trainingContent:=$trainingContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Marv is a factual chatbot that is also sarcastic.\"}, {\"role\": \"user\", \"content\": \"How far is the moon from Earth?\"}, {\"role\": \"assistant\", \"content\": \"Around 384,400 kilometers. Give or take a few, not that you're planning a trip or anything.\"}]}"+Char:C90(Line feed:K15:40)
$trainingContent:=$trainingContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Marv is a factual chatbot that is also sarcastic.\"}, {\"role\": \"user\", \"content\": \"What is 2+2?\"}, {\"role\": \"assistant\", \"content\": \"Four. Seriously? You needed a chatbot for that?\"}]}"+Char:C90(Line feed:K15:40)
$trainingContent:=$trainingContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Marv is a factual chatbot that is also sarcastic.\"}, {\"role\": \"user\", \"content\": \"What's the tallest mountain?\"}, {\"role\": \"assistant\", \"content\": \"Mount Everest, obviously. Standing at 8,849 meters.\"}]}"+Char:C90(Line feed:K15:40)
$trainingContent:=$trainingContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Marv is a factual chatbot that is also sarcastic.\"}, {\"role\": \"user\", \"content\": \"What is water made of?\"}, {\"role\": \"assistant\", \"content\": \"H2O. Two hydrogens, one oxygen. Chemistry 101.\"}]}"+Char:C90(Line feed:K15:40)
$trainingContent:=$trainingContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Marv is a factual chatbot that is also sarcastic.\"}, {\"role\": \"user\", \"content\": \"When did World War II end?\"}, {\"role\": \"assistant\", \"content\": \"1945. A pretty significant year, you might recall.\"}]}"+Char:C90(Line feed:K15:40)
$trainingContent:=$trainingContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Marv is a factual chatbot that is also sarcastic.\"}, {\"role\": \"user\", \"content\": \"What is the speed of light?\"}, {\"role\": \"assistant\", \"content\": \"299,792,458 meters per second. Fast enough for you?\"}]}"+Char:C90(Line feed:K15:40)
$trainingContent:=$trainingContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Marv is a factual chatbot that is also sarcastic.\"}, {\"role\": \"user\", \"content\": \"Who painted the Mona Lisa?\"}, {\"role\": \"assistant\", \"content\": \"Leonardo da Vinci. Renaissance genius and all that.\"}]}"+Char:C90(Line feed:K15:40)
$trainingContent:=$trainingContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Marv is a factual chatbot that is also sarcastic.\"}, {\"role\": \"user\", \"content\": \"What's the largest planet?\"}, {\"role\": \"assistant\", \"content\": \"Jupiter. It's basically huge, in case you were wondering.\"}]}"+Char:C90(Line feed:K15:40)

$trainingFile.setText($trainingContent)

var $uploadedFileId:=""
var $fineTuningJobId:=""

// MARK:- Upload training file
var $uploadResult:=$client.files.create($trainingFile; "fine-tune")

If (Asserted:C1132(Bool:C1537($uploadResult.success); "Cannot upload training file: "+JSON Stringify:C1217($uploadResult)))

	If (Asserted:C1132($uploadResult.file#Null:C1517; "Uploaded file must not be null"))

		$uploadedFileId:=$uploadResult.file.id
		ASSERT:C1129(Length:C16($uploadedFileId)>0; "File ID must not be empty")
		ASSERT:C1129($uploadResult.file.purpose="fine-tune"; "File purpose must be 'fine-tune'")

	End if

End if

// MARK:- Test creating a fine-tuning job
If (Length:C16($uploadedFileId)>0)

	var $params:=cs:C1710.OpenAIFineTuningJobParameters.new()
	$params.suffix:="test-model"
	$params.seed:=42

	// Add metadata
	$params.metadata:={}
	$params.metadata.test:="automated"
	$params.metadata.purpose:="unit-test"

	var $createResult:=$client.fineTuning.create("gpt-4o-mini-2024-07-18"; $uploadedFileId; $params)

	If (Asserted:C1132(Bool:C1537($createResult.success); "Cannot create fine-tuning job: "+JSON Stringify:C1217($createResult)))

		If (Asserted:C1132($createResult.job#Null:C1517; "Created job must not be null"))

			$fineTuningJobId:=$createResult.job.id
			ASSERT:C1129(Length:C16($fineTuningJobId)>0; "Job ID must not be empty")
			ASSERT:C1129($createResult.job.object="fine_tuning.job"; "Object type must be 'fine_tuning.job'")
			ASSERT:C1129($createResult.job.model="gpt-4o-mini-2024-07-18"; "Base model must match")
			ASSERT:C1129($createResult.job.training_file=$uploadedFileId; "Training file ID must match")
			ASSERT:C1129(($createResult.job.status="queued") || ($createResult.job.status="running"); "Initial status should be 'queued' or 'running'")
			ASSERT:C1129($createResult.job.created_at>0; "Created timestamp must be set")
			ASSERT:C1129($createResult.job.seed=42; "Seed must match")

			// Check metadata
			If (Asserted:C1132($createResult.job.metadata#Null:C1517; "Metadata should be set"))
				ASSERT:C1129($createResult.job.metadata.test="automated"; "Metadata test field must match")
				ASSERT:C1129($createResult.job.metadata.purpose="unit-test"; "Metadata purpose field must match")
			End if

		End if

	End if

End if

// MARK:- Test retrieving a fine-tuning job
If (Length:C16($fineTuningJobId)>0)

	var $retrieveResult:=$client.fineTuning.retrieve($fineTuningJobId)

	If (Asserted:C1132(Bool:C1537($retrieveResult.success); "Cannot retrieve fine-tuning job: "+JSON Stringify:C1217($retrieveResult)))

		If (Asserted:C1132($retrieveResult.job#Null:C1517; "Retrieved job must not be null"))

			ASSERT:C1129($retrieveResult.job.id=$fineTuningJobId; "Retrieved job ID must match")
			ASSERT:C1129($retrieveResult.job.object="fine_tuning.job"; "Object type must be 'fine_tuning.job'")
			ASSERT:C1129($retrieveResult.job.model="gpt-4o-mini-2024-07-18"; "Base model must match")
			ASSERT:C1129($retrieveResult.job.training_file=$uploadedFileId; "Training file ID must match")

		End if

	End if

End if

// MARK:- Test listing fine-tuning jobs
var $listResult:=$client.fineTuning.list()

If (Asserted:C1132(Bool:C1537($listResult.success); "Cannot list fine-tuning jobs: "+JSON Stringify:C1217($listResult)))

	If (Asserted:C1132($listResult.jobs#Null:C1517; "Jobs collection must not be null"))

		If (Asserted:C1132($listResult.jobs.length>0; "Must have at least one job"))

			// Check if our created job is in the list
			var $foundJob:=False:C215
			var $job : cs:C1710.OpenAIFineTuningJob
			For each ($job; $listResult.jobs)
				If ($job.id=$fineTuningJobId)
					$foundJob:=True:C214
					break
				End if
			End for each

			ASSERT:C1129($foundJob; "Created job should be found in job list")

		End if

	End if

End if

// MARK:- Test listing jobs with parameters
var $listParams:=cs:C1710.OpenAIFineTuningJobListParameters.new()
$listParams.limit:=5

var $filteredListResult:=$client.fineTuning.list($listParams)

If (Asserted:C1132(Bool:C1537($filteredListResult.success); "Cannot list fine-tuning jobs with parameters: "+JSON Stringify:C1217($filteredListResult)))

	If (Asserted:C1132($filteredListResult.jobs#Null:C1517; "Filtered jobs collection must not be null"))

		// Verify limit is respected (should return at most 5 jobs)
		ASSERT:C1129($filteredListResult.jobs.length<=5; "Should not return more than 5 jobs")

	End if

End if

// MARK:- Test listing job events
If (Length:C16($fineTuningJobId)>0)

	var $eventsParams:=cs:C1710.OpenAIFineTuningJobListParameters.new()
	$eventsParams.limit:=20

	var $eventsResult:=$client.fineTuning.listEvents($fineTuningJobId; $eventsParams)

	If (Asserted:C1132(Bool:C1537($eventsResult.success); "Cannot list fine-tuning job events: "+JSON Stringify:C1217($eventsResult)))

		If (Asserted:C1132($eventsResult.events#Null:C1517; "Events collection must not be null"))

			// Jobs should have at least one event (creation event)
			If ($eventsResult.events.length>0)
				var $event : cs:C1710.OpenAIFineTuningEvent:=$eventsResult.events[0]
				ASSERT:C1129(Length:C16($event.id)>0; "Event ID must not be empty")
				ASSERT:C1129($event.object="fine_tuning.job.event"; "Event object type must be 'fine_tuning.job.event'")
				ASSERT:C1129(Length:C16($event.message)>0; "Event message must not be empty")
				ASSERT:C1129(($event.level="info") || ($event.level="warn") || ($event.level="error"); "Event level must be valid")
				ASSERT:C1129($event.created_at>0; "Event created timestamp must be set")
			End if

		End if

	End if

End if

// MARK:- Test cancelling a fine-tuning job
If (Length:C16($fineTuningJobId)>0)

	var $cancelResult:=$client.fineTuning.cancel($fineTuningJobId)

	If (Asserted:C1132(Bool:C1537($cancelResult.success); "Cannot cancel fine-tuning job: "+JSON Stringify:C1217($cancelResult)))

		If (Asserted:C1132($cancelResult.job#Null:C1517; "Cancelled job must not be null"))

			ASSERT:C1129($cancelResult.job.id=$fineTuningJobId; "Cancelled job ID must match")
			ASSERT:C1129($cancelResult.job.status="cancelled"; "Job status should be 'cancelled'")

		End if

	End if

End if

// MARK:- Test error handling for non-existent job
var $invalidResult:=$client.fineTuning.retrieve("ftjob-nonexistent123")

If (Asserted:C1132(Not:C34(Bool:C1537($invalidResult.success)); "Should fail for non-existent job"))

	ASSERT:C1129($invalidResult.request.response.status>=400; "Should return 4xx error status")

End if

// MARK:- Test parameter validation
// Test that create throws with empty model
var $lastErrors:=Last errors:C1799
Try($client.fineTuning.create(""; $uploadedFileId))
$lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error with empty model"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("model"; $lastErrors[0].message)>0; "Error should mention model parameter")
End if

// Test that create throws with empty training_file
Try($client.fineTuning.create("gpt-4o-mini-2024-07-18"; ""))
$lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error with empty training_file"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("training_file"; $lastErrors[0].message)>0; "Error should mention training_file parameter")
End if

// Test that retrieve throws with empty job ID
Try($client.fineTuning.retrieve(""))
$lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error with empty job ID"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("fineTuningJobId"; $lastErrors[0].message)>0; "Error should mention fineTuningJobId parameter")
End if

// Test that cancel throws with empty job ID
Try($client.fineTuning.cancel(""))
$lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error with empty job ID for cancellation"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("fineTuningJobId"; $lastErrors[0].message)>0; "Error should mention fineTuningJobId parameter")
End if

// Test that listEvents throws with empty job ID
Try($client.fineTuning.listEvents(""))
$lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error with empty job ID for list events"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("fineTuningJobId"; $lastErrors[0].message)>0; "Error should mention fineTuningJobId parameter")
End if

Try(True:C214)  // Reset errors

// MARK:- Cleanup uploaded file
If (Length:C16($uploadedFileId)>0)

	var $deleteResult:=$client.files.delete($uploadedFileId)
	ASSERT:C1129(Bool:C1537($deleteResult.success); "Should be able to delete uploaded training file")

End if

// MARK:- Cleanup test files
If ($trainingFile.exists)
	$trainingFile.delete()
End if
If ($testDataFolder.exists)
	$testDataFolder.delete(fk recursive:K87:7)
End if
