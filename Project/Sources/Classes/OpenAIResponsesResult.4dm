Class extends OpenAIResult

/*
* Get the response object from the result
* @return OpenAIResponse object or Null if not available
 */
Function get response : cs:C1710.OpenAIResponse
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if

	return cs:C1710.OpenAIResponse.new($body)

/*
* Get the text output from the response
* @return Text string or empty string if not available
 */
Function get text : Text
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || ($body.output=Null:C1517))
		return ""
	End if

	// Handle different output structures
	Case of
		: (Value type:C1509($body.output)=Is text:K8:3)
			return $body.output
		: ((Value type:C1509($body.output)=Is object:K8:27) && ($body.output.text#Null:C1517))
			return $body.output.text
		: ((Value type:C1509($body.output)=Is collection:K8:32) && ($body.output.length>0))
			// If output is a collection, try to get text from first item
			If (Value type:C1509($body.output[0])=Is object:K8:27)
				return $body.output[0].text || ""
			End if
	End case

	return ""

/*
* Get the full output object from the response
* @return Object or Null if not available
 */
Function get output : Variant
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if
	return $body.output
