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
property _formula : 4D:C1709.Function

property lastErrors : Collection

// tool call handling
property tools : Collection:=[]
property toolHandlers : Object:={}
property autoHandleToolCalls : Boolean:=False:C215

Class constructor($chat : cs:C1710.OpenAIChatAPI; $systemPrompt : Text; $parameters : cs:C1710.OpenAIChatCompletionsParameters)
	This:C1470.chat:=$chat
	This:C1470.systemPrompt:=cs:C1710.OpenAIMessage.new({role: "system"; content: $systemPrompt})
	
	// Initialize tool-related properties
	This:C1470.tools:=[]
	This:C1470.toolHandlers:={}
	This:C1470.autoHandleToolCalls:=True:C214
	
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
		This:C1470._formula:=This:C1470.parameters.formula
		
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
		If (This:C1470.parameters.formula#Null:C1517)
			This:C1470.parameters.formula:=This:C1470._manageAsyncResponse
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
Function reset($unregisterTools : Boolean)
	This:C1470.messages:=[]
	
	If ($unregisterTools)
		This:C1470.unregisterTools()
	End if
	
	// Register a tool with its handler function
Function registerTool($tool : Object; $handler : 4D:C1709.Function)
	If ($tool=Null:C1517)
		return 
	End if 
	
	If ($tool.function=Null:C1517) || ($tool.function.name=Null:C1517)
		return   // Invalid tool definition
	End if 
	
	var $functionName : Text:=$tool.function.name
	
	// Remove existing tool if it exists (this handles all cleanup)
	This:C1470.unregisterTool($functionName)
	
	// Add tool to the tools collection
	This:C1470.tools.push($tool)
	
	// Register the handler function
	If ($handler#Null:C1517)
		This:C1470.toolHandlers[$functionName]:=$handler
	End if 
	
	// Add tools to parameters if not already set
	If (This:C1470.parameters.tools=Null:C1517)
		This:C1470.parameters.tools:=[]
	End if 
	
	// Add the new tool to parameters
	This:C1470.parameters.tools.push($tool) 
	
	// Register multiple tools at once
Function registerTools($toolsWithHandlers : Object)
	If ($toolsWithHandlers=Null:C1517)
		return 
	End if 
	var $functionName : Text
	For each ($functionName; $toolsWithHandlers)
		var $toolInfo : Object:=$toolsWithHandlers[$functionName]
		
		If ($toolInfo.tool#Null:C1517) && ($toolInfo.handler#Null:C1517)
			This:C1470.registerTool($toolInfo.tool; $toolInfo.handler)
		End if 
	End for each 
	
	// Unregister a specific tool by function name
Function unregisterTool($functionName : Text)
	If (Length:C16($functionName)=0)
		return 
	End if 
	
	// Remove from toolHandlers
	If (This:C1470.toolHandlers[$functionName]#Null:C1517)
		OB REMOVE:C1226(This:C1470.toolHandlers; $functionName)
	End if 
	
	// Remove from tools collection
	var $index : Integer:=0
	While ($index<This:C1470.tools.length)
		If (This:C1470.tools[$index].function.name=$functionName)
			This:C1470.tools.remove($index)
			break
		Else 
			$index+=1
		End if 
	End while 
	
	// Remove from parameters.tools collection
	If (This:C1470.parameters.tools#Null:C1517)
		$index:=0
		While ($index<This:C1470.parameters.tools.length)
			If (This:C1470.parameters.tools[$index].function.name=$functionName)
				This:C1470.parameters.tools.remove($index)
				break
			Else 
				$index+=1
			End if 
		End while 
	End if 
	
	// Unregister all tools
Function unregisterTools()
	// Clear all tool handlers
	This:C1470.toolHandlers:={}
	
	// Clear tools collection
	This:C1470.tools:=[]
	
	// Clear tools from parameters
	If (This:C1470.parameters.tools#Null:C1517)
		This:C1470.parameters.tools:=[]
	End if 
	
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
			If (This:C1470._formula#Null:C1517)
				This:C1470._formula.call(This:C1470.chat._client; $result)
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
			
			// Check for tool calls and handle them automatically
			If (This:C1470.autoHandleToolCalls) && ($result.choice.message.tool_calls#Null:C1517)
				This:C1470._handleToolCalls($result.choice.message.tool_calls)
			End if 
			
		Else 
			
			This:C1470.lastErrors:=$result.error
			
		End if 
		
		This:C1470._notifyOnTerminate($result)
		
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
	If (This:C1470._formula#Null:C1517)
		This:C1470._formula.call(This:C1470.chat._client; $result)
	End if 
	
Function _manageAsyncResponse($result : Object)
	This:C1470._manageResponse($result)
	
	// Handle tool calls automatically
Function _handleToolCalls($toolCalls : Collection)
	If ($toolCalls=Null:C1517) || ($toolCalls.length=0)
		return 
	End if 
	
	var $toolResponses : Collection:=[]
	var $toolCall : Object
	For each ($toolCall; $toolCalls)
		If ($toolCall.function=Null:C1517) || ($toolCall.function.name=Null:C1517)
			continue
		End if 
		
		var $functionName : Text:=$toolCall.function.name
		var $handler : 4D:C1709.Function:=This:C1470.toolHandlers[$functionName]
		
		If ($handler=Null:C1517)
			// No handler registered for this function
			var $noHandlerResponse:=cs:C1710.OpenAIMessage.new()
			$noHandlerResponse.role:="tool"
			$noHandlerResponse.tool_call_id:=$toolCall.id
			$noHandlerResponse.content:="Error: No handler registered for function '"+$functionName+"'"
			$toolResponses.push($noHandlerResponse)
			continue
		End if 
		
		// Parse function arguments
		var $arguments : Object
		If ($toolCall.function.arguments#Null:C1517)
			Try
				$arguments:=JSON Parse:C1218($toolCall.function.arguments)
			Catch
				var $parseErrorResponse:=cs:C1710.OpenAIMessage.new()
				$parseErrorResponse.role:="tool"
				$parseErrorResponse.tool_call_id:=$toolCall.id
				$parseErrorResponse.content:="Error: Invalid JSON arguments for function '"+$functionName+"'"
				$toolResponses.push($parseErrorResponse)
				continue
			End try
		Else 
			$arguments:={}
		End if 
		
		// Execute the tool function
		Try
			var $result : Variant:=$handler.call(This:C1470; $arguments)
			
			var $toolResponse:=cs:C1710.OpenAIMessage.new()
			$toolResponse.role:="tool"
			$toolResponse.tool_call_id:=$toolCall.id
			
			// Convert result to string if necessary
			Case of 
				: (Value type:C1509($result)=Is text:K8:3)
					$toolResponse.content:=$result
				: (Value type:C1509($result)=Is object:K8:27) || (Value type:C1509($result)=Is collection:K8:32)
					$toolResponse.content:=JSON Stringify:C1217($result)
				Else 
					$toolResponse.content:=String:C10($result)
			End case 
			
			$toolResponses.push($toolResponse)
			
		Catch
			var $executionErrorResponse:=cs:C1710.OpenAIMessage.new()
			$executionErrorResponse.role:="tool"
			$executionErrorResponse.tool_call_id:=$toolCall.id
			$executionErrorResponse.content:="Error executing function '"+$functionName+"': "+Last errors:C1799.last().message
			$toolResponses.push($executionErrorResponse)
		End try
		
	End for each 
	
	// Add tool responses to messages
	var $response : cs:C1710.OpenAIMessage
	For each ($response; $toolResponses)
		This:C1470.messages.push($response)
	End for each 
	
	// Continue the conversation by making another API call
	This:C1470._continueConversationAfterToolCalls()
	
	// Continue conversation after tool calls
Function _continueConversationAfterToolCalls()
	var $messages : Collection:=This:C1470.messages.copy()
	$messages.unshift(This:C1470.systemPrompt)
	
	// Create a copy of parameters without modifying the original
	var $parameters : cs:C1710.OpenAIChatCompletionsParameters:=cs:C1710.OpenAIChatCompletionsParameters.new(This:C1470.parameters)
	
	// Make another call to continue the conversation
	var $result:=This:C1470.chat.completions.create($messages; $parameters)
	If ($result#Null:C1517)
		This:C1470._manageResponse($result)  // This will handle both sync and async
	End if 
	