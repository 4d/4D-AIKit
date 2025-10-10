// API resource for managing files in OpenAI
// Files can be used across Assistants, Fine-tuning, Batch, and Vision endpoints
Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
/*
* Upload a file that can be used across various endpoints.
* 
* Individual files can be up to 512 MB, and the size of all files uploaded by one organization can be up to 1 TB.
* The Assistants API supports files up to 2 million tokens.
* The Batch API only supports .jsonl files up to 200 MB.
* 
* Supported purposes:
* - assistants: Used in the Assistants API
* - batch: Used in the Batch API (expires after 30 days by default)
* - fine-tune: Used for fine-tuning
* - vision: Images used for vision fine-tuning
* - user_data: Flexible file type for any purpose
* - evals: Used for eval data sets
* 
* @param $file {4D.File|4D.Blob} The File or Blob object to upload (not the filename)
* @param $purpose {Text} The intended purpose of the uploaded file (required)
* @param $parameters {cs.OpenAIFileParameters} Optional parameters including expiration policy
* @return {cs.OpenAIFileResult} Result containing the uploaded file information
* @throws Error if file is not 4D.File or 4D.Blob, or if purpose is empty
*/
Function create($file : Variant; $purpose : Text; $parameters : cs:C1710.OpenAIFileParameters) : cs:C1710.OpenAIFileResult
	// Validate file parameter - must be either 4D.File or 4D.Blob
	var $isFile:=False:C215
	var $isBlob:=False:C215
	
	If ($file#Null:C1517)
		Case of 
			: (Value type:C1509($file)=Is object:K8:27)
				$isFile:=OB Instance of:C1731($file; 4D:C1709.File)
				$isBlob:=OB Instance of:C1731($file; 4D:C1709.Blob)
			: (Value type:C1509($file)=Is BLOB:K8:12)
				$isBlob:=True:C214
		End case 
	End if 
	
	If (Not:C34($isFile) && Not:C34($isBlob))
		throw:C1805(1; "Expected a non-empty value for `file` (must be 4D.File or 4D.Blob/Blob)")
	End if 
	
	If (Length:C16($purpose)=0)
		throw:C1805(1; "Expected a non-empty value for `purpose`")
	End if 
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIFileParameters)))
		$parameters:=cs:C1710.OpenAIFileParameters.new($parameters)
	End if 
	
	var $body:=$parameters.body()
	$body.purpose:=$purpose
	
	If (Length:C16(String:C10($parameters.fileName))>0)
		var $files:={file: {file: $file; filename: $parameters.fileName}}
	Else 
		$files:={file: $file}
	End if 
	
	return This:C1470._client._postFiles("/files"; $body; $files; $parameters; cs:C1710.OpenAIFileResult)
	
/*
* Returns information about a specific file.
* 
* @param $fileId {Text} The ID of the file to retrieve (required)
* @param $parameters {cs.OpenAIParameters} Optional parameters for the request
* @return {cs.OpenAIFileResult} Result containing the file information
* @throws Error if fileId is empty
*/
Function retrieve($fileId : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIFileResult
	If (Length:C16($fileId)=0)
		throw:C1805(1; "Expected a non-empty value for `fileId`")
	End if 
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIParameters)))
		$parameters:=cs:C1710.OpenAIParameters.new($parameters)
	End if 
	
	return This:C1470._client._get("/files/"+$fileId; $parameters; cs:C1710.OpenAIFileResult)
	
/*
* Returns a list of files that belong to the user's organization.
* 
* @param $parameters {cs.OpenAIFileListParameters} Optional parameters for filtering and pagination
* @return {cs.OpenAIFileListResult} Result containing a collection of file objects
*/
Function list($parameters : cs:C1710.OpenAIFileListParameters) : cs:C1710.OpenAIFileListResult
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIFileListParameters)))
		$parameters:=cs:C1710.OpenAIFileListParameters.new($parameters)
	End if 
	
	var $query:=$parameters.body()
	return This:C1470._client._getApiList("/files"; $query; $parameters; cs:C1710.OpenAIFileListResult)
	
/*
* Delete a file.
* 
* @param $fileId {Text} The ID of the file to delete (required)
* @param $parameters {cs.OpenAIParameters} Optional parameters for the request
* @return {cs.OpenAIFileDeletedResult} Result containing the deletion status
* @throws Error if fileId is empty
*/
Function delete($fileId : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIFileDeletedResult
	If (Length:C16($fileId)=0)
		throw:C1805(1; "Expected a non-empty value for `fileId`")
	End if 
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIParameters)))
		$parameters:=cs:C1710.OpenAIParameters.new($parameters)
	End if 
	
	return This:C1470._client._delete("/files/"+$fileId; $parameters; cs:C1710.OpenAIFileDeletedResult)
	
/*
* Returns the contents of the specified file.
* 
* @param $fileId {Text} The ID of the file to retrieve content from (required)
* @param $parameters {cs.OpenAIParameters} Optional parameters for the request
* @return {cs.OpenAIResult} Result containing the file content
* @throws Error if fileId is empty
*/
Function _content($fileId : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	If (Length:C16($fileId)=0)
		throw:C1805(1; "Expected a non-empty value for `fileId`")
	End if 
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIParameters)))
		$parameters:=cs:C1710.OpenAIParameters.new($parameters)
	End if 
	
	return This:C1470._client._get("/files/"+$fileId+"/content"; $parameters; cs:C1710.OpenAIResult)
	