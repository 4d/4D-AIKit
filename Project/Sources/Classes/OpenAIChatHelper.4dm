property chat : cs:C1710.OpenAIChatAPI
property systemPrompt : cs:C1710.OpenAIMessage
property numberOfMessages : Integer:=5
property parameters : cs:C1710.OpenAIChatCompletionParameters

property messages : Collection:=[]

property _userFormula : 4D:C1709.Function

property lastErrors : Collection

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
	
	// Reset chat context, ie. remove messages
Function reset()
	This:C1470.messages:=[]
	
	// remove first messages if there is more than numberOfMessages
Function _trim()
	While (This:C1470.messages.length>This:C1470.numberOfMessages)
		This:C1470.messages.remove(0)
	End while 
	
Function _manageResponse($result : Object)
	If ($result=Null:C1517)
		return 
	End if 
	
	If ($result.success)
		
		This:C1470.messages.push($result.choice.message)
		
		This:C1470._trim()
		
	Else 
		
		This:C1470.lastErrors:=$result.error
		
	End if 
	
Function _manageAsyncResponse($result : Object)
	
	This:C1470._manageResponse($result)
	
	If ($result#Null:C1517)
		If (This:C1470._userFormula#Null:C1517)
			This:C1470._userFormula.call(This:C1470.chat._client; $result)
		End if 
	End if 