// Response ID
property id : Text

// Object type (should be "response")
property object : Text

// Model used
property model : Text

// Creation timestamp
property created : Integer

// Output content
property output : Variant

// Status of the response
property status : Text

// Usage information
property usage : Object

// Metadata
property metadata : Object

// Conversation ID
property conversation_id : Text

Class constructor($data : Object)
	If ($data=Null:C1517)
		return
	End if

	// Copy all properties from the response data
	var $key : Text
	For each ($key; $data)
		This:C1470[$key]:=$data[$key]
	End for each

/*
* Get the text output from the response
* @return Text string or empty string if not available
 */
Function get outputText : Text
	return This:C1470._extractTextFromOutput(This:C1470.output)

/*
* Check if the response is complete
* @return Boolean
 */
Function get isComplete : Boolean
	return (This:C1470.status="completed") || (This:C1470.status="done")

/*
* Check if the response failed
* @return Boolean
 */
Function get isFailed : Boolean
	return (This:C1470.status="failed") || (This:C1470.status="error")

/*
* Check if the response is still processing
* @return Boolean
 */
Function get isProcessing : Boolean
	return (This:C1470.status="processing") || (This:C1470.status="in_progress")

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
