// Loop-level stop reason set by the agent loop (OpenAIChatHelper), e.g. "max_iterations"
// or "cancelled". Empty means: derive stopReason from the response itself.
property _stopReason : Text

Class extends OpenAIResult

// Why the response stopped. An explicit reason set by the agent loop wins; otherwise it is
// derived from the response: the choice finish_reason verbatim ("stop", "length", "tool_calls",
// "content_filter", ...), "error" if the request failed, or "" if not terminated.
Function get stopReason : Text
	If (Length:C16(String:C10(This:C1470._stopReason))>0)
		return This:C1470._stopReason
	End if
	If (Not:C34(This:C1470.success))
		return "error"
	End if
	var $choice : cs:C1710.OpenAIChoice:=This:C1470.choice
	If (($choice#Null:C1517) && (Length:C16(String:C10($choice.finish_reason))>0))
		return String:C10($choice.finish_reason)
	End if
	return ""

Function set stopReason($value : Text)
	This:C1470._stopReason:=$value

Function get choices : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.choices)=Is collection:K8:32)))
		return []
	End if 
	
	return $body.choices.map(Formula:C1597(cs:C1710.OpenAIChoice.new($1.value)))
	
Function get choice : cs:C1710.OpenAIChoice
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.choices)=Is collection:K8:32)))
		return Null:C1517
	End if 
	If ($body.choices.length=0)
		return Null:C1517
	End if 
	
	return cs:C1710.OpenAIChoice.new($body.choices.first())