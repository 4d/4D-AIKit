Class extends OpenAIResult

// Get the output from the response
Function get output : Variant
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if
	return $body.output

// Get the response ID
Function get id : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if
	return String:C10($body.id)

// Get the status of the response (e.g., "completed", "in_progress", "failed")
Function get status : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if
	return String:C10($body.status)

// Get the model used
Function get model : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if
	return String:C10($body.model)

// Get tool calls if any
Function get tool_calls : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.tool_calls)=Is collection:K8:32)))
		return []
	End if
	return $body.tool_calls

// Get metadata if any
Function get metadata : Object
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if
	return $body.metadata

// Get created timestamp
Function get created_at : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if
	return String:C10($body.created_at)

// Get completed timestamp
Function get completed_at : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if
	return String:C10($body.completed_at)
