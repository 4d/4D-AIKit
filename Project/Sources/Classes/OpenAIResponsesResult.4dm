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
Function get outputText : Text
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || ($body.output=Null:C1517))
		return ""
	End if

	return This:C1470._extractTextFromOutput($body.output)

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

/*
* Extract text from a Responses API output structure.
* @param $output - Response output (text, object, or collection)
* @return Text
 */
Function _extractTextFromOutput($output : Variant) : Text
	If ($output=Null:C1517)
		return ""
	End if

	Case of
		: (Value type:C1509($output)=Is text:K8:3)
			return $output
		: (Value type:C1509($output)=Is object:K8:27)
			// Direct output_text item
			If (($output.type="output_text") && ($output.text#Null:C1517))
				return $output.text
			End if
			// Message output with content array
			If (($output.type="message") && (Value type:C1509($output.content)=Is collection:K8:32))
				var $text : Text:=""
				var $item : Variant
				For each ($item; $output.content)
					$text:=$text+This:C1470._extractTextFromOutput($item)
				End for each
				return $text
			End if
			// Fallback for objects that expose text directly
			If ($output.text#Null:C1517)
				return $output.text
			End if
		: (Value type:C1509($output)=Is collection:K8:32)
			var $joined : Text:=""
			var $entry : Variant
			For each ($entry; $output)
				$joined:=$joined+This:C1470._extractTextFromOutput($entry)
			End for each
			return $joined
	End case

	return ""
