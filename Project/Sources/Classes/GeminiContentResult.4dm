Class extends GeminiResult

Function get candidates : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.candidates)=Is collection:K8:32)))
		return []
	End if

	return $body.candidates.map(Formula:C1597(cs:C1710.GeminiCandidate.new($1.value)))

Function get candidate : cs:C1710.GeminiCandidate
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.candidates)=Is collection:K8:32)))
		return Null:C1517
	End if
	If ($body.candidates.length=0)
		return Null:C1517
	End if

	return cs:C1710.GeminiCandidate.new($body.candidates.first())

Function get promptFeedback : Object
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if
	return $body.promptFeedback

// Get usage metadata
Function get usage : Object
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if
	return $body.usageMetadata

