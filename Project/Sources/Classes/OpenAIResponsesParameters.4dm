// ID of the model to use (optional, e.g., "gpt-4o" or "o3")
property model : Text

// System/developer message for context
property instructions : Text

// Associates response with conversation (string or object)
property conversation : Variant

// Enables multi-turn conversations
property previous_response_id : Text

// Output configuration for plain text or structured JSON
property text : Object

// Whether to stream back partial progress via server-sent events
property stream : Boolean:=False:C215

// Property for stream=True. {include_usage: True}
property stream_options : Object

// Upper bound for generated tokens
property max_output_tokens : Integer:=0

// A list of tools the model may call
property tools : Collection

// Controls which (if any) tool is called by the model
property tool_choice : Variant

// Maximum total tool calls per response
property max_tool_calls : Integer:=0

// Enable parallel execution of tool calls
property parallel_tool_calls : Boolean:=True:C214

// What sampling temperature to use, between 0 and 2
property temperature : Real:=-1

// Nucleus sampling parameter
property top_p : Real:=-1

// Return top token probabilities
property top_logprobs : Integer:=0

// Configuration for o-series models (reasoning)
property reasoning : Object

// Key-value pairs for metadata (16 pairs max, 64-char keys, 512-char values)
property metadata : Object

// Background processing mode
property background : Boolean:=False:C215

// Enable response storage for retrieval
property store : Boolean:=True:C214

// Context overflow handling: "auto" or "disabled"
property truncation : Text

// Function to call asynchronously when receiving data. /!\ Be sure your current process not die.
property onData : 4D:C1709.Function

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)

	If ((This:C1470.onData=Null:C1517) && ($object.onData#Null:C1517))
		This:C1470.onData:=$object.onData
	End if

	This:C1470._mapTools()

Function _mapTools
	If (This:C1470.tools=Null:C1517)
		return
	End if
	If (This:C1470.tools.length=0)
		return
	End if

	var $tools:=[]
	var $tool : Variant
	For each ($tool; This:C1470.tools)
		If (Value type:C1509($tool)#Is object:K8:27)
			continue  // ignore
		End if

		If (OB Instance of:C1731($tool; cs:C1710.OpenAITool))
			$tools.push($tool)
		Else
			$tools.push(cs:C1710.OpenAITool.new($tool))
		End if

	End for each

	This:C1470.tools:=$tools

Function body() : Object
	var $body : Object:=Super:C1706.body()

	If (Length:C16(String:C10(This:C1470.model))>0)
		$body.model:=This:C1470.model
	End if
	If (Length:C16(String:C10(This:C1470.instructions))>0)
		$body.instructions:=This:C1470.instructions
	End if
	If (This:C1470.conversation#Null:C1517)
		$body.conversation:=This:C1470.conversation
	End if
	If (Length:C16(String:C10(This:C1470.previous_response_id))>0)
		$body.previous_response_id:=This:C1470.previous_response_id
	End if
	If (This:C1470.text#Null:C1517)
		$body.text:=This:C1470.text
	End if
	If (This:C1470.stream)
		$body.stream:=This:C1470.stream
	End if
	If (This:C1470.stream_options#Null:C1517)
		$body.stream_options:=This:C1470.stream_options
	End if
	If (This:C1470.max_output_tokens>0)
		$body.max_output_tokens:=This:C1470.max_output_tokens
	End if

	This:C1470._mapTools()  // in case of post modification
	If (This:C1470.tools#Null:C1517)
		$body.tools:=This:C1470.tools.map(Formula:C1597($1.value.body()))
	End if
	If (This:C1470.tool_choice#Null:C1517)
		$body.tool_choice:=This:C1470.tool_choice
	End if
	If (This:C1470.max_tool_calls>0)
		$body.max_tool_calls:=This:C1470.max_tool_calls
	End if
	If (This:C1470.parallel_tool_calls#Null:C1517)
		$body.parallel_tool_calls:=This:C1470.parallel_tool_calls
	End if

	If (This:C1470.temperature>=0)
		$body.temperature:=This:C1470.temperature
	End if
	If (This:C1470.top_p>=0)
		$body.top_p:=This:C1470.top_p
	End if
	If (This:C1470.top_logprobs>0)
		$body.top_logprobs:=This:C1470.top_logprobs
	End if

	If (This:C1470.reasoning#Null:C1517)
		$body.reasoning:=This:C1470.reasoning
	End if
	If (This:C1470.metadata#Null:C1517)
		$body.metadata:=This:C1470.metadata
	End if
	If (This:C1470.background)
		$body.background:=This:C1470.background
	End if
	If (This:C1470.store#Null:C1517)
		$body.store:=This:C1470.store
	End if
	If (Length:C16(String:C10(This:C1470.truncation))>0)
		$body.truncation:=This:C1470.truncation
	End if

	return $body

Function _isAsync() : Boolean
	return Super:C1706._isAsync()\
		 || ((Bool:C1537(This:C1470.stream)) && (This:C1470.onData#Null:C1517) && (OB Instance of:C1731(This:C1470.onData; 4D:C1709.Function)))
