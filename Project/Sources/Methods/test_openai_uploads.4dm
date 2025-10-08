//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// MARK:- Setup: Create test data for multipart upload
var $testDataFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder("OpenAI_Upload_Test")
If (Not:C34($testDataFolder.exists))
	$testDataFolder.create()
End if 

// Create test content (simulating a large file split into parts)
var $totalSize:=0
var $chunks:=New collection:C1472
var $chunkFiles:=New collection:C1472

// Create 3 test chunks (simulating a file split into parts)
var $i; $j : Integer
For ($i; 1; 3)
	var $chunkFile:=$testDataFolder.file("chunk_"+String:C10($i)+".jsonl")
	var $chunkContent:=""
	
	// Add multiple lines to each chunk
	For ($j; 1; 5)
		$chunkContent:=$chunkContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Test chunk "+String:C10($i)+" line "+String:C10($j)+"\"}, {\"role\": \"user\", \"content\": \"Sample question "+String:C10($j)+"\"}, {\"role\": \"assistant\", \"content\": \"Sample answer "+String:C10($j)+"\"}]}"+Char:C90(Line feed:K15:40)
	End for 
	
	$chunkFile.setText($chunkContent)
	$chunkFiles.push($chunkFile)
	$totalSize:=$totalSize+$chunkFile.size
End for 

var $uploadId:=""
var $partIds:=New collection:C1472

// MARK:- Test 1: Create upload
var $uploadParams:=cs:C1710.OpenAIUploadParameters.new()

var $createResult:=$client.uploads.create("test_multipart.jsonl"; $totalSize; "fine-tune"; "text/jsonl"; $uploadParams)

If (Asserted:C1132(Bool:C1537($createResult.success); "Cannot create upload: "+JSON Stringify:C1217($createResult)))
	
	If (Asserted:C1132($createResult.upload#Null:C1517; "Upload must not be null"))
		
		ASSERT:C1129(Length:C16(String:C10($createResult.upload.id))>0; "Upload ID must not be empty")
		ASSERT:C1129(String:C10($createResult.upload.object)="upload"; "Object type must be 'upload'")
		ASSERT:C1129(String:C10($createResult.upload.status)="pending"; "Initial status must be 'pending'")
		ASSERT:C1129(String:C10($createResult.upload.filename)="test_multipart.jsonl"; "Filename must match")
		ASSERT:C1129(String:C10($createResult.upload.purpose)="fine-tune"; "Purpose must match")
		ASSERT:C1129($createResult.upload.bytes=$totalSize; "Bytes must match total size")
		// ASSERT(String($createResult.upload.mime_type)="text/jsonl"; "MIME type must match") // seems not in response...
		ASSERT:C1129((Value type:C1509($createResult.upload.created_at)=Is real:K8:4) && $createResult.upload.created_at>0; "Created timestamp must be set")
		ASSERT:C1129((Value type:C1509($createResult.upload.expires_at)=Is real:K8:4) && $createResult.upload.expires_at>0; "Expires timestamp must be set")
		
		$uploadId:=$createResult.upload.id
		
	End if 
	
End if 

// MARK:- Test 2: Add parts to upload
If (Length:C16($uploadId)>0)
	
	For each ($chunkFile; $chunkFiles)
		var $partParams:=cs:C1710.OpenAIParameters.new()
		var $partResult:=$client.uploads.addPart($uploadId; $chunkFile; $partParams)
		
		If (Asserted:C1132(Bool:C1537($partResult.success); "Cannot add part: "+JSON Stringify:C1217($partResult)))
			
			If (Asserted:C1132($partResult.part#Null:C1517; "Part must not be null"))
				
				ASSERT:C1129(Length:C16(String:C10($partResult.part.id))>0; "Part ID must not be empty")
				ASSERT:C1129(String:C10($partResult.part.object)="upload.part"; "Object type must be 'upload.part'")
				ASSERT:C1129(String:C10($partResult.part.upload_id)=$uploadId; "Part upload_id must match upload ID")
				ASSERT:C1129((Value type:C1509($partResult.part.created_at)=Is real:K8:4) && $partResult.part.created_at>0; "Part created timestamp must be set")
				
				$partIds.push($partResult.part.id)
				
			End if 
			
		End if 
	End for each 
	
End if 

// MARK:- Test 3: Complete upload
If (Length:C16($uploadId)>0) && ($partIds.length=3)
	
	var $completeParams:=cs:C1710.OpenAIUploadCompleteParameters.new()
	
	var $completeResult:=$client.uploads.complete($uploadId; $partIds; $completeParams)
	
	If (Asserted:C1132(Bool:C1537($completeResult.success); "Cannot complete upload: "+JSON Stringify:C1217($completeResult)))
		
		If (Asserted:C1132($completeResult.upload#Null:C1517; "Completed upload must not be null"))
			
			ASSERT:C1129(String:C10($completeResult.upload.id)=$uploadId; "Completed upload ID must match")
			ASSERT:C1129(String:C10($completeResult.upload.status)="completed"; "Status must be 'completed'")
			
			// Check if file object is present
			If (Asserted:C1132($completeResult.upload.file#Null:C1517; "File object must be present after completion"))
				
				ASSERT:C1129(Length:C16(String:C10($completeResult.upload.file.id))>0; "File ID must not be empty")
				ASSERT:C1129(String:C10($completeResult.upload.file.object)="file"; "File object type must be 'file'")
				ASSERT:C1129(String:C10($completeResult.upload.file.filename)="test_multipart.jsonl"; "File filename must match")
				ASSERT:C1129(String:C10($completeResult.upload.file.purpose)="fine-tune"; "File purpose must match")
				ASSERT:C1129($completeResult.upload.file.bytes>0; "File bytes must be greater than 0")
				
				// Clean up: delete the created file
				var $deleteResult:=$client.files.delete($completeResult.upload.file.id)
				ASSERT:C1129(Bool:C1537($deleteResult.success); "Should be able to delete the created file")
				
			End if 
			
		End if 
		
	End if 
	
End if 

// MARK:- Test 4: Create and cancel upload
var $cancelParams:=cs:C1710.OpenAIUploadParameters.new()

var $cancelCreateResult:=$client.uploads.create("test_cancel.jsonl"; 1000; "fine-tune"; "text/jsonl"; $cancelParams)

If (Asserted:C1132(Bool:C1537($cancelCreateResult.success); "Cannot create upload for cancel test: "+JSON Stringify:C1217($cancelCreateResult)))
	
	If (Asserted:C1132($cancelCreateResult.upload#Null:C1517; "Upload for cancel must not be null"))
		
		var $cancelUploadId:=$cancelCreateResult.upload.id
		
		// Cancel the upload
		var $cancelResult:=$client.uploads.cancel($cancelUploadId; cs:C1710.OpenAIParameters.new())
		
		If (Asserted:C1132(Bool:C1537($cancelResult.success); "Cannot cancel upload: "+JSON Stringify:C1217($cancelResult)))
			
			If (Asserted:C1132($cancelResult.upload#Null:C1517; "Cancelled upload must not be null"))
				
				ASSERT:C1129(String:C10($cancelResult.upload.id)=$cancelUploadId; "Cancelled upload ID must match")
				ASSERT:C1129(String:C10($cancelResult.upload.status)="cancelled"; "Status must be 'cancelled'")
				
			End if 
			
		End if 
		
	End if 
	
End if 

// MARK:- Test 5: Upload with Blob instead of File
var $blobUploadParams:=cs:C1710.OpenAIUploadParameters.new()

var $blobCreateResult:=$client.uploads.create("test_blob.jsonl"; 100; "fine-tune"; "text/jsonl"; $blobUploadParams)

If (Asserted:C1132(Bool:C1537($blobCreateResult.success); "Cannot create upload for blob test: "+JSON Stringify:C1217($blobCreateResult)))
	
	If (Asserted:C1132($blobCreateResult.upload#Null:C1517; "Blob upload must not be null"))
		
		var $blobUploadId:=$blobCreateResult.upload.id
		
		// Create a blob
		var $testBlob : Blob
		TEXT TO BLOB:C554("{\"messages\": [{\"role\": \"system\", \"content\": \"Test\"}]}"; $testBlob; UTF8 text without length:K22:17)
		
		// Add blob as part
		var $blobPartResult:=$client.uploads.addPart($blobUploadId; $testBlob; cs:C1710.OpenAIParameters.new())
		
		If (Asserted:C1132(Bool:C1537($blobPartResult.success); "Cannot add blob part: "+JSON Stringify:C1217($blobPartResult)))
			
			If (Asserted:C1132($blobPartResult.part#Null:C1517; "Blob part must not be null"))
				
				ASSERT:C1129(Length:C16(String:C10($blobPartResult.part.id))>0; "Blob part ID must not be empty")
				ASSERT:C1129(String:C10($blobPartResult.part.upload_id)=$blobUploadId; "Blob part upload_id must match")
				
				// Cancel this test upload (don't complete it)
				$client.uploads.cancel($blobUploadId; cs:C1710.OpenAIParameters.new())
				
			End if 
			
		End if 
		
	End if 
	
End if 

// MARK:- Test 6: Error handling - Invalid upload ID
var $invalidPartResult:=$client.uploads.addPart("invalid_upload_id"; $chunkFiles[0]; cs:C1710.OpenAIParameters.new())
ASSERT:C1129(Not:C34(Bool:C1537($invalidPartResult.success)); "Adding part to invalid upload ID should fail")

// MARK:- Test 7: Error handling - Complete with wrong part IDs
var $testUpload2:=$client.uploads.create("test_error.jsonl"; 1000; "fine-tune"; "text/jsonl"; cs:C1710.OpenAIUploadParameters.new())

If (Bool:C1537($testUpload2.success))
	var $wrongCompleteParams:=cs:C1710.OpenAIUploadCompleteParameters.new()
	
	var $wrongPartIds:=New collection:C1472("invalid_part_1"; "invalid_part_2")
	var $wrongCompleteResult:=$client.uploads.complete($testUpload2.upload.id; $wrongPartIds; $wrongCompleteParams)
	ASSERT:C1129(Not:C34(Bool:C1537($wrongCompleteResult.success)); "Completing with invalid part IDs should fail")
	
	// Clean up
	$client.uploads.cancel($testUpload2.upload.id; cs:C1710.OpenAIParameters.new())
End if 

// MARK:- Cleanup: Remove test folder
$testDataFolder.delete(Delete with contents:K24:24)
