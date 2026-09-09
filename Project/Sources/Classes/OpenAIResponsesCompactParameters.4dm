// The model to use for the compacted response
property model : Text

// Prompt cache key to reuse for the compacted response
property prompt_cache_key : Text

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)
	
Function body() : Object
	var $body:=Super:C1706.body()
	
	If (Length:C16(This:C1470.model)>0)
		$body.model:=This:C1470.model
	End if 
	If (Length:C16(This:C1470.prompt_cache_key)>0)
		$body.prompt_cache_key:=This:C1470.prompt_cache_key
	End if 
	
	return $body
