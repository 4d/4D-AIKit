property completions : cs:C1710.OpenAIChatCompletions

Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
	This:C1470.completions:=cs:C1710.OpenAIChatCompletions.new($client)
	