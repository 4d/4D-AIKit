// API resource for managing files in Gemini
// Files can be used for multimodal input, document processing, etc.
Class extends GeminiAPIResource

Class constructor($client : cs:C1710.Gemini)
	Super:C1705($client)

/*
* Upload a file to Gemini File API.
*
* @param $file {4D.File|4D.Blob} The File or Blob object to upload
* @param $parameters {cs.GeminiFileParameters} Optional parameters including displayName and mimeType
* @return {cs.GeminiFileResult} Result containing the uploaded file information
* @throws Error if file is not 4D.File or 4D.Blob
*/
Function create($file : Variant; $parameters : cs:C1710.GeminiFileParameters) : cs:C1710.GeminiFileResult
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

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.GeminiFileParameters)))
		$parameters:=cs:C1710.GeminiFileParameters.new($parameters)
	End if

	var $body:=$parameters.body()

	// Prepare file data
	If (Length:C16(String:C10($parameters.filename))>0)
		var $files:={file: {file: $file; filename: $parameters.filename}}
	Else
		$files:={file: $file}
	End if

	return This:C1470._client._postFiles("/upload/v1beta/files"; $body; $files; $parameters; cs:C1710.GeminiFileResult)

/*
* Returns information about a specific file.
*
* @param $fileId {Text} The ID of the file to retrieve (e.g., "files/abc123")
* @param $parameters {cs.GeminiParameters} Optional parameters for the request
* @return {cs.GeminiFileResult} Result containing the file information
* @throws Error if fileId is empty
*/
Function retrieve($fileId : Text; $parameters : cs:C1710.GeminiParameters) : cs:C1710.GeminiFileResult
	If (Length:C16($fileId)=0)
		throw:C1805(1; "Expected a non-empty value for `fileId`")
	End if

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.GeminiParameters)))
		$parameters:=cs:C1710.GeminiParameters.new($parameters)
	End if

	// Gemini file IDs include "files/" prefix, so we need to handle both cases
	var $path:=$fileId
	If (Position:C15("files/"; $fileId)#1)
		$path:="/files/"+$fileId
	Else
		$path:="/"+$fileId
	End if

	return This:C1470._client._get($path; $parameters; cs:C1710.GeminiFileResult)

/*
* Returns a list of files.
*
* @param $parameters {cs.GeminiFileListParameters} Optional parameters for filtering and pagination
* @return {cs.GeminiFileListResult} Result containing a collection of file objects
*/
Function list($parameters : cs:C1710.GeminiFileListParameters) : cs:C1710.GeminiFileListResult

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.GeminiFileListParameters)))
		$parameters:=cs:C1710.GeminiFileListParameters.new($parameters)
	End if

	var $query:=$parameters.body()
	return This:C1470._client._getApiList("/files"; $query; $parameters; cs:C1710.GeminiFileListResult)

/*
* Delete a file.
*
* @param $fileId {Text} The ID of the file to delete
* @param $parameters {cs.GeminiParameters} Optional parameters for the request
* @return {cs.GeminiResult} Result containing the deletion status
* @throws Error if fileId is empty
*/
Function delete($fileId : Text; $parameters : cs:C1710.GeminiParameters) : cs:C1710.GeminiResult
	If (Length:C16($fileId)=0)
		throw:C1805(1; "Expected a non-empty value for `fileId`")
	End if

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.GeminiParameters)))
		$parameters:=cs:C1710.GeminiParameters.new($parameters)
	End if

	// Gemini file IDs include "files/" prefix
	var $path:=$fileId
	If (Position:C15("files/"; $fileId)#1)
		$path:="/files/"+$fileId
	Else
		$path:="/"+$fileId
	End if

	return This:C1470._client._delete($path; $parameters; cs:C1710.GeminiResult)

