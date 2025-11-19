// Parameters for assistant operations (create and modify)

// ID of the model to use
property model : Text

// The name of the assistant (max 256 characters)
property name : Text

// The description of the assistant (max 512 characters)
property description : Text

// The system instructions that the assistant uses (max 256,000 characters)
property instructions : Text

// A list of tool enabled on the assistant (max 128 tools)
// Tools can be of types code_interpreter, file_search, or function
property tools : Collection

// A set of resources that are used by the assistant's tools
property toolResources : Object

// Set of 16 key-value pairs that can be attached to an object
property metadata : Object

// What sampling temperature to use, between 0 and 2
property temperature : Real

// An alternative to sampling with temperature (nucleus sampling)
property topP : Real

// Specifies the format that the model must output
property responseFormat : Variant

// Constrains effort on reasoning for reasoning models
property reasoningEffort : Text

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)

Function body() : Object
	var $body:=Super:C1706.body()

	// Required for create, optional for modify
	If (Length:C16(String:C10(This:C1470.model))>0)
		$body.model:=This:C1470.model
	End if

	// Optional fields
	If (Length:C16(String:C10(This:C1470.name))>0)
		$body.name:=This:C1470.name
	End if

	If (Length:C16(String:C10(This:C1470.description))>0)
		$body.description:=This:C1470.description
	End if

	If (Length:C16(String:C10(This:C1470.instructions))>0)
		$body.instructions:=This:C1470.instructions
	End if

	If ((This:C1470.tools#Null:C1517) && (This:C1470.tools.length>0))
		$body.tools:=This:C1470.tools
	End if

	// Convert toolResources from camelCase to snake_case
	If (This:C1470.toolResources#Null:C1517)
		$body.tool_resources:=This:C1470.toolResources
	End if

	If (This:C1470.metadata#Null:C1517)
		$body.metadata:=This:C1470.metadata
	End if

	If (This:C1470.temperature#0)
		$body.temperature:=This:C1470.temperature
	End if

	// Convert topP from camelCase to snake_case
	If (This:C1470.topP#0)
		$body.top_p:=This:C1470.topP
	End if

	// Convert responseFormat from camelCase to snake_case
	If (This:C1470.responseFormat#Null:C1517)
		$body.response_format:=This:C1470.responseFormat
	End if

	// Convert reasoningEffort from camelCase to snake_case
	If (Length:C16(String:C10(This:C1470.reasoningEffort))>0)
		$body.reasoning_effort:=This:C1470.reasoningEffort
	End if

	return $body

