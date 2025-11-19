// Result class for single fine-tuning job operations (create, retrieve, cancel)
Class extends OpenAIResult

/*
* Returns the fine-tuning job object from the API response
* @return {cs.OpenAIFineTuningJob} The job object, or Null if invalid response
*/
Function get job : cs:C1710.OpenAIFineTuningJob
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.id)=Is text:K8:3)))
		return Null:C1517
	End if

	var $job:=Try(cs:C1710.OpenAIFineTuningJob.new($body))
	If ($job=Null:C1517)
		var $errors:=Last errors:C1799
		If (($errors#Null:C1517) && (This:C1470.errors=Null:C1517))
			This:C1470._errors:=$errors  // decoding error
		End if
	End if

	return $job
