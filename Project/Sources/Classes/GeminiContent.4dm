// Gemini content object (used in both requests and responses)

property parts : Collection
property role : Text

Class constructor($data : Object)
	If ($data=Null:C1517)
		This:C1470.parts:=[]
		return
	End if

	This:C1470.role:=String:C10($data.role)

	// Parse parts
	If (Value type:C1509($data.parts)=Is collection:K8:32)
		This:C1470.parts:=$data.parts.map(Formula:C1597(cs:C1710.GeminiPart.new($1.value)))
	Else
		This:C1470.parts:=[]
	End if

// Create a new content object from text
Function fromText($text : Text; $role : Text) : cs:C1710.GeminiContent
	var $content:=cs:C1710.GeminiContent.new()
	$content.role:=$role
	$content.parts:=[cs:C1710.GeminiPart.new({text: $text})]
	return $content

// Add a text part to this content
Function addText($text : Text)
	This:C1470.parts.push(cs:C1710.GeminiPart.new({text: $text}))

// Convert to request body format
Function toBody() : Object
	var $body:={parts: []}

	If (Length:C16(This:C1470.role)>0)
		$body.role:=This:C1470.role
	End if

	var $part : cs:C1710.GeminiPart
	For each ($part; This:C1470.parts)
		$body.parts.push($part.toBody())
	End for each

	return $body

