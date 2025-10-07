//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// MARK:- Setup test data
var $testDataFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder("OpenAI_Test_Async")
If (Not:C34($testDataFolder.exists))
	$testDataFolder.create()
End if 

var $testFile:=$testDataFolder.file("test_async.jsonl")
var $testContent:=""
$testContent:=$testContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Marv is a factual chatbot that is also sarcastic.\"}, {\"role\": \"user\", \"content\": \"What's the capital of France?\"}, {\"role\": \"assistant\", \"content\": \"Paris, as if everyone doesn't know that already.\"}]}"+Char:C90(Line feed:K15:40)
$testFile.setText($testContent)

var $uploadedFileId:=""

// MARK:- Test file upload (async)
cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.files.create($testFile; "fine-tune"; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))

cs:C1710._TestSignal.me.wait(15*1000)

var $uploadResult : cs:C1710.OpenAIFileResult:=cs:C1710._TestSignal.me.result
If (Asserted:C1132(Bool:C1537($uploadResult.success); "Cannot upload file (async): "+JSON Stringify:C1217($uploadResult)))
	
	If (Asserted:C1132($uploadResult.file#Null:C1517; "Async uploaded file must not be null"))
		
		ASSERT:C1129(Length:C16(String:C10($uploadResult.file.id))>0; "Async file ID must not be empty")
		ASSERT:C1129(String:C10($uploadResult.file.object)="file"; "Object type must be 'file'")
		ASSERT:C1129(String:C10($uploadResult.file.purpose)="fine-tune"; "Purpose must match")
		ASSERT:C1129(String:C10($uploadResult.file.filename)="test_async.jsonl"; "Filename must match")
		ASSERT:C1129((Value type:C1509($uploadResult.file.bytes)=Is real:K8:4) && $uploadResult.file.bytes>0; "File size must be greater than 0")
		ASSERT:C1129((Value type:C1509($uploadResult.file.created_at)=Is real:K8:4) && $uploadResult.file.created_at>0; "Created timestamp must be set")
		
		$uploadedFileId:=$uploadResult.file.id
		
	End if 
	
End if 

cs:C1710._TestSignal.me.reset()

// MARK:- Test file retrieval (async)
If (Length:C16($uploadedFileId)>0)
	
	cs:C1710._TestSignal.me.init()
	
	CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.files.retrieve($uploadedFileId; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))
	
	cs:C1710._TestSignal.me.wait(10*1000)
	
	var $retrieveResult : cs:C1710.OpenAIFileResult:=cs:C1710._TestSignal.me.result
	If (Asserted:C1132(Bool:C1537($retrieveResult.success); "Cannot retrieve file (async): "+JSON Stringify:C1217($retrieveResult)))
		
		If (Asserted:C1132($retrieveResult.file#Null:C1517; "Async retrieved file must not be null"))
			
			ASSERT:C1129($retrieveResult.file.id=$uploadedFileId; "Retrieved file ID must match")
			ASSERT:C1129($retrieveResult.file.object="file"; "Object type must be 'file'")
			ASSERT:C1129($retrieveResult.file.purpose="fine-tune"; "Purpose must match")
			ASSERT:C1129($retrieveResult.file.filename="test_async.jsonl"; "Filename must match")
			
		End if 
		
	End if 
	
	cs:C1710._TestSignal.me.reset()
	
End if 

// MARK:- Test file listing (async)
cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.files.list({formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))

cs:C1710._TestSignal.me.wait(10*1000)

var $listResult : cs:C1710.OpenAIFileListResult:=cs:C1710._TestSignal.me.result
If (Asserted:C1132(Bool:C1537($listResult.success); "Cannot list files (async): "+JSON Stringify:C1217($listResult)))
	
	If (Asserted:C1132($listResult.files#Null:C1517; "Async files collection must not be null"))
		
		If (Asserted:C1132($listResult.files.length>0; "Async must have at least one file"))
			
			// Check if our uploaded file is in the list
			var $foundFile:=False:C215
			var $file : cs:C1710.OpenAIFile
			For each ($file; $listResult.files)
				If ($file.id=$uploadedFileId)
					$foundFile:=True:C214
					break
				End if 
			End for each 
			
			ASSERT:C1129($foundFile; "Uploaded file should be found in async file list")
			
		End if 
		
	End if 
	
End if 

cs:C1710._TestSignal.me.reset()

// MARK:- Test file listing with parameters (async)
var $listParams:=cs:C1710.OpenAIFileListParameters.new({\
purpose: "fine-tune"; \
limit: 5; \
order: "desc"; \
formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))\
})

cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.files.list($listParams)))

cs:C1710._TestSignal.me.wait(10*1000)

var $filteredListResult : cs:C1710.OpenAIFileListResult:=cs:C1710._TestSignal.me.result
If (Asserted:C1132(Bool:C1537($filteredListResult.success); "Cannot list files with parameters (async): "+JSON Stringify:C1217($filteredListResult)))
	
	If (Asserted:C1132($filteredListResult.files#Null:C1517; "Filtered async files collection must not be null"))
		
		// Verify that all returned files have the correct purpose
		For each ($file; $filteredListResult.files)
			ASSERT:C1129($file.purpose="fine-tune"; "All files should have 'fine-tune' purpose")
		End for each 
		
	End if 
	
End if 

cs:C1710._TestSignal.me.reset()

// MARK:- Test file upload with onResponse/onError (async)
var $testFile2:=$testDataFolder.file("test_async2.jsonl")
$testFile2.setText($testContent)

cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.files.create($testFile2; "user_data"; {\
onResponse: Formula:C1597(cs:C1710._TestSignal.me.trigger($1)); \
onError: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))\
})))

cs:C1710._TestSignal.me.wait(15*1000)

var $uploadResult2 : cs:C1710.OpenAIFileResult:=cs:C1710._TestSignal.me.result
If (Asserted:C1132(Bool:C1537($uploadResult2.success); "Cannot upload file with onResponse (async): "+JSON Stringify:C1217($uploadResult2)))
	
	If (Asserted:C1132($uploadResult2.file#Null:C1517; "onResponse uploaded file must not be null"))
		
		ASSERT:C1129(Length:C16(String:C10($uploadResult2.file.id))>0; "onResponse file ID must not be empty")
		ASSERT:C1129($uploadResult2.file.purpose="user_data"; "Purpose should be 'user_data'")
		
		// Clean up this file
		var $cleanupResult:=$client.files.delete($uploadResult2.file.id)
		ASSERT:C1129(Bool:C1537($cleanupResult.success); "Should be able to delete test file 2")
		
	End if 
	
End if 

cs:C1710._TestSignal.me.reset()

// MARK:- Test file deletion (async)
If (Length:C16($uploadedFileId)>0)
	
	cs:C1710._TestSignal.me.init()
	
	CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.files.delete($uploadedFileId; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))
	
	cs:C1710._TestSignal.me.wait(10*1000)
	
	var $deleteResult : cs:C1710.OpenAIFileDeletedResult:=cs:C1710._TestSignal.me.result
	If (Asserted:C1132(Bool:C1537($deleteResult.success); "Cannot delete file (async): "+JSON Stringify:C1217($deleteResult)))
		
		If (Asserted:C1132($deleteResult.deleted#Null:C1517; "Async delete result must not be null"))
			
			ASSERT:C1129($deleteResult.deleted.id=$uploadedFileId; "Deleted file ID must match")
			ASSERT:C1129($deleteResult.deleted.deleted=True:C214; "File should be marked as deleted")
			ASSERT:C1129($deleteResult.deleted.object="file"; "Object type must be 'file'")
			
		End if 
		
	End if 
	
	cs:C1710._TestSignal.me.reset()
	
	// Verify file is actually deleted by trying to retrieve it (async)
	cs:C1710._TestSignal.me.init()
	
	CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.files.retrieve($uploadedFileId; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))
	
	cs:C1710._TestSignal.me.wait(10*1000)
	
	var $verifyDeleteResult : cs:C1710.OpenAIFileResult:=cs:C1710._TestSignal.me.result
	ASSERT:C1129(Not:C34(Bool:C1537($verifyDeleteResult.success)); "Should not be able to retrieve deleted file (async)")
	
	cs:C1710._TestSignal.me.reset()
	
End if 

// MARK:- Test error handling for non-existent file (async)
cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.files.retrieve("file-nonexistent-async123"; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))

cs:C1710._TestSignal.me.wait(10*1000)

var $invalidResult : cs:C1710.OpenAIFileResult:=cs:C1710._TestSignal.me.result
If (Asserted:C1132(Not:C34(Bool:C1537($invalidResult.success)); "Should fail for non-existent file (async)"))
	
	ASSERT:C1129($invalidResult.request.response.status>=400; "Should return 4xx error status")
	
End if 

cs:C1710._TestSignal.me.reset()

// MARK:- Cleanup test files
If ($testFile.exists)
	$testFile.delete()
End if 
If ($testFile2.exists)
	$testFile2.delete()
End if 
If ($testDataFolder.exists)
	$testDataFolder.delete(fk recursive:K87:7)
End if 

// MARK:- Teardown
KILL WORKER:C1390(Current method name:C684)
