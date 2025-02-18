// Initial request
property request : 4D:C1709.HTTPRequest

// Contain the stream data send by server
property data : Object

// Build stream result with event blob data.
Class constructor($request : 4D:C1709.HTTPRequest; $data : 4D:C1709.Blob)
	
	var $textData:=BLOB to text:C555($data; UTF8 C string:K22:15)
	While ((Length:C16($textData)>0) && $textData[[Length:C16($textData)]]="\n")
		$textData:=Substring:C12($textData; 1; Length:C16($textData)-1)
	End while 
	var $pos:=Position:C15("{"; $textData)
	If ($pos>0)
		$textData:=Substring:C12($textData; $pos)  // remove "data:"
	End if 
	
	This:C1470.data:=Try(JSON Parse:C1218($textData))
	
	// Return True if we success to decode the streaming data as object.
Function get success : Boolean
	return This:C1470.data#Null:C1517
	
	// Return errors if we manage to find some. 
Function get errors : Collection
	If ((This:C1470.request.errors#Null:C1517) && (This:C1470.request.errors.length>0))
		return This:C1470.request.errors
	End if 
	
	If ((This:C1470.data#Null:C1517) && (This:C1470.data.error#Null:C1517))
		return [This:C1470.data.error]
	End if 
	
	return []
	
	// Return a choice data, with a delta message.
Function get choice : cs:C1710.OpenAIChoice
	var $body:=This:C1470.data
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.choices)=Is collection:K8:32)))
		return Null:C1517
	End if 
	If ($body.choices.length=0)
		return Null:C1517
	End if 
	
	return cs:C1710.OpenAIChoice.new($body.choices.first())
	
	// Return choices data, with delta messages.
Function get choices : Collection
	var $body:=This:C1470.data
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.choices)=Is collection:K8:32)))
		return []
	End if 
	
	return $body.choices.map(Formula:C1597(cs:C1710.OpenAIChoice.new($1.value)))
	