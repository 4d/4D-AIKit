// ID of the model to use
property model : Text:="gpt-4o"

// Whether to stream back partial progress. If set, tokens will be sent as data-only. Callback formula required.
property stream : Boolean:=False:C215

// Property for stream=True. {include_usage: True}
property stream_options : Object

// Text, image, or file inputs to the model, used to generate a response
property input : Variant

// A system (or developer) message inserted into the model's context
property instructions : Text

// An upper bound for the number of tokens that can be generated for a response
property max_output_tokens : Integer:=0

// The maximum number of total calls to built-in tools that can be processed in a response
property max_tool_calls : Integer:=0

// Whether to allow the model to run tool calls in parallel
property parallel_tool_calls : Boolean:=True:C214

// The unique ID of the previous response to the model for multi-turn conversations
property previous_response_id : Text

// Reference to a prompt template and its variables
property prompt : Object

// Used by OpenAI to cache responses for similar requests
property prompt_cache_key : Text

// Configuration options for reasoning models
property reasoning : Object

// A stable identifier used to help detect users that may be violating OpenAI's usage policies
property safety_identifier : Text

// Specifies the processing type used for serving the request
property service_tier : Text

// Whether or not to store the output of this response request
property store : Boolean:=True:C214

// What sampling temperature to use, between 0 and 2
property temperature : Real:=-1

// Configuration options for a text response from the model
property text : Object

// How the model should select which tool (or tools) to use
property tool_choice : Variant

// A list of tools the model may call
property tools : Collection

// An integer between 0 and 20 specifying the number of most likely tokens to return
property top_logprobs : Integer:=0

// An alternative to sampling with temperature, called nucleus sampling
property top_p : Real:=-1

// The truncation strategy to use for the model response
property truncation : Text:="disabled"

// Whether to run the model response in the background
property background : Boolean:=False:C215

// Specify additional output data to include in the model response
property include : Collection

// Set of 16 key-value pairs that can be attached to an object
property metadata : Object

// Function to call asynchronously when receiving data. /!\ Be sure your current process not die.
property onData : 4D:C1709.Function

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)

Function body() : Object
	var $body : Object:=Super:C1706.body()
	
	If (Length:C16(String:C10(This:C1470.model))>0)
		$body.model:=This:C1470.model
	End if 
	
	If (This:C1470.stream)
		$body.stream:=This:C1470.stream
		If (This:C1470.stream_options#Null:C1517)
			$body.stream_options:=This:C1470.stream_options
		End if 
	End if 
	
	If (This:C1470.input#Null:C1517)
		$body.input:=This:C1470.input
	End if 
	
	If (Length:C16(This:C1470.instructions)>0)
		$body.instructions:=This:C1470.instructions
	End if 
	
	If (This:C1470.max_output_tokens>0)
		$body.max_output_tokens:=This:C1470.max_output_tokens
	End if 
	
	If (This:C1470.max_tool_calls>0)
		$body.max_tool_calls:=This:C1470.max_tool_calls
	End if 
	
	$body.parallel_tool_calls:=This:C1470.parallel_tool_calls
	
	If (Length:C16(This:C1470.previous_response_id)>0)
		$body.previous_response_id:=This:C1470.previous_response_id
	End if 
	
	If (This:C1470.prompt#Null:C1517)
		$body.prompt:=This:C1470.prompt
	End if 
	
	If (Length:C16(This:C1470.prompt_cache_key)>0)
		$body.prompt_cache_key:=This:C1470.prompt_cache_key
	End if 
	
	If (This:C1470.reasoning#Null:C1517)
		$body.reasoning:=This:C1470.reasoning
	End if 
	
	If (Length:C16(This:C1470.safety_identifier)>0)
		$body.safety_identifier:=This:C1470.safety_identifier
	End if 
	
	If (Length:C16(This:C1470.service_tier)>0)
		$body.service_tier:=This:C1470.service_tier
	End if 
	
	$body.store:=This:C1470.store
	
	If (This:C1470.temperature>=0)
		$body.temperature:=This:C1470.temperature
	End if 
	
	If (This:C1470.text#Null:C1517)
		$body.text:=This:C1470.text
	End if 
	
	If (This:C1470.tool_choice#Null:C1517)
		$body.tool_choice:=This:C1470.tool_choice
	End if 
	
	If (This:C1470.tools#Null:C1517)
		$body.tools:=This:C1470.tools
	End if 
	
	If (This:C1470.top_logprobs>0)
		$body.top_logprobs:=This:C1470.top_logprobs
	End if 
	
	If (This:C1470.top_p>=0)
		$body.top_p:=This:C1470.top_p
	End if 
	
	If (Length:C16(This:C1470.truncation)>0)
		$body.truncation:=This:C1470.truncation
	End if 
	
	$body.background:=This:C1470.background
	
	If (This:C1470.include#Null:C1517)
		$body.include:=This:C1470.include
	End if 
	
	If (This:C1470.metadata#Null:C1517)
		$body.metadata:=This:C1470.metadata
	End if 
	
	return $body
