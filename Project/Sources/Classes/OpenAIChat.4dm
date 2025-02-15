property completions : cs:C1710.OpenAIChatCompletions

Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
	This:C1470.completions:=cs:C1710.OpenAIChatCompletions.new($client)
	
	
	// MARK:- Lazy-friendly helper classes
	
	// Not api related: just an helper to create a  chat with a list of messages
Function createChatHelper($systemPrompt : Text; $parameters : cs:C1710.OpenAIChatCompletionParameters) : cs:C1710.OpenAIChatHelper
	return cs:C1710.OpenAIChatHelper.new(This:C1470; $systemPrompt; $parameters)
	
	// Not api related: just an helper to analyse an image
Function createVisionHelper($imageURL : Text; $parameters : cs:C1710.OpenAIChatCompletionParameters) : cs:C1710.OpenAIVisionHelper
	return cs:C1710.OpenAIVisionHelper.new(This:C1470; $imageURL; $parameters)