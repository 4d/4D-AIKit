//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// MARK:- Setup: Create test data
var $testDataFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder("OpenAI_Upload_Test_Async")
If (Not:C34($testDataFolder.exists))
	$testDataFolder.create()
End if 

// Create test chunks
var $totalSize:=0
var $chunkFiles:=New collection:C1472

var $i; $j : Integer
For ($i; 1; 3)
	var $chunkFile:=$testDataFolder.file("async_chunk_"+String:C10($i)+".jsonl")
	var $chunkContent:=""
	
	For ($j; 1; 5)
		$chunkContent:=$chunkContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Async test chunk "+String:C10($i)+" line "+String:C10($j)+"\"}, {\"role\": \"user\", \"content\": \"Q"+String:C10($j)+"\"}, {\"role\": \"assistant\", \"content\": \"A"+String:C10($j)+"\"}]}"+Char:C90(Line feed:K15:40)
	End for 
	
	$chunkFile.setText($chunkContent)
	$chunkFiles.push($chunkFile)
	$totalSize:=$totalSize+$chunkFile.size
End for 

var $uploadId:=""
var $partIds:=New collection:C1472

// MARK:- Test 1: Create upload (async)
cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.uploads.create("test_async_multipart.jsonl"; $totalSize; "fine-tune"; "text/jsonl"; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))

cs:C1710._TestSignal.me.wait(15*1000)

var $createResult : cs:C1710.OpenAIUploadResult:=cs:C1710._TestSignal.me.result

If (Asserted:C1132(Bool:C1537($createResult.success); "Cannot create upload (async): "+JSON Stringify:C1217($createResult)))
	
	If (Asserted:C1132($createResult.upload#Null:C1517; "Async upload must not be null"))
		
		ASSERT:C1129(Length:C16(String:C10($createResult.upload.id))>0; "Async upload ID must not be empty")
		ASSERT:C1129(String:C10($createResult.upload.object)="upload"; "Object type must be 'upload'")
		ASSERT:C1129(String:C10($createResult.upload.status)="pending"; "Initial status must be 'pending'")
		ASSERT:C1129(String:C10($createResult.upload.filename)="test_async_multipart.jsonl"; "Filename must match")
		ASSERT:C1129(String:C10($createResult.upload.purpose)="fine-tune"; "Purpose must match")
		ASSERT:C1129($createResult.upload.bytes=$totalSize; "Bytes must match")
		
		$uploadId:=$createResult.upload.id
		
	End if 
	
End if 

cs:C1710._TestSignal.me.reset()

// MARK:- Test 2: Add parts (async)
If (Length:C16($uploadId)>0)
	
	For each ($chunkFile; $chunkFiles)
		cs:C1710._TestSignal.me.init()
		
		CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.uploads.addPart($uploadId; $chunkFile; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))
		
		cs:C1710._TestSignal.me.wait(15*1000)
		
		var $partResult : cs:C1710.OpenAIUploadPartResult:=cs:C1710._TestSignal.me.result
		
		If (Asserted:C1132(Bool:C1537($partResult.success); "Cannot add part (async): "+JSON Stringify:C1217($partResult)))
			
			If (Asserted:C1132($partResult.part#Null:C1517; "Async part must not be null"))
				
				ASSERT:C1129(Length:C16(String:C10($partResult.part.id))>0; "Async part ID must not be empty")
				ASSERT:C1129(String:C10($partResult.part.object)="upload.part"; "Object type must be 'upload.part'")
				ASSERT:C1129(String:C10($partResult.part.upload_id)=$uploadId; "Part upload_id must match")
				
				$partIds.push($partResult.part.id)
				
			End if 
			
		End if 
		
		cs:C1710._TestSignal.me.reset()
		
	End for each 
	
End if 

// MARK:- Test 3: Complete upload (async)
If (Length:C16($uploadId)>0) && ($partIds.length=3)
	
	cs:C1710._TestSignal.me.init()
	
	CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.uploads.complete($uploadId; $partIds; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))
	
	cs:C1710._TestSignal.me.wait(15*1000)
	
	var $completeResult : cs:C1710.OpenAIUploadResult:=cs:C1710._TestSignal.me.result
	
	If (Asserted:C1132(Bool:C1537($completeResult.success); "Cannot complete upload (async): "+JSON Stringify:C1217($completeResult)))
		
		If (Asserted:C1132($completeResult.upload#Null:C1517; "Async completed upload must not be null"))
			
			ASSERT:C1129(String:C10($completeResult.upload.id)=$uploadId; "Async completed upload ID must match")
			ASSERT:C1129(String:C10($completeResult.upload.status)="completed"; "Status must be 'completed'")
			
			If (Asserted:C1132($completeResult.upload.file#Null:C1517; "File object must be present"))
				
				ASSERT:C1129(Length:C16(String:C10($completeResult.upload.file.id))>0; "File ID must not be empty")
				ASSERT:C1129(String:C10($completeResult.upload.file.object)="file"; "File object type must be 'file'")
				ASSERT:C1129(String:C10($completeResult.upload.file.filename)="test_async_multipart.jsonl"; "Filename must match")
				
				// Clean up: delete the created file (async)
				cs:C1710._TestSignal.me.reset()
				cs:C1710._TestSignal.me.init()
				
				CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.files.delete($completeResult.upload.file.id; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))
				
				cs:C1710._TestSignal.me.wait(10*1000)
				
				var $deleteResult : cs:C1710.OpenAIFileDeletedResult:=cs:C1710._TestSignal.me.result
				ASSERT:C1129(Bool:C1537($deleteResult.success); "Should be able to delete the created file (async)")
				
			End if 
			
		End if 
		
	End if 
	
	cs:C1710._TestSignal.me.reset()
	
End if 

// MARK:- Test 4: Cancel upload (async)
cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.uploads.create("test_async_cancel.jsonl"; 1000; "fine-tune"; "text/jsonl"; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))

cs:C1710._TestSignal.me.wait(15*1000)

var $cancelCreateResult : cs:C1710.OpenAIUploadResult:=cs:C1710._TestSignal.me.result

If (Asserted:C1132(Bool:C1537($cancelCreateResult.success); "Cannot create upload for async cancel test: "+JSON Stringify:C1217($cancelCreateResult)))
	
	If (Asserted:C1132($cancelCreateResult.upload#Null:C1517; "Upload for async cancel must not be null"))
		
		var $cancelUploadId:=$cancelCreateResult.upload.id
		
		cs:C1710._TestSignal.me.reset()
		cs:C1710._TestSignal.me.init()
		
		// Cancel the upload
		CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.uploads.cancel($cancelUploadId; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))
		
		cs:C1710._TestSignal.me.wait(15*1000)
		
		var $cancelResult : cs:C1710.OpenAIUploadResult:=cs:C1710._TestSignal.me.result
		
		If (Asserted:C1132(Bool:C1537($cancelResult.success); "Cannot cancel upload (async): "+JSON Stringify:C1217($cancelResult)))
			
			If (Asserted:C1132($cancelResult.upload#Null:C1517; "Cancelled upload must not be null"))
				
				ASSERT:C1129(String:C10($cancelResult.upload.id)=$cancelUploadId; "Async cancelled upload ID must match")
				ASSERT:C1129(String:C10($cancelResult.upload.status)="cancelled"; "Status must be 'cancelled'")
				
			End if 
			
		End if 
		
	End if 
	
End if 

cs:C1710._TestSignal.me.reset()

// MARK:- Test 5: Using onResponse/onError callbacks
cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.uploads.create("test_callback.jsonl"; 500; "fine-tune"; "text/jsonl"; {\
onResponse: Formula:C1597(cs:C1710._TestSignal.me.trigger($1)); \
onError: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))\
})))

cs:C1710._TestSignal.me.wait(15*1000)

var $callbackResult : cs:C1710.OpenAIUploadResult:=cs:C1710._TestSignal.me.result

If (Asserted:C1132(Bool:C1537($callbackResult.success); "Cannot create upload with callbacks (async): "+JSON Stringify:C1217($callbackResult)))
	
	If (Asserted:C1132($callbackResult.upload#Null:C1517; "Callback upload must not be null"))
		
		ASSERT:C1129(Length:C16(String:C10($callbackResult.upload.id))>0; "Callback upload ID must not be empty")
		ASSERT:C1129(String:C10($callbackResult.upload.status)="pending"; "Callback upload status must be 'pending'")
		
		// Cancel this test upload
		$client.uploads.cancel($callbackResult.upload.id; cs:C1710.OpenAIParameters.new())
		
	End if 
	
End if 

cs:C1710._TestSignal.me.reset()

// MARK:- Cleanup: Remove test folder
$testDataFolder.delete(Delete with contents:K24:24)

KILL WORKER:C1390(Current method name:C684)
