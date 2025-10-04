Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
/*
* Upload a file that can be used across various endpoints.
* Individual files can be up to 512 MB, and the size of all files uploaded by one organization can be up to 100 GB.
 */
Function create($file : Variant; $purpose : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIFileResult
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
	
	var $body:={purpose: $purpose}
	var $files:={file: $file}
	
	return This:C1470._client._postFiles("/files"; $body; $files; $parameters; cs:C1710.OpenAIFileResult)
	
/*
* Returns information about a specific file.
 */
Function retrieve($fileId : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIFileResult
	If (Length:C16($fileId)=0)
		throw:C1805(1; "Expected a non-empty value for `fileId`")
	End if 
	
	return This:C1470._client._get("/files/"+$fileId; $parameters; cs:C1710.OpenAIFileResult)
	
/*
* Returns a list of files that belong to the user's organization.
 */
Function list($parameters : cs:C1710.OpenAIFileListParameters) : cs:C1710.OpenAIFileListResult
	var $queryParameters:={}
	
	If ($parameters#Null:C1517)
		If (Length:C16(String:C10($parameters.after))>0)
			$queryParameters.after:=$parameters.after
		End if 
		If ($parameters.limit>0)
			$queryParameters.limit:=$parameters.limit
		End if 
		If (Length:C16(String:C10($parameters.order))>0)
			$queryParameters.order:=$parameters.order
		End if 
		If (Length:C16(String:C10($parameters.purpose))>0)
			$queryParameters.purpose:=$parameters.purpose
		End if 
	End if 
	
	return This:C1470._client._getApiList("/files"; $queryParameters; $parameters; cs:C1710.OpenAIFileListResult)
	
/*
* Delete a file.
 */
Function delete($fileId : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIFileDeletedResult
	If (Length:C16($fileId)=0)
		throw:C1805(1; "Expected a non-empty value for `fileId`")
	End if 
	
	return This:C1470._client._delete("/files/"+$fileId; $parameters; cs:C1710.OpenAIFileDeletedResult)
	
/*
* Returns the contents of the specified file.
 */
Function _content($fileId : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	If (Length:C16($fileId)=0)
		throw:C1805(1; "Expected a non-empty value for `fileId`")
	End if 
	
	return This:C1470._client._get("/files/"+$fileId+"/content"; $parameters; cs:C1710.OpenAIResult)
	