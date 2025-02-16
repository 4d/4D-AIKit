property chat : cs:C1710.OpenAIChatAPI
property imageURL : Text

Class constructor($chat : cs:C1710.OpenAIChatAPI; $imageURL : Text)
	This:C1470.chat:=$chat
	This:C1470.imageURL:=$imageURL
	
Function prompt($prompt : Text; $parameters : cs:C1710.OpenAIChatCompletionParameters) : cs:C1710.OpenAIChatCompletionsResult
	
	var $message:=cs:C1710.OpenAIMessage.new({role: "user"; \
		content: [\
		{type: "text"; text: $prompt}; \
		{type: "image_url"; image_url: {url: This:C1470.imageURL; detail: "low"}}\
		]})
	
	If ($parameters=Null:C1517)
		$parameters:={}
	End if 
	If ($parameters.model=Null:C1517)
		$parameters.model:="gpt-4o-mini"
	End if 
	
	return This:C1470.chat.completions.create([$message]; $parameters)