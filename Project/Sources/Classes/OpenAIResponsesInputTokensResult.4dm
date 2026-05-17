Class extends OpenAIResult

/*
* Returns the computed number of input tokens.
* @return Integer token count, or 0 if unavailable
*/
Function get input_tokens : Integer
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return 0
	End if 
	return Num:C11($body.input_tokens)

/*
* Returns any extra details associated with the token count result.
* @return Object or Null if unavailable
*/
Function get details : Object
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if 
	If ($body.details#Null:C1517)
		return $body.details
	End if 
	return $body.input_tokens_details
