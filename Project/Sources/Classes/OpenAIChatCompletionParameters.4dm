//  ID of the model to use.
property model : Text:="gpt-4o-mini"

// Whether to stream back partial progress. If set, tokens will be sent as data-only.
// property stream : Boolean:=False

// The maximum number of [tokens](/tokenizer) that can be generated in the completion.
property maxCompletionTokens : Integer:=0

//  How many completions to generate for each prompt.
property n : Integer:=1

// property seed : Variant

//  What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
property temperature : Real:=-1

// Whether or not to store the output of this chat completion request.
property store : Boolean:=False:C215

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)
	
Function body() : Object
	var $body : Object:=Super:C1706.body()
	
	If (Length:C16(This:C1470.model)>0)
		$body.model:=This:C1470.model
	End if 
	If (This:C1470.maxCompletionTokens>0)
		$body.max_completion_tokens:=This:C1470.maxCompletionTokens
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
	
	return $body