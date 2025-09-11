property chat : cs:C1710.OpenAIChatAPI
property systemPrompt : cs:C1710.OpenAIMessage
property numberOfMessages : Integer:=5
property parameters : cs:C1710.OpenAIChatCompletionsParameters

property messages : Collection:=[]

// user formula call save
property _onData : 4D:C1709.Function
property _onTerminate : 4D:C1709.Function
property _onError : 4D:C1709.Function
property _onResponse : 4D:C1709.Function

property lastErrors : Collection

Class constructor($chat : cs:C1710.OpenAIChatAPI; $systemPrompt : Text; $parameters : cs:C1710.OpenAIChatCompletionsParameters)
	This:C1470.chat:=$chat
	This:C1470.systemPrompt:=cs:C1710.OpenAIMessage.new({role: "system"; content: $systemPrompt})
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIChatCompletionsParameters)))
		$parameters:=cs:C1710.OpenAIChatCompletionsParameters.new($parameters)
	End if 
	This:C1470.parameters:=$parameters
	If (This:C1470.parameters.model=Null:C1517)
		This:C1470.parameters.model:="gpt-4o-mini"
	End if 
	
	If (This:C1470.parameters._isAsync())
		// save user formula
		This:C1470._onData:=This:C1470.parameters.onData
		This:C1470._onTerminate:=This:C1470.parameters.onTerminate
		This:C1470._onResponse:=This:C1470.parameters.onResponse
		This:C1470._onError:=This:C1470.parameters.onError
		
		If (This:C1470.parameters.onData#Null:C1517)
			This:C1470.parameters.onData:=This:C1470._manageAsyncResponse
		End if 
		If (This:C1470.parameters.onTerminate#Null:C1517)
			This:C1470.parameters.onTerminate:=This:C1470._manageAsyncResponse
		End if 
		If (This:C1470.parameters.onResponse#Null:C1517)
			This:C1470.parameters.onResponse:=This:C1470._manageAsyncResponse
		End if 
		If (This:C1470.parameters.onError#Null:C1517)
			This:C1470.parameters.onError:=This:C1470._manageAsyncResponse
		End if 
		
		// to replace by one of us
		This:C1470.parameters._formulaThis:=This:C1470
	End if 
	
Function prompt($prompt : Text) : cs:C1710.OpenAIChatCompletionsResult
	
	If (This:C1470.parameters._isAsync())
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
		This:C1470._manageResponse($result)  // sync
	End if 
	return $result
	
	// Reset chat context, ie. remove messages
Function reset()
	This:C1470.messages:=[]
	
	// Remove the first message if there are more than numberOfMessages.
Function _trim()
	If (This:C1470.numberOfMessages>0)
		While (This:C1470.messages.length>This:C1470.numberOfMessages)
			This:C1470.messages.remove(0)
		End while 
	End if 
	
Function _manageResponse($result : Object)
	If ($result=Null:C1517)
		return 
	End if 
	
	If (This:C1470.parameters.stream)
		
		If ($result.terminated)
			
			This:C1470._notifyOnTerminate($result)
			
		Else 
			
			If (($result.choice=Null:C1517) || ($result.choice.delta=Null:C1517))
				return 
			End if 
			
			var $message:=This:C1470.messages.last()
			Case of 
				: ($message.role="user")
					This:C1470.messages.push($result.choice.delta)
				: ($message.role="assistant")
					$message.text+=$result.choice.delta.text
			End case 
			
			If (This:C1470._onData#Null:C1517)
				This:C1470._onData.call(This:C1470.chat._client; $result)
			End if 
			
		End if 
		
	Else 
		
		If (Not:C34($result.terminated))
			// must not occurs
			return 
		End if 
		
		If ($result.success)
			
			This:C1470.messages.push($result.choice.message)
			
			This:C1470._trim()
			
		Else 
			
			This:C1470.lastErrors:=$result.error
			
		End if 
		
		This:C1470._notifyOnTerminate()
		
	End if 
	
Function _notifyOnTerminate($result)
	If ($result.success)
		
		If (This:C1470._onResponse#Null:C1517)
			This:C1470._onResponse.call(This:C1470.chat._client; $result)
		End if 
		
	Else 
		
		If (This:C1470._onError#Null:C1517)
			This:C1470._onError.call(This:C1470.chat._client; $result)
		End if 
		
	End if 
	
	If (This:C1470._onTerminate#Null:C1517)
		This:C1470._onTerminate.call(This:C1470.chat._client; $result)
	End if 
	
Function _manageAsyncResponse($result : Object)
	This:C1470._manageResponse($result)
	