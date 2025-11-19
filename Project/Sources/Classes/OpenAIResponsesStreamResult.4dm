// Contain the stream event data sent by server
property event : Text
property data : Object

property _decodingErrors : Collection
property _terminated : Boolean

Class extends OpenAIResult

// Build stream result with SSE event and data.
Class constructor($request : 4D:C1709.HTTPRequest; $event : Text; $body : Variant; $terminated : Boolean)
	This:C1470.request:=$request
	This:C1470._terminated:=$terminated
	
	If (Length:C16($event)>0)
		This:C1470.event:=$event
	End if 
	
	Case of 
		: (Value type:C1509($body)=Is object:K8:27)
			This:C1470.data:=$body
		: (Value type:C1509($body)=Is text:K8:3)
			var $textData:=$body
			If (Position:C15("data: "; $textData)=1)
				$textData:=Substring:C12($textData; Length:C16("data: ")+1)
			End if 
			
			If ($textData="[DONE]")
				return 
			End if 
			
			var $parsed:=Try(JSON Parse:C1218($textData))
			If ($parsed#Null:C1517)
				This:C1470.data:=$parsed
			Else 
				This:C1470._decodingErrors:=Last errors:C1799
			End if 
	End case 
	
	If ((Length:C16(This:C1470.event)=0) && (This:C1470.data#Null:C1517) && (This:C1470.data.type#Null:C1517))
		This:C1470.event:=This:C1470.data.type
	End if 
	
Function get terminated : Boolean
	return This:C1470._terminated
	
	// Return True if we success to decode the streaming data as object.
Function get success : Boolean
	If (This:C1470.data=Null:C1517)
		return False:C215
	End if 
	If ((This:C1470.request=Null:C1517) || (This:C1470.request.response=Null:C1517))
		return True:C214  // we do not have final state
	End if 
	return (300>This:C1470.request.response.status) && (This:C1470.request.response.status>=200)
	
	// Return errors if we manage to find some. 
Function get errors : Collection
	If ((This:C1470.request.errors#Null:C1517) && (This:C1470.request.errors.length>0))
		return This:C1470.request.errors
	End if 
	
	If ((This:C1470.data#Null:C1517) && (This:C1470.data.error#Null:C1517))
		return [This:C1470.data.error]
	End if 
	
	If (This:C1470._decodingErrors#Null:C1517)
		return This:C1470._decodingErrors
	End if 
	
	return []
