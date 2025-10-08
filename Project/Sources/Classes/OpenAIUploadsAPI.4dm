// API resource for managing file uploads in OpenAI
// Allows you to upload large files in multiple parts (up to 8 GB)
Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
/*
* Creates an intermediate Upload object that you can add Parts to.
* Currently, an Upload can accept at most 8 GB in total and expires after an hour after you create it.
* 
* Once you complete the Upload, a File object will be created that contains all the parts you uploaded.
* This File is usable in the rest of the platform as a regular File object.
* 
* @param $filename {Text} The name of the file to upload (required)
* @param $bytes {Integer} The number of bytes in the file you are uploading (required)
* @param $purpose {Text} The intended purpose of the uploaded file (required)
* @param $mime_Type {Text} The MIME type of the file (required)
* @param $parameters {cs.OpenAIUploadParameters} Optional parameters including expires_after
* @return {cs.OpenAIUploadResult} Result containing the Upload object with status pending
* @throws Error if any required parameter is empty or invalid
*/
Function create($filename : Text; $bytes : Integer; $purpose : Text; $mimeType : Text; $parameters : cs:C1710.OpenAIUploadParameters) : cs:C1710.OpenAIUploadResult
	
	// Validate required parameters
	If (Length:C16($filename)=0)
		throw:C1805(1; "Expected a non-empty value for `filename`")
	End if 
	
	If ($bytes<=0)
		throw:C1805(1; "Expected a positive value for `bytes`")
	End if 
	
	If (Length:C16($purpose)=0)
		throw:C1805(1; "Expected a non-empty value for `purpose`")
	End if 
	
	If (Length:C16($mimeType)=0)
		throw:C1805(1; "Expected a non-empty value for `mime_type`")
	End if 
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIUploadParameters)))
		$parameters:=cs:C1710.OpenAIUploadParameters.new($parameters)
	End if 
	
	// Set required parameters
	var $body : Object:=$parameters.body()
	$body.filename:=$filename
	$body.bytes:=$bytes
	$body.purpose:=$purpose
	$body.mime_type:=$mimeType
	
	return This:C1470._client._post("/uploads"; $body; $parameters; cs:C1710.OpenAIUploadResult)
	
/*
* Adds a Part to an Upload object. A Part represents a chunk of bytes from the file you are trying to upload.
* 
* Each Part can be at most 64 MB, and you can add Parts until you hit the Upload maximum of 8 GB.
* It is possible to add multiple Parts in parallel. You can decide the intended order of the Parts when you complete the Upload.
* 
* @param $uploadId {Text} The ID of the Upload (required)
* @param $data {4D.File|4D.Blob} The chunk of bytes for this Part (required)
* @param $parameters {cs.OpenAIParameters} Optional parameters for the request
* @return {cs.OpenAIUploadPartResult} Result containing the upload Part object
* @throws Error if uploadId is empty or data is invalid
*/
Function addPart($uploadId : Text; $data : Variant; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIUploadPartResult
	If (Length:C16($uploadId)=0)
		throw:C1805(1; "Expected a non-empty value for `uploadId`")
	End if 
	
	// Validate data parameter - must be either 4D.File or 4D.Blob
	var $isFile:=False:C215
	var $isBlob:=False:C215
	
	If ($data#Null:C1517)
		Case of 
			: (Value type:C1509($data)=Is object:K8:27)
				$isFile:=OB Instance of:C1731($data; 4D:C1709.File)
				$isBlob:=OB Instance of:C1731($data; 4D:C1709.Blob)
			: (Value type:C1509($data)=Is BLOB:K8:12)
				$isBlob:=True:C214
		End case 
	End if 
	
	If (Not:C34($isFile) && Not:C34($isBlob))
		throw:C1805(1; "Expected a non-empty value for `data` (must be 4D.File or 4D.Blob/Blob)")
	End if 
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIParameters)))
		$parameters:=cs:C1710.OpenAIParameters.new($parameters)
	End if 
	
	var $body : Object:=$parameters.body()
	var $files : Object:={data: $data}
	
	return This:C1470._client._postFiles("/uploads/"+$uploadId+"/parts"; $body; $files; $parameters; cs:C1710.OpenAIUploadPartResult)
	
/*
* Completes the Upload.
* 
* Within the returned Upload object, there is a nested File object that is ready to use in the rest of the platform.
* You can specify the order of the Parts by passing in an ordered list of the Part IDs.
* The number of bytes uploaded upon completion must match the number of bytes initially specified when creating the Upload object.
* No Parts may be added after an Upload is completed.
* 
* @param $uploadId {Text} The ID of the Upload (required)
* @param $part_ids {Collection} The ordered list of Part IDs (required)
* @param $parameters {cs.OpenAIUploadCompleteParameters} Optional parameters including md5 checksum
* @return {cs.OpenAIUploadResult} Result containing the Upload object with status completed and a file property
* @throws Error if uploadId is empty or part_ids is invalid
*/
Function complete($uploadId : Text; $part_ids : Collection; $parameters : cs:C1710.OpenAIUploadCompleteParameters) : cs:C1710.OpenAIUploadResult
	If (Length:C16($uploadId)=0)
		throw:C1805(1; "Expected a non-empty value for `uploadId`")
	End if 
	
	If ($part_ids=Null:C1517) || ($part_ids.length=0)
		throw:C1805(1; "Expected a non-empty collection for `part_ids`")
	End if 
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIUploadCompleteParameters)))
		$parameters:=cs:C1710.OpenAIUploadCompleteParameters.new($parameters)
	End if 
	
	// Set required parameter
	$parameters.part_ids:=$part_ids
	
	var $body : Object:=$parameters.body()
	
	return This:C1470._client._post("/uploads/"+$uploadId+"/complete"; $body; $parameters; cs:C1710.OpenAIUploadResult)
	
/*
* Cancels the Upload. No Parts may be added after an Upload is cancelled.
* 
* @param $uploadId {Text} The ID of the Upload (required)
* @param $parameters {cs.OpenAIParameters} Optional parameters for the request
* @return {cs.OpenAIUploadResult} Result containing the Upload object with status cancelled
* @throws Error if uploadId is empty
*/
Function cancel($uploadId : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIUploadResult
	If (Length:C16($uploadId)=0)
		throw:C1805(1; "Expected a non-empty value for `uploadId`")
	End if 
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIParameters)))
		$parameters:=cs:C1710.OpenAIParameters.new($parameters)
	End if 
	
	var $body : Object:={}  // Empty body for cancel request
	
	return This:C1470._client._post("/uploads/"+$uploadId+"/cancel"; $body; $parameters; cs:C1710.OpenAIUploadResult)
	