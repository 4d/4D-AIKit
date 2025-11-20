// Gemini content part (can be text, inline data, file data, etc.)

property text : Text
property inlineData : Object
property fileData : Object
property functionCall : Object
property functionResponse : Object

Class constructor($data : Object)
	If ($data=Null:C1517)
		return
	End if

	This:C1470.text:=String:C10($data.text)
	This:C1470.inlineData:=$data.inlineData
	This:C1470.fileData:=$data.fileData
	This:C1470.functionCall:=$data.functionCall
	This:C1470.functionResponse:=$data.functionResponse

// Create a text part
Function fromText($text : Text) : cs:C1710.GeminiPart
	var $part:=cs:C1710.GeminiPart.new()
	$part.text:=$text
	return $part

// Create an inline data part (for images, etc.)
Function fromInlineData($mimeType : Text; $data : Text) : cs:C1710.GeminiPart
	var $part:=cs:C1710.GeminiPart.new()
	$part.inlineData:={mimeType: $mimeType; data: $data}
	return $part

// Convert to request body format
Function toBody() : Object
	var $body:={}

	If (Length:C16(This:C1470.text)>0)
		$body.text:=This:C1470.text
	End if

	If (This:C1470.inlineData#Null:C1517)
		$body.inlineData:=This:C1470.inlineData
	End if

	If (This:C1470.fileData#Null:C1517)
		$body.fileData:=This:C1470.fileData
	End if

	If (This:C1470.functionCall#Null:C1517)
		$body.functionCall:=This:C1470.functionCall
	End if

	If (This:C1470.functionResponse#Null:C1517)
		$body.functionResponse:=This:C1470.functionResponse
	End if

	return $body

