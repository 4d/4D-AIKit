//  Configuration options for model generation and outputs.
property generationConfig : Object

// Safety settings for content generation.
property safetySettings : Collection

// Tool configuration for function calling.
property tools : Collection

// System instruction for the model.
property systemInstruction : Variant

// Cached content to use for the request.
property cachedContent : Text

Class extends GeminiParameters

Class constructor($object : Object)
	Super:C1705($object)

Function body() : Object
	var $body : Object:=Super:C1706.body()

	If (This:C1470.generationConfig#Null:C1517)
		$body.generationConfig:=This:C1470.generationConfig
	End if

	If (This:C1470.safetySettings#Null:C1517)
		$body.safetySettings:=This:C1470.safetySettings
	End if

	If (This:C1470.tools#Null:C1517)
		$body.tools:=This:C1470.tools
	End if

	If (This:C1470.systemInstruction#Null:C1517)
		// System instruction can be text or object
		If (Value type:C1509(This:C1470.systemInstruction)=Is text:K8:3)
			$body.systemInstruction:={parts: [{text: This:C1470.systemInstruction}]}
		Else
			$body.systemInstruction:=This:C1470.systemInstruction
		End if
	End if

	If (Length:C16(String:C10(This:C1470.cachedContent))>0)
		$body.cachedContent:=This:C1470.cachedContent
	End if

	return $body

// Helper to set generation config options
Function setGenerationConfig($temperature : Real; $maxOutputTokens : Integer; $topP : Real; $topK : Integer)
	This:C1470.generationConfig:={}

	If ($temperature>=0)
		This:C1470.generationConfig.temperature:=$temperature
	End if

	If ($maxOutputTokens>0)
		This:C1470.generationConfig.maxOutputTokens:=$maxOutputTokens
	End if

	If ($topP>=0)
		This:C1470.generationConfig.topP:=$topP
	End if

	If ($topK>0)
		This:C1470.generationConfig.topK:=$topK
	End if

