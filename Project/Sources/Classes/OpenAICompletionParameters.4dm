//  ID of the model to use.
property model : Text:="gpt-3.5-turbo-instruct"

// Whether to stream back partial progress. If set, tokens will be sent as data-only.
// property stream : Boolean:=False

// Generates `best_of` completions server-side and returns the "best" (the one with the highest log probability per token). Results cannot be streamed.
// property bestOf: Integer

// Echo back the prompt in addition to the completion.
property echo : Boolean

// The maximum number of [tokens](/tokenizer) that can be generated in the completion.
property maxTokens : Integer

//  How many completions to generate for each prompt.
property n : Integer:=1

// property seed : Variant

// The suffix that comes after a completion of inserted text. (only for `gpt-3.5-turbo-instruct`)
// property suffix: text 

//  What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
property temperature : Real:=-1

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)
	
Function body() : Object
	var $body:=Super:C1706.body()
	
	If (Length:C16(This:C1470.model)>0)
		$body.model:=This:C1470.model
	End if 
	If (This:C1470.echo)
		$body.echo:=This:C1470.echo
	End if 
	If (This:C1470.maxTokens>0)
		$body.maxTokens:=This:C1470.maxTokens
	End if 
	If (This:C1470.n>0)
		$body.n:=This:C1470.n
	End if 
	If (This:C1470.temperature>=0)
		$body.temperature:=This:C1470.temperature
	End if 
	
	
	return $body
	