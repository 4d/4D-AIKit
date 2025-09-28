//  ID of the model to use.
property model : Text:="gpt-4o-mini"

// Whether to stream back partial progress. If set, tokens will be sent as data-only. Callback formula required.
property stream : Boolean:=False:C215

// Property for stream=True. {include_usage: True}
property stream_options : Object

// The maximum number of [tokens](/tokenizer) that can be generated in the completion.
property max_completion_tokens : Integer:=0

//  How many completions to generate for each prompt.
property n : Integer:=1

//  What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
property temperature : Real:=-1

// Whether or not to store the output of this chat completion request.
property store : Boolean:=False:C215

// Constrains effort on reasoning for reasoning models. Currently supported values are low, medium, and high
property reasoning_effort : Text

// An object specifying the format that the model must output. ex: `{ "type": "json_schema", "json_schema": {...} }`
property response_format : Object

// A list of tools the model may call.
property tools : Collection

// Controls which (if any) tool is called by the model.
property tool_choice : Variant

// Static predicted output content, such as the content of a text file that is being regenerated.
property prediction : Object

// seed, metadata, modalities, etc...

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
	If (This:C1470.max_completion_tokens>0)
		$body.max_completion_tokens:=This:C1470.max_completion_tokens
	End if 
	If (This:C1470.n>0)
		$body.n:=This:C1470.n
	End if 
	If (This:C1470.temperature>=0)
		$body.temperature:=This:C1470.temperature
	End if 
	If (This:C1470.store)
		$body.store:=This:C1470.store
	End if 
	If (This:C1470.stream)
		$body.stream:=This:C1470.stream
	End if 
	If (This:C1470.stream_options#Null:C1517)
		$body.stream_options:=This:C1470.stream_options
	End if 
	If (Length:C16(String:C10(This:C1470.reasoning_effort))>0)
		$body.reasoning_effort:=This:C1470.reasoning_effort
	End if 
	If (This:C1470.response_format#Null:C1517)
		$body.response_format:=This:C1470.response_format
	End if 
	
	This:C1470._mapTools()  // in case of post modification
	If (This:C1470.tools#Null:C1517)
		$body.tools:=This:C1470.tools.map(Formula:C1597($1.value.body()))
	End if 
	If (This:C1470.tool_choice#Null:C1517)
		$body.tool_choice:=This:C1470.tool_choice
	End if 
	If (This:C1470.prediction#Null:C1517)
		$body.prediction:=This:C1470.prediction
	End if 
	return $body
	
Function _isAsync() : Boolean
	return Super:C1706._isAsync()\
		 || ((Bool:C1537(This:C1470.stream)) && (This:C1470.onData#Null:C1517) && (OB Instance of:C1731(This:C1470.onData; 4D:C1709.Function)))