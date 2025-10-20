//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// MARK:- Create test file for upload
var $testDataFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder("OpenAI_Test_Data")
If (Not:C34($testDataFolder.exists))
	$testDataFolder.create()
End if 

var $testFile:=$testDataFolder.file("test_data.jsonl")
var $testContent:=""
$testContent:=$testContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Marv is a factual chatbot that is also sarcastic.\"}, {\"role\": \"user\", \"content\": \"What's the capital of France?\"}, {\"role\": \"assistant\", \"content\": \"Paris, as if everyone doesn't know that already.\"}]}"+Char:C90(Line feed:K15:40)
$testContent:=$testContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Marv is a factual chatbot that is also sarcastic.\"}, {\"role\": \"user\", \"content\": \"Who wrote 'Romeo and Juliet'?\"}, {\"role\": \"assistant\", \"content\": \"Oh, just William Shakespeare. Ever heard of him?\"}]}"+Char:C90(Line feed:K15:40)
$testContent:=$testContent+"{\"messages\": [{\"role\": \"system\", \"content\": \"Marv is a factual chatbot that is also sarcastic.\"}, {\"role\": \"user\", \"content\": \"How far is the moon from Earth?\"}, {\"role\": \"assistant\", \"content\": \"Around 384,400 kilometers. Give or take a few, not that"+" you're planning a trip or anything.\"}]}"+Char:C90(Line feed:K15:40)

$testFile.setText($testContent)

var $uploadedFileId:=""

// MARK:- Test file upload
var $uploadResult:=$client.files.create($testFile; "fine-tune")

If (Asserted:C1132(Bool:C1537($uploadResult.success); "Cannot upload file: "+JSON Stringify:C1217($uploadResult)))
	
	If (Asserted:C1132($uploadResult.file#Null:C1517; "File must not be null"))
		
		ASSERT:C1129(Length:C16(String:C10($uploadResult.file.id))>0; "File ID must not be empty")
		ASSERT:C1129(String:C10($uploadResult.file.object)="file"; "Object type must be 'file'")
		ASSERT:C1129(String:C10($uploadResult.file.purpose)="fine-tune"; "Purpose must match")
		ASSERT:C1129(String:C10($uploadResult.file.filename)="test_data.jsonl"; "Filename must match")
		ASSERT:C1129((Value type:C1509($uploadResult.file.bytes)=Is real:K8:4) && $uploadResult.file.bytes>0; "File size must be greater than 0")
		ASSERT:C1129((Value type:C1509($uploadResult.file.created_at)=Is real:K8:4) && $uploadResult.file.created_at>0; "Created timestamp must be set")
		
		$uploadedFileId:=$uploadResult.file.id
		
	End if 
	
End if 

// MARK:- Test file retrieval  
If (Length:C16($uploadedFileId)>0)
	
	var $retrieveResult:=$client.files.retrieve($uploadedFileId)
	
	If (Asserted:C1132(Bool:C1537($retrieveResult.success); "Cannot retrieve file: "+JSON Stringify:C1217($retrieveResult)))
		
		If (Asserted:C1132($retrieveResult.file#Null:C1517; "Retrieved file must not be null"))
			
			ASSERT:C1129($retrieveResult.file.id=$uploadedFileId; "Retrieved file ID must match")
			ASSERT:C1129($retrieveResult.file.object="file"; "Object type must be 'file'")
			ASSERT:C1129($retrieveResult.file.purpose="fine-tune"; "Purpose must match")
			ASSERT:C1129($retrieveResult.file.filename="test_data.jsonl"; "Filename must match")
			
		End if 
		
	End if 
	
End if 

// MARK:- Test file listing
var $listResult:=$client.files.list()

If (Asserted:C1132(Bool:C1537($listResult.success); "Cannot list files: "+JSON Stringify:C1217($listResult)))
	
	If (Asserted:C1132($listResult.files#Null:C1517; "Files collection must not be null"))
		
		If (Asserted:C1132($listResult.files.length>0; "Must have at least one file"))
			
			// Check if our uploaded file is in the list
			var $foundFile:=False:C215
			var $file : cs:C1710.OpenAIFile
			For each ($file; $listResult.files)
				If ($file.id=$uploadedFileId)
					$foundFile:=True:C214
					break
				End if 
			End for each 
			
			ASSERT:C1129($foundFile; "Uploaded file should be found in file list")
			
		End if 
		
	End if 
	
End if 

// MARK:- Test file listing with parameters
var $listParams:=cs:C1710.OpenAIFileListParameters.new({\
purpose: "fine-tune"; \
limit: 5; \
order: "desc"\
})

var $filteredListResult:=$client.files.list($listParams)

If (Asserted:C1132(Bool:C1537($filteredListResult.success); "Cannot list files with parameters: "+JSON Stringify:C1217($filteredListResult)))
	
	If (Asserted:C1132($filteredListResult.files#Null:C1517; "Filtered files collection must not be null"))
		
		// Verify that all returned files have the correct purpose
		For each ($file; $filteredListResult.files)
			ASSERT:C1129($file.purpose="fine-tune"; "All files should have 'fine-tune' purpose")
		End for each 
		
		// Verify limit is respected
		//ASSERT($filteredListResult.files.length<=5; "Should not return more than 5 files")
		
	End if 
	
End if 

// MARK:- Test file listing pagination
var $paginationParams:=cs:C1710.OpenAIFileListParameters.new({\
limit: 2; \
order: "asc"\
})

var $firstPage:=$client.files.list($paginationParams)

If (Asserted:C1132(Bool:C1537($firstPage.success); "Cannot list first page for pagination test: "+JSON Stringify:C1217($firstPage)))
	If (Asserted:C1132($firstPage.files#Null:C1517; "First page files must not be null"))
		If (Asserted:C1132($firstPage.files.length>0; "First page must have at least one file"))
			var $lastFile : cs:C1710.OpenAIFile:=$firstPage.files.last()
			var $lastFileId:=$lastFile.id
			// Set after parameter to paginate
			$paginationParams.after:=$lastFileId
			var $secondPage:=$client.files.list($paginationParams)
			If (Asserted:C1132(Bool:C1537($secondPage.success); "Cannot list second page for pagination test: "+JSON Stringify:C1217($secondPage)))
				If (Asserted:C1132($secondPage.files#Null:C1517; "Second page files must not be null"))
					// Verify second page does not include lastFileId from first page
					var $found:=False:C215
					For each ($file; $secondPage.files)
						If ($file.id=$lastFileId)
							$found:=True:C214
							break
						End if 
					End for each 
					ASSERT:C1129($found=False:C215; "Second page should not include last file from first page")
				End if 
			End if 
		End if 
	End if 
End if 

// MARK:- Test file creation with expires_after parameter
var $expirationParams:=cs:C1710.OpenAIFileParameters.new({\
expires_after: {anchor: "created_at"; seconds: 3600}\
})

var $tempFile:=$testDataFolder.file("temp.jsonl")
$tempFile.setText("test")

var $expiryResult:=$client.files.create($tempFile; "user_data"; $expirationParams)

If (Asserted:C1132(Bool:C1537($expiryResult.success); "Cannot create file with expires_after: "+JSON Stringify:C1217($expiryResult)))
	If (Asserted:C1132($expiryResult.file#Null:C1517; "Expiry result file must not be null"))
		ASSERT:C1129($expiryResult.file.expires_at>0; "File should have expiration timestamp")
		// Clean up remote file
		var $cleanupExpiry:=$client.files.delete($expiryResult.file.id)
		ASSERT:C1129(Bool:C1537($cleanupExpiry.success); "Should be able to delete expiry file")
	End if 
End if 

// Cleanup local temp file
If ($tempFile.exists)
	$tempFile.delete()
End if 

// MARK:- Test file content retrieval
If ((Length:C16($uploadedFileId)>0) && False:C215)  // Disabled as OpenAI may restrict content access
	
	var $contentResult:=$client.files._content($uploadedFileId)
	
	If (Asserted:C1132(Bool:C1537($contentResult.success); "Cannot retrieve file content: "+JSON Stringify:C1217($contentResult)))
		
		// Check that we got some content back
		If (Asserted:C1132($contentResult.request.response.body#Null:C1517; "File content must not be null"))
			
			var $retrievedContent:=""
			Case of 
				: (Value type:C1509($contentResult.request.response.body)=Is text:K8:3)
					$retrievedContent:=$contentResult.request.response.body
				: (Value type:C1509($contentResult.request.response.body)=Is BLOB:K8:12)
					$retrievedContent:=Convert to text:C1012($contentResult.request.response.body; "UTF-8")
			End case 
			
			ASSERT:C1129(Length:C16($retrievedContent)>0; "File content should not be empty")
			ASSERT:C1129(Position:C15("messages"; $retrievedContent)>0; "Content should contain expected JSONL structure")
			
		End if 
		
	End if 
	
End if 

// MARK:- Test error handling for non-existent file
var $invalidResult:=$client.files.retrieve("file-nonexistent123")

If (Asserted:C1132(Not:C34(Bool:C1537($invalidResult.success)); "Should fail for non-existent file"))
	
	ASSERT:C1129($invalidResult.request.response.status>=400; "Should return 4xx error status")
	
End if 

// MARK:- Test file deletion
If (Length:C16($uploadedFileId)>0)
	
	var $deleteResult:=$client.files.delete($uploadedFileId)
	
	If (Asserted:C1132(Bool:C1537($deleteResult.success); "Cannot delete file: "+JSON Stringify:C1217($deleteResult)))
		
		If (Asserted:C1132($deleteResult.deleted#Null:C1517; "Delete result must not be null"))
			
			ASSERT:C1129($deleteResult.deleted.id=$uploadedFileId; "Deleted file ID must match")
			ASSERT:C1129($deleteResult.deleted.deleted=True:C214; "File should be marked as deleted")
			ASSERT:C1129($deleteResult.deleted.object="file"; "Object type must be 'file'")
			
		End if 
		
	End if 
	
	// Verify file is actually deleted by trying to retrieve it
	var $verifyDeleteResult:=$client.files.retrieve($uploadedFileId)
	ASSERT:C1129(Not:C34(Bool:C1537($verifyDeleteResult.success)); "Should not be able to retrieve deleted file")
	
End if 

// MARK:- Test parameter validation
// Test that create throws with null file
var $didThrow:=False:C215
Try($client.files.create(Null:C1517; "fine-tune"))
var $lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error with null file"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("file"; $lastErrors[0].message)>0; "Error should mention file parameter")
End if 

// Test that create throws with empty purpose
Try($client.files.create($testFile; ""))
$lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error with empty purpose"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("purpose"; $lastErrors[0].message)>0; "Error should mention purpose parameter")
End if 

// Test that retrieve throws with empty file ID
Try($client.files.retrieve(""))
$lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error with empty file ID"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("fileId"; $lastErrors[0].message)>0; "Error should mention fileId parameter")
End if 

// Test that delete throws with empty file ID
Try($client.files.delete(""))
$lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error with empty file ID for deletion"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("fileId"; $lastErrors[0].message)>0; "Error should mention fileId parameter")
End if 

Try(True:C214)  // Reset errors

// MARK:- Test uploading Blob (binary file - PDF)
// Create a PDF blob from base64 https://www.emcken.dk/programming/2024/01/12/very-small-pdf-for-testing/
var $pdfBase64:="JVBERi0xLjQKMSAwIG9iago8PC9UeXBlIC9DYXRhbG9nCi9QYWdlcyAyIDAgUgo+PgplbmRvYmoK"
$pdfBase64+="MiAwIG9iago8PC9UeXBlIC9QYWdlcwovS2lkcyBbMyAwIFJdCi9Db3VudCAxCj4+CmVuZG9iagoz"
$pdfBase64+="IDAgb2JqCjw8L1R5cGUgL1BhZ2UKL1BhcmVudCAyIDAgUgovTWVkaWFCb3ggWzAgMCA1OTUgODQy"
$pdfBase64+="XQovQ29udGVudHMgNSAwIFIKL1Jlc291cmNlcyA8PC9Qcm9jU2V0IFsvUERGIC9UZXh0XQovRm9u"
$pdfBase64+="dCA8PC9GMSA0IDAgUj4+Cj4+Cj4+CmVuZG9iago0IDAgb2JqCjw8L1R5cGUgL0ZvbnQKL1N1YnR5"
$pdfBase64+="cGUgL1R5cGUxCi9OYW1lIC9GMQovQmFzZUZvbnQgL0hlbHZldGljYQovRW5jb2RpbmcgL01hY1Jv"
$pdfBase64+="bWFuRW5jb2RpbmcKPj4KZW5kb2JqCjUgMCBvYmoKPDwvTGVuZ3RoIDUzCj4+CnN0cmVhbQpCVAov"
$pdfBase64+="RjEgMjAgVGYKMjIwIDQwMCBUZAooRHVtbXkgUERGKSBUagpFVAplbmRzdHJlYW0KZW5kb2JqCnhy"
$pdfBase64+="ZWYKMCA2CjAwMDAwMDAwMDAgNjU1MzUgZgowMDAwMDAwMDA5IDAwMDAwIG4KMDAwMDAwMDA2MyAw"
$pdfBase64+="MDAwMCBuCjAwMDAwMDAxMjQgMDAwMDAgbgowMDAwMDAwMjc3IDAwMDAwIG4KMDAwMDAwMDM5MiAw"
$pdfBase64+="MDAwMCBuCnRyYWlsZXIKPDwvU2l6ZSA2Ci9Sb290IDEgMCBSCj4+CnN0YXJ0eHJlZgo0OTUKJSVF"
$pdfBase64+="T0YK"

var $pdfBlob : Blob  // :=4D.Blob.new()
BASE64 DECODE:C896($pdfBase64; $pdfBlob)

// Test uploading blob with user_data purpose
var $blobUploadResult:=$client.files.create($pdfBlob; "user_data"; {filename: "test.pdf"})

If (Asserted:C1132(Bool:C1537($blobUploadResult.success); "Cannot upload blob file: "+JSON Stringify:C1217($blobUploadResult)))
	
	If (Asserted:C1132($blobUploadResult.file#Null:C1517; "Blob upload file must not be null"))
		
		ASSERT:C1129(Length:C16(String:C10($blobUploadResult.file.id))>0; "Blob upload file ID must not be empty")
		ASSERT:C1129($blobUploadResult.file.object="file"; "Object type must be 'file'")
		ASSERT:C1129($blobUploadResult.file.purpose="user_data"; "Purpose should be 'user_data'")
		ASSERT:C1129($blobUploadResult.file.bytes>0; "File size must be greater than 0")
		ASSERT:C1129($blobUploadResult.file.created_at>0; "Created timestamp must be set")
		ASSERT:C1129(String:C10($blobUploadResult.file.filename)="test.pdf"; "Created filename must be used:"+String:C10($blobUploadResult.file.filename))
		
		
		var $modelName:=cs:C1710._TestModels.new($client).chats
		var $messages:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant."})]
		var $message:=cs:C1710.OpenAIMessage.new({role: "user"; content: "Could you write what is writted in the document"})
		$message.addFileId($blobUploadResult.file.id)
		$messages.push($message)
		
		var $result:=$client.chat.completions.create($messages; {model: $modelName})
		
		ASSERT:C1129(Bool:C1537($result.success); "Should be able to talk with a file")
		
		
		// Clean up
		var $cleanupResult:=$client.files.delete($blobUploadResult.file.id)
		ASSERT:C1129(Bool:C1537($cleanupResult.success); "Should be able to delete blob file")
		
	End if 
	
End if 

// MARK:- Cleanup test files
If ($testFile.exists)
	$testFile.delete()
End if 
If ($testDataFolder.exists)
	$testDataFolder.delete(fk recursive:K87:7)
End if 
