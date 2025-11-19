// Result class for fine-tuning event list operations
Class extends OpenAIResult

/*
* Returns a collection of fine-tuning event objects from the API response
* @return {Collection} Collection of cs.OpenAIFineTuningEvent objects, or empty collection if none found
*/
Function get events : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.data)=Is collection:K8:32)))
		return []
	End if

	var $events:=[]
	var $event : Object
	For each ($event; $body.data)
		$event:=Try(cs:C1710.OpenAIFineTuningEvent.new($event))
		If ($event#Null:C1517)
			$events.push($event)
		End if
	End for each

	return $events

/*
* Indicates if there are more events beyond this page
* @return {Boolean} True if there are more events to fetch
*/
Function get has_more : Boolean
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return False:C215
	End if

	return Bool:C1537($body.has_more)
