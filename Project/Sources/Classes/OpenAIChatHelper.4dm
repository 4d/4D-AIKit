property chat : cs:C1710.OpenAIChatAPI
property systemPrompt : cs:C1710.Message
property numberOfMessage : Integer:=5
property parameters : cs:C1710.OpenAIChatCompletionParameters

property messages : Collection:=[]

property _userFormula : 4D:C1709.Function

Class constructor($chat : cs:C1710.OpenAIChatAPI; $systemPrompt : Text; $parameters : cs:C1710.OpenAIChatCompletionParameters)
	This:C1470.chat:=$chat
	This:C1470.systemPrompt:=cs:C1710.OpenAIMessage.new({role: "system"; content: $systemPrompt})
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIChatCompletionParameters)))
		$parameters:=cs:C1710.OpenAIChatCompletionParameters.new($parameters)
	End if 
	This:C1470.parameters:=$parameters
	If (This:C1470.parameters.model=Null:C1517)
		This:C1470.parameters.model:="gpt-4o-mini"
	End if 
	
	If (This:C1470.parameters.formula#Null:C1517)
		This:C1470._userFormula:=This:C1470.parameters.formula
		This:C1470.parameters.formula:=This:C1470._manageAsyncResponse
		This:C1470.parameters._formulaThis:=This:C1470
	End if 
	
Function prompt($prompt : Text) : cs:C1710.OpenAIChatCompletionsResult
	
	If (This:C1470.parameters.formula#Null:C1517)
		Use (This:C1470.messages)
			This:C1470.messages.push(OB Copy:C1225(cs:C1710.OpenAIMessage.new({role: "user"; content: $prompt}); ck shared:K85:29; This:C1470.messages))
		End use 
	Else 
		This:C1470.messages.push(cs:C1710.OpenAIMessage.new({role: "user"; content: $prompt}))
	End if 
	
	var $messages : Collection:=This:C1470.messages.copy()
	$messages.unshift(This:C1470.systemPrompt)
	
	var $result:=This:C1470.chat.completions.create($messages; This:C1470.parameters)
	If ($result#Null:C1517)
		This:C1470._manageResponse($result)
	End if 
	return $result
	
Function _manageResponse($result : Object)
	If ($result.success)
		This:C1470.messages.push($result.choices.first().message)
		
		If (This:C1470.messages.length>This:C1470.numberOfMessage)
			This:C1470.messages.remove(0)
			// XXX: maybe remove assistant if first?
		End if 
		
	End if 
	
Function _manageAsyncResponse($result : Object)
	If ($result#Null:C1517)
		If ($result.success)
			Use (This:C1470.messages)
				This:C1470.messages.push(OB Copy:C1225($result.choices.first().message; ck shared:K85:29; This:C1470.messages))
				
				If (This:C1470.messages.length>This:C1470.numberOfMessage)
					This:C1470.messages.remove(0)
					// XXX: maybe remove assistant if first?
				End if 
				
			End use 
			
		End if 
		If (This:C1470._userFormula#Null:C1517)
			This:C1470._userFormula.call(This:C1470.chat._client; $result)
		End if 
		
	End if 