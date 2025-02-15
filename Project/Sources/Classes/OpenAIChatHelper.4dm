property chat : cs:C1710.OpenAIChatAPI
property systemPrompt : cs:C1710.Message
property numberOfMessage : Integer:=5
property parameters : cs:C1710.OpenAIChatCompletionParameters

property messages : Collection:=[]

Class constructor($chat : cs:C1710.OpenAIChatAPI; $systemPrompt : Text; $parameters : cs:C1710.OpenAIChatCompletionParameters)
	This:C1470.chat:=$chat
	This:C1470.systemPrompt:=cs:C1710.OpenAIMessage.new({role: "system"; content: $systemPrompt})
	This:C1470.parameters:=$parameters
	If (This:C1470.parameters=Null:C1517)
		This:C1470.parameters:={}
	End if 
	If (This:C1470.parameters.model=Null:C1517)
		This:C1470.parameters.model:="gpt-4o-mini"
	End if 
	
	
Function prompt($prompt : Text) : cs:C1710.OpenAIChatCompletionsResult
	
	var $messages : Collection:=This:C1470.messages.copy()
	$messages.unshift(This:C1470.systemPrompt)
	
	var $result:=This:C1470.chat.completions.create($messages; This:C1470.parameters)
	If ($result.success)
		This:C1470.messages.push($result.choices.first().message)
		
		If (This:C1470.messages.length>This:C1470.numberOfMessage)
			This:C1470.messages.remove(0)
			// XXX: maybe remove assistant if first?
		End if 
	End if 
	
	return $result
	