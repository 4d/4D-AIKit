// Result class for fine-tuning job list operations
Class extends OpenAIResult

/*
* Returns a collection of fine-tuning job objects from the API response
* @return {Collection} Collection of cs.OpenAIFineTuningJob objects, or empty collection if none found
*/
Function get jobs : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.data)=Is collection:K8:32)))
		return []
	End if

	var $jobs:=[]
	var $job : Object
	For each ($job; $body.data)
		$job:=Try(cs:C1710.OpenAIFineTuningJob.new($job))
		If ($job#Null:C1517)
			$jobs.push($job)
		End if
	End for each

	return $jobs

/*
* Returns the ID of the first job in the list
* @return {Text} The first job ID, or empty string if not available
*/
Function get first_id : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if

	return String:C10($body.first_id)

/*
* Returns the ID of the last job in the list
* @return {Text} The last job ID, or empty string if not available
*/
Function get last_id : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if

	return String:C10($body.last_id)

/*
* Indicates if there are more jobs beyond this page
* @return {Boolean} True if there are more jobs to fetch
*/
Function get has_more : Boolean
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return False:C215
	End if

	return Bool:C1537($body.has_more)
