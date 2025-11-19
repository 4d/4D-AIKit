// Represents an assistant that can call the model and use tools

// The identifier, which can be referenced in API endpoints
property id : Text

// The object type, which is always "assistant"
property object : Text

// The Unix timestamp (in seconds) for when the assistant was created
property createdAt : Integer

// The name of the assistant (max 256 characters)
property name : Text

// The description of the assistant (max 512 characters)
property description : Text

// ID of the model to use
property model : Text

// The system instructions that the assistant uses (max 256,000 characters)
property instructions : Text

// A list of tool enabled on the assistant (max 128 tools)
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

Class constructor($object : Object)
	If ($object=Null:C1517)
		return
	End if

	var $key : Text
	For each ($key; $object)
		// Convert snake_case API fields to camelCase 4D properties
		Case of
			: ($key="created_at")
				This:C1470.createdAt:=$object[$key]
			: ($key="tool_resources")
				This:C1470.toolResources:=$object[$key]
			: ($key="top_p")
				This:C1470.topP:=$object[$key]
			: ($key="response_format")
				This:C1470.responseFormat:=$object[$key]
			: ($key="reasoning_effort")
				This:C1470.reasoningEffort:=$object[$key]
			Else
				This:C1470[$key]:=$object[$key]
		End case
	End for each

