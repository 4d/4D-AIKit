// Gemini model information

property name : Text
property version : Text
property displayName : Text
property description : Text
property inputTokenLimit : Integer
property outputTokenLimit : Integer
property supportedGenerationMethods : Collection
property temperature : Real
property maxTemperature : Real
property topP : Real
property topK : Integer

Class constructor($data : Object)
	If ($data=Null:C1517)
		return
	End if

	This:C1470.name:=String:C10($data.name)
	This:C1470.version:=String:C10($data.version)
	This:C1470.displayName:=String:C10($data.displayName)
	This:C1470.description:=String:C10($data.description)
	This:C1470.inputTokenLimit:=Num:C11($data.inputTokenLimit)
	This:C1470.outputTokenLimit:=Num:C11($data.outputTokenLimit)
	This:C1470.supportedGenerationMethods:=$data.supportedGenerationMethods
	This:C1470.temperature:=Num:C11($data.temperature)
	This:C1470.maxTemperature:=Num:C11($data.maxTemperature)
	This:C1470.topP:=Num:C11($data.topP)
	This:C1470.topK:=Num:C11($data.topK)

