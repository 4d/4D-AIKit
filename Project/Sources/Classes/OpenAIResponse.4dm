property id : Text
property object : Text
property model : Text
property created_at : Real
property status : Text
property output : Collection
property instructions : Variant
property metadata : Object
property parallel_tool_calls : Boolean
property temperature : Real
property tool_choice : Variant
property tools : Collection
property top_p : Real
property background : Boolean
property max_output_tokens : Integer
property max_tool_calls : Integer
property previous_response_id : Text
property prompt : Object
property prompt_cache_key : Text
property reasoning : Object
property safety_identifier : Text
property service_tier : Text
property text : Object
property top_logprobs : Integer
property truncation : Text
property usage : Object
property user : Text
property error : Object
property incomplete_details : Object

Class constructor($response : Object)
	If ($response=Null:C1517)
		return 
	End if 
	
	This:C1470.id:=$response.id
	This:C1470.object:=$response.object
	This:C1470.model:=$response.model
	This:C1470.created_at:=$response.created_at
	This:C1470.status:=$response.status
	This:C1470.output:=$response.output
	This:C1470.instructions:=$response.instructions
	This:C1470.metadata:=$response.metadata
	This:C1470.parallel_tool_calls:=$response.parallel_tool_calls
	This:C1470.temperature:=$response.temperature
	This:C1470.tool_choice:=$response.tool_choice
	This:C1470.tools:=$response.tools
	This:C1470.top_p:=$response.top_p
	This:C1470.background:=$response.background
	This:C1470.max_output_tokens:=$response.max_output_tokens
	This:C1470.max_tool_calls:=$response.max_tool_calls
	This:C1470.previous_response_id:=$response.previous_response_id
	This:C1470.prompt:=$response.prompt
	This:C1470.prompt_cache_key:=$response.prompt_cache_key
	This:C1470.reasoning:=$response.reasoning
	This:C1470.safety_identifier:=$response.safety_identifier
	This:C1470.service_tier:=$response.service_tier
	This:C1470.text:=$response.text
	This:C1470.top_logprobs:=$response.top_logprobs
	This:C1470.truncation:=$response.truncation
	This:C1470.usage:=$response.usage
	This:C1470.user:=$response.user
	This:C1470.error:=$response.error
	This:C1470.incomplete_details:=$response.incomplete_details
	
Function get output_text : Text
	var $texts : Collection:=[]
	
	If (Value type:C1509(This:C1470.output)=Is collection:K8:32)
		var $outputItem : Object
		For each ($outputItem; This:C1470.output)
			If ($outputItem.type="message") && (Value type:C1509($outputItem.content)=Is collection:K8:32)
				var $content : Object
				For each ($content; $outputItem.content)
					If ($content.type="output_text") && (Length:C16($content.text)>0)
						$texts.push($content.text)
					End if 
				End for each 
			End if 
		End for each 
	End if 
	
	return $texts.join("")
	
Function get success : Boolean
	return (This:C1470.error=Null:C1517) && (This:C1470.status#"failed")
	