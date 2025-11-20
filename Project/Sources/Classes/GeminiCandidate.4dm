// Gemini response candidate

property content : cs:C1710.GeminiContent
property finishReason : Text
property safetyRatings : Collection
property citationMetadata : Object
property tokenCount : Integer
property index : Integer

Class constructor($data : Object)
	If ($data=Null:C1517)
		return
	End if

	If ($data.content#Null:C1517)
		This:C1470.content:=cs:C1710.GeminiContent.new($data.content)
	End if

	This:C1470.finishReason:=String:C10($data.finishReason)
	This:C1470.safetyRatings:=$data.safetyRatings
	This:C1470.citationMetadata:=$data.citationMetadata
	This:C1470.tokenCount:=Num:C11($data.tokenCount)
	This:C1470.index:=Num:C11($data.index)

// Get the text content from the first part (convenience method)
Function get text : Text
	If ((This:C1470.content=Null:C1517) || (This:C1470.content.parts.length=0))
		return ""
	End if
	var $firstPart:=This:C1470.content.parts[0]
	return String:C10($firstPart.text)

