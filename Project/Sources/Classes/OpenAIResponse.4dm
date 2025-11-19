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
Function get text : Text
	If (This:C1470.output=Null:C1517)
		return ""
	End if

	Case of
		: (Value type:C1509(This:C1470.output)=Is text:K8:3)
			return This:C1470.output
		: ((Value type:C1509(This:C1470.output)=Is object:K8:27) && (This:C1470.output.text#Null:C1517))
			return This:C1470.output.text
		: ((Value type:C1509(This:C1470.output)=Is collection:K8:32) && (This:C1470.output.length>0))
			// If output is a collection, try to get text from first item
			If (Value type:C1509(This:C1470.output[0])=Is object:K8:27)
				return This:C1470.output[0].text || ""
			End if
	End case

	return ""

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
