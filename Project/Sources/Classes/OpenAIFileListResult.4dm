// Result class for file list operations
Class extends OpenAIResult

/*
* Returns a collection of file objects from the API response
* @return {Collection} Collection of cs.OpenAIFile objects, or empty collection if none found
*/
Function get files : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.data)=Is collection:K8:32)))
		return []
	End if 
	
	var $files:=[]
	var $file : Object
	For each ($file; $body.data)
		$files.push(cs:C1710.OpenAIFile.new($file))
	End for each 
	
	return $files
	
/*
* Returns the ID of the first file in the list
* @return {Text} The first file ID, or empty string if not available
*/
Function get first_id : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if 
	
	return String:C10($body.first_id)
	
/*
* Returns the ID of the last file in the list
* @return {Text} The last file ID, or empty string if not available
*/
Function get last_id : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if 
	
	return String:C10($body.last_id)
	
/*
* Indicates if there are more files beyond this page
* @return {Boolean} True if there are more files to fetch
*/
Function get has_more : Boolean
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return False:C215
	End if 
	
	return Bool:C1537($body.has_more)
	