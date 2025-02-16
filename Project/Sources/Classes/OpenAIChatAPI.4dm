property completions : cs:C1710.OpenAIChatCompletions
property vision : cs:C1710.OpenAIVision

Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
	This:C1470.completions:=cs:C1710.OpenAIChatCompletions.new($client)
	This:C1470.vision:=cs:C1710.OpenAIVision.new(This:C1470)
	
	
	// MARK:- Lazy-friendly helper classes
	
Function create($systemPrompt : Text; $parameters : cs:C1710.OpenAIChatCompletionParameters) : cs:C1710.OpenAIChatHelper
	return cs:C1710.OpenAIChatHelper.new(This:C1470; $systemPrompt; $parameters)
	