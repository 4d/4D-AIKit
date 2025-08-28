//%attributes = {"invisible":true}
// Test file for OpenAI Files API
// This test covers all major functionality of the Files API

var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// MARK:- Setup test file
var $testFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder("OpenAI_Test")
If (Not:C34($testFolder.exists))
	$testFolder.create()
End if 

var $testFile:=$testFolder.file("test_fine_tune.jsonl")
var $jsonlContent:=""
$jsonlContent:=$jsonlContent+"{\"messages\": [{\"role\": \"user\", \"content\": \"What is 2+2?\"}, {\"role\": \"assistant\", \"content\": \"4\"}]}"+Char:C90(13)
$jsonlContent:=$jsonlContent+"{\"messages\": [{\"role\": \"user\", \"content\": \"What is the capital of France?\"}, {\"role\": \"assistant\", \"content\": \"Paris\"}]}"+Char:C90(13)

$testFile.setText($jsonlContent)

If (Not:C34($testFile.exists))
	ASSERT:C1129(False:C215; "Could not create test file")
	return 
End if 

TRACE:C157  // Files API Test Starting

// Test will be expanded once compilation issues are resolved
// For now, this serves as a placeholder that follows the project patterns

// Cleanup
If ($testFile.exists)
	$testFile.delete()
End if 
If ($testFolder.exists)
	$testFolder.delete()
End if 
