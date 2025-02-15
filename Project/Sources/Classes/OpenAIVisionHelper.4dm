property chat : cs:C1710.OpenAIChat
property imageURL : Text
property parameters : cs:C1710.OpenAIChatCompletionParameters

Class constructor($chat : cs:C1710.OpenAIChat; $imageURL : Text; $parameters : cs:C1710.OpenAIChatCompletionParameters)
	This:C1470.chat:=$chat
	This:C1470.imageURL:=$imageURL
	This:C1470.parameters:=$parameters
	If (This:C1470.parameters=Null:C1517)
		This:C1470.parameters:={}
	End if 
	If (This:C1470.parameters.model=Null:C1517)
		This:C1470.parameters.model:="gpt-4o-mini"
	End if 
	
Function prompt($prompt : Text) : cs:C1710.OpenAIChatCompletionsResult
	
	var $message:=cs:C1710.Message.new({role: "user"})
	$message.content:=[\
		{type: "text"; text: $prompt}; \
		{type: "image_url"; image_url: {url: This:C1470.imageURL; detail: "low"}}\
		]
	
	return This:C1470.chat.completions.create([$message]; This:C1470.parameters)