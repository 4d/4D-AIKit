// Gemini file information

property name : Text
property displayName : Text
property mimeType : Text
property sizeBytes : Integer
property createTime : Text
property updateTime : Text
property expirationTime : Text
property sha256Hash : Text
property uri : Text
property state : Text
property error : Object
property videoMetadata : Object

Class constructor($data : Object)
	If ($data=Null:C1517)
		return
	End if

	This:C1470.name:=String:C10($data.name)
	This:C1470.displayName:=String:C10($data.displayName)
	This:C1470.mimeType:=String:C10($data.mimeType)
	This:C1470.sizeBytes:=Num:C11($data.sizeBytes)
	This:C1470.createTime:=String:C10($data.createTime)
	This:C1470.updateTime:=String:C10($data.updateTime)
	This:C1470.expirationTime:=String:C10($data.expirationTime)
	This:C1470.sha256Hash:=String:C10($data.sha256Hash)
	This:C1470.uri:=String:C10($data.uri)
	This:C1470.state:=String:C10($data.state)
	This:C1470.error:=$data.error
	This:C1470.videoMetadata:=$data.videoMetadata

