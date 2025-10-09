property chat : cs:C1710.OpenAIChatAPI
property systemPrompt : cs:C1710.OpenAIMessage
property numberOfMessages : Integer:=15
property parameters : cs:C1710.OpenAIChatCompletionsParameters

property messages : Collection:=[]

// user formula call save
property _onData : 4D:C1709.Function
property _onTerminate : 4D:C1709.Function
property _onError : 4D:C1709.Function
property _onResponse : 4D:C1709.Function
property _formula : 4D:C1709.Function
property _formulaThis : Object

property lastErrors : Collection

// List of registered OpenAI tools. Use "registerTool" if you want to automatically handle tool calls functionally.
property tools : Collection:=[]

// Contains formulas to execute tool calls
property _toolHandlers : Object:={}

// Boolean indicating whether tool calls are handled automatically using registered tools
property autoHandleToolCalls : Boolean:=True:C214

// Initialize the chat helper with a system prompt and some parameters
Class constructor($chat : cs:C1710.OpenAIChatAPI; $systemPrompt : Text; $parameters : cs:C1710.OpenAIChatCompletionsParameters)
	This:C1470.chat:=$chat
	This:C1470.systemPrompt:=cs:C1710.OpenAIMessage.new({role: "system"; content: $systemPrompt})
	
	This:C1470._formulaThis:=$parameters  // original object as this
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIChatCompletionsParameters)))
		$parameters:=cs:C1710.OpenAIChatCompletionsParameters.new($parameters)
	End if 
	This:C1470.parameters:=$parameters
	If (This:C1470.parameters.model=Null:C1517)
		This:C1470.parameters.model:="gpt-4o-mini"
	End if 
	
	// Initialize tool-related properties if needed
	If (This:C1470.parameters.tools#Null:C1517)
		This:C1470.registerTools(This:C1470.parameters.tools)
	End if 
	
	If (This:C1470.parameters._isAsync())
		
		This:C1470.messages:=New shared collection:C1527
		
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
	
Function _pushMessage($message : cs:C1710.OpenAIMessage)
	
	If (This:C1470.parameters._isAsync())  // or is shared?
		Use (This:C1470.messages)
			This:C1470.messages.push(OB Copy:C1225($message; ck shared:K85:29; This:C1470.messages))
		End use 
	Else 
		This:C1470.messages.push($message)
	End if 
	
Function prompt($prompt : Variant) : cs:C1710.OpenAIChatCompletionsResult
	var $type:=Value type:C1509($prompt)
	Case of 
		: ($type=Is text:K8:3)
			var $message:=cs:C1710.OpenAIMessage.new({role: "user"; content: $prompt})
		: ($type=Is object:K8:27)
			Case of 
				: (OB Instance of:C1731($prompt; cs:C1710.OpenAIMessage))
					$message:=$prompt
				: ($prompt.content#Null:C1517)
					$message:=cs:C1710.OpenAIMessage.new($prompt)
					If ($message.role=Null:C1517)
						$message.role:="user"
					End if 
				Else 
					$message:=cs:C1710.OpenAIMessage.new({role: "user"; content: $prompt})
			End case 
		Else 
			throw:C1805(1; "Cannot prompt with parameter of type "+String:C10(Value type:C1509($type))+". Must a Text or OpenAIMessage")
	End case 
	
	This:C1470._pushMessage($message)
	
	var $messages : Collection:=This:C1470.messages.copy()
	$messages.unshift(This:C1470.systemPrompt)
	
	var $result:=This:C1470.chat.completions.create($messages; This:C1470.parameters)
	If ($result#Null:C1517)
		$result:=This:C1470._manageResponse($result)  // sync
	End if 
	return $result
	
	// Reset chat context, ie. remove messages and tools
Function reset()
	
	If (This:C1470.parameters._isAsync())
		This:C1470.messages:=New shared collection:C1527
	Else 
		This:C1470.messages:=[]
	End if 
	
	This:C1470.unregisterTools()
	
	// Register a tool with its handler function or a handler object where we call the function with the tool name
	// If the handler function is not defined, we try to get one from $tool.handler property.
	// Tool could be defined in a "tool" attribute too to be separated from handler code
Function registerTool($tool : Object; $handler : Object)
	If ($tool=Null:C1517)
		return 
	End if 
	
	If (($handler=Null:C1517) && ($tool.handler#Null:C1517))
		$handler:=$tool.handler
	End if 
	
	If (($handler=Null:C1517) && ($tool.handler=Null:C1517))
		var $possibleName : Text:=$tool.name || $tool.tool.name || $tool.function.name || $tool.tool.function.name
		If ($tool[$possibleName]#Null:C1517)
			$handler:=$tool
		End if 
	End if 
	
	If (Not:C34(OB Instance of:C1731($tool; cs:C1710.OpenAITool)))
		$tool:=cs:C1710.OpenAITool.new($tool)
	End if 
	
	// If not a function type, just add it to parameters
	If (Not:C34(String:C10($tool.type)="function"))
		
		If (This:C1470.parameters.tools=Null:C1517)
			This:C1470.parameters.tools:=[]
		End if 
		This:C1470.parameters.tools.push($tool)
		
		return 
		
	End if 
	
	var $functionName : Text:=$tool.name
	
	// Remove existing tool if it exists (this handles all cleanup)
	This:C1470.unregisterTool($functionName)
	
	If ($handler=Null:C1517)
		$handler:=$tool.handler
	End if 
	
	If ($handler=Null:C1517)
		// throw(1; "You must defined an handler for the tool "+$functionName)
		return 
	End if 
	
	// Add tool to the tools collection
	This:C1470.tools.push($tool)
	
	// Register the handler function
	This:C1470._toolHandlers[$functionName]:=$handler
	
	// Add tools to parameters if not already set
	If (This:C1470.parameters.tools=Null:C1517)
		This:C1470.parameters.tools:=[]
	End if 
	
	// Add the new tool to parameters
	This:C1470.parameters.tools.push($tool)
	
	// Register multiple tools at once.
	// Tools to be registered need an handler function.
Function registerTools($toolsWithHandlers : Variant)
	Case of 
		: ($toolsWithHandlers=Null:C1517)
			return 
			
		: ((Value type:C1509($toolsWithHandlers)=Is object:K8:27) && (Value type:C1509($toolsWithHandlers.tools)=Is collection:K8:32))
			
			For each ($tool; $toolsWithHandlers.tools)
				
				This:C1470.registerTool($tool; $toolsWithHandlers)
				
			End for each 
			
		: (Value type:C1509($toolsWithHandlers)=Is object:K8:27)
			
			var $functionName : Text
			For each ($functionName; $toolsWithHandlers)
				var $toolInfo : Object:=$toolsWithHandlers[$functionName]
				
				var $tool : Object:=($toolInfo.tool=Null:C1517) ? $toolInfo : $toolInfo.tool
				If ($tool=Null:C1517)
					continue
				End if 
				
				// help if name not filled?
				If (($tool.name=Null:C1517) || (($tool.function#Null:C1517) && (String:C10($tool.type)="function") && ($tool.function.name=Null:C1517)))
					
					If ($tool.function#Null:C1517)
						$tool.function.name:=$functionName
					Else 
						$tool.name:=$functionName
					End if 
				End if 
				
				// finally register
				This:C1470.registerTool($tool; $toolInfo.handler)
				
			End for each 
			
		: (Value type:C1509($toolsWithHandlers)=Is collection:K8:32)
			
			For each ($toolInfo; $toolsWithHandlers)
				
				$tool:=($toolInfo.tool=Null:C1517) ? $toolInfo : $toolInfo.tool
				If ($tool=Null:C1517)
					continue
				End if 
				
				If (($tool.name=Null:C1517) && ($tool.type=Null:C1517))
					continue
				End if 
				This:C1470.registerTool($tool; $toolInfo.handler)
				
			End for each 
			
		Else 
			
			ASSERT:C1129(False:C215; "Wrong type parameter when registering tools")
			
	End case 
	
	
	// Unregister a specific tool by function name
Function unregisterTool($functionName : Text)
	If (Length:C16($functionName)=0)
		return 
	End if 
	
	// Remove from toolHandlers
	If (This:C1470._toolHandlers[$functionName]#Null:C1517)
		OB REMOVE:C1226(This:C1470._toolHandlers; $functionName)
	End if 
	
	// Remove from tools collection
	var $index : Integer:=0
	While ($index<This:C1470.tools.length)
		If (This:C1470.tools[$index].name=$functionName)
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
			If (This:C1470.parameters.tools[$index].name=$functionName)
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
	This:C1470._toolHandlers:={}
	
	// Clear tools collection
	This:C1470.tools:=[]
	
	// Clear tools from parameters
	If (This:C1470.parameters.tools#Null:C1517)
		This:C1470.parameters.tools:=[]
	End if 
	
	// Remove messages to keep conversation under numberOfMessages limit.
	// Prioritize removing complete tool call sequences to maintain coherence.
Function _trim()
	If (This:C1470.numberOfMessages<=0)
		return 
	End if 
	
	While (This:C1470.messages.length>This:C1470.numberOfMessages)
		
		var $removedSequence : Boolean:=False:C215
		
		// First priority: Try to remove complete tool call sequences
		// Look for assistant messages with tool_calls followed by tool responses
		var $i : Integer:=0
		While ($i<This:C1470.messages.length) && (Not:C34($removedSequence))
			
			var $message : cs:C1710.OpenAIMessage:=This:C1470.messages[$i]
			
			// Check if this is an assistant message with tool calls
			If ($message.role="assistant") && ($message.tool_calls#Null:C1517) && ($message.tool_calls.length>0)
				
				// Find all associated tool response messages
				var $toolCallIds : Collection:=[]
				var $toolCall : Object
				For each ($toolCall; $message.tool_calls)
					If ($toolCall.id#Null:C1517)
						$toolCallIds.push($toolCall.id)
					End if 
				End for each 
				
				// Count how many tool responses follow this message
				var $toolResponseCount : Integer:=0
				var $j : Integer:=$i+1
				var $foundToolCallIds : Collection:=[]
				
				While ($j<This:C1470.messages.length)
					var $nextMessage : cs:C1710.OpenAIMessage:=This:C1470.messages[$j]
					If ($nextMessage.role="tool") && ($nextMessage.tool_call_id#Null:C1517)
						
						// Check if this tool response belongs to our tool call
						If ($toolCallIds.indexOf($nextMessage.tool_call_id)>=0)
							$toolResponseCount:=$toolResponseCount+1
							$foundToolCallIds.push($nextMessage.tool_call_id)
						Else 
							// This tool response belongs to a different tool call, stop here
							break
						End if 
						
					Else 
						// Not a tool response, stop looking
						break
					End if 
					$j:=$j+1
				End while 
				
				// If we found all expected tool responses, remove the complete sequence
				If ($foundToolCallIds.length=$toolCallIds.length)
					// Remove tool responses first (from end to start to maintain indices)
					var $k : Integer:=$i+$toolResponseCount
					While ($k>$i)
						This:C1470.messages.remove($k)
						$k:=$k-1
					End while 
					// Remove the assistant message with tool calls
					This:C1470.messages.remove($i)
					$removedSequence:=True:C214
				End if 
				
			End if 
			
			$i:=$i+1
		End while 
		
		// If no complete tool call sequence was found, remove the first message
		// This maintains the original behavior for non-tool messages
		If (Not:C34($removedSequence))
			This:C1470.messages.remove(0)
		End if 
		
	End while 
	
Function _manageResponse($result : Object) : Object
	If ($result=Null:C1517)
		return 
	End if 
	
	// MARK: _manageResponse stream
	If (This:C1470.parameters.stream)
		
		If ($result.terminated)
			
			If ($result.success)
				This:C1470._trim()
			End if 
			
			If (This:C1470.autoHandleToolCalls && ($result.success) && ($result.choice#Null:C1517) && (String:C10($result.choice.finish_reason)="tool_calls"))
				
				var $lastMessage:=This:C1470.messages.last()
				This:C1470._handleAsyncToolCalls($result; $lastMessage)
				If ($result._newResult#Null:C1517)
					return $result._newResult  // we already manage _notifyOnTerminate
				End if 
				
			End if 
			
			This:C1470._notifyOnTerminate($result)
			
		Else 
			
			If (($result.choice=Null:C1517) || ($result.choice.delta=Null:C1517))
				return 
			End if 
			
			var $message:=This:C1470.messages.last()
			Case of 
				: ($message.role="assistant")
					$message._accumulateDelta($result.choice.delta)
				Else 
					This:C1470._pushMessage($result.choice.delta)
			End case 
			
			If (This:C1470._onData#Null:C1517)
				This:C1470._onData.call(This:C1470._formulaThis || This:C1470.chat._client; $result)
			End if 
			If (This:C1470._formula#Null:C1517)
				This:C1470._formula.call(This:C1470._formulaThis || This:C1470.chat._client; $result)
			End if 
			
		End if 
		
		// MARK: _manageResponse no stream
	Else 
		If (Not:C34($result.terminated))
			// must not occurs
			return $result
		End if 
		
		If ($result.success)
			
			This:C1470._pushMessage($result.choice.message)
			
			This:C1470._trim()
			
			// Check for tool calls and handle them automatically
			If (This:C1470.autoHandleToolCalls) && ($result.choice.message.tool_calls#Null:C1517)
				This:C1470._handleToolCalls($result)
				If ($result._newResult#Null:C1517)
					return $result._newResult  // we already manage _notifyOnTerminate
				End if 
			End if 
			
		Else 
			
			This:C1470.lastErrors:=$result.error
			
		End if 
		
		This:C1470._notifyOnTerminate($result)
		
	End if 
	return $result
	
Function _notifyOnTerminate($result)
	If ($result.success)
		
		If (This:C1470._onResponse#Null:C1517)
			This:C1470._onResponse.call(This:C1470._formulaThis || This:C1470.chat._client; $result)
		End if 
		
	Else 
		
		If (This:C1470._onError#Null:C1517)
			This:C1470._onError.call(This:C1470._formulaThis || This:C1470.chat._client; $result)
		End if 
		
	End if 
	
	If (This:C1470._onTerminate#Null:C1517)
		This:C1470._onTerminate.call(This:C1470._formulaThis || This:C1470.chat._client; $result)
	End if 
	If (This:C1470._formula#Null:C1517)
		This:C1470._formula.call(This:C1470._formulaThis || This:C1470.chat._client; $result)
	End if 
	
Function _manageAsyncResponse($result : Object)
	This:C1470._manageResponse($result)
	
	// Handle tool calls automatically
Function _handleToolCalls($result : cs:C1710.OpenAIChatCompletionsResult)
	var $toolResponses:=This:C1470._processToolCalls($result.choice.message)
	If ($toolResponses=Null:C1517) || ($toolResponses.length=0)
		return 
	End if 
	
	// Add tool responses to messages
	var $response : cs:C1710.OpenAIMessage
	For each ($response; $toolResponses)
		
		This:C1470._pushMessage($response)
		
	End for each 
	
	// Continue the conversation by making another API call
	This:C1470._continueConversationAfterToolCalls($result)
	
	// Continue conversation after tool calls
Function _continueConversationAfterToolCalls($result : cs:C1710.OpenAIChatCompletionsResult)
	var $messages : Collection:=This:C1470.messages.copy()
	$messages.unshift(This:C1470.systemPrompt)
	
	// Create a copy of parameters without modifying the original
	var $parameters : cs:C1710.OpenAIChatCompletionsParameters:=cs:C1710.OpenAIChatCompletionsParameters.new(This:C1470.parameters)
	
	// Make another call to continue the conversation
	var $newResult:=This:C1470.chat.completions.create($messages; $parameters)
	If ($newResult#Null:C1517)
		//%W-550.26
		$result._newResult:=This:C1470._manageResponse($newResult)  // This will handle sync
		//%W+550.26
	End if 
	
	
	// Handle tool calls automatically for async/streaming responses
Function _handleAsyncToolCalls($result : cs:C1710.OpenAIChatCompletionsStreamResult; $lastMessage : cs:C1710.OpenAIMessage)
	var $toolResponses:=This:C1470._processToolCalls($lastMessage)
	If ($toolResponses=Null:C1517) || ($toolResponses.length=0)
		return 
	End if 
	
	// Add tool responses to messages
	var $response : cs:C1710.OpenAIMessage
	For each ($response; $toolResponses)
		This:C1470._pushMessage($response)
	End for each 
	
	// Continue the conversation by making another API call
	This:C1470._continueAsyncConversationAfterToolCalls($result)
	
	
	// Continue async conversation after tool calls
Function _continueAsyncConversationAfterToolCalls($result : cs:C1710.OpenAIChatCompletionsStreamResult)
	var $messages : Collection:=This:C1470.messages.copy()
	$messages.unshift(This:C1470.systemPrompt)
	
	// Make another call to continue the conversation
	var $newResult:=This:C1470.chat.completions.create($messages; This:C1470.parameters)
	If ($newResult#Null:C1517)
		//%W-550.26
		$result._newResult:=$newResult
		//%W+550.26
	End if 
	
	// Process tool calls and return collection of response messages
Function _processToolCalls($message : cs:C1710.OpenAIMessage) : Collection
	var $toolCalls:=$message.tool_calls
	If ($toolCalls=Null:C1517) || ($toolCalls.length=0)
		return Null:C1517
	End if 
	
	var $toolResponses : Collection:=[]
	var $toolCall : Object
	For each ($toolCall; $toolCalls)
		If ($toolCall.function=Null:C1517) || ($toolCall.function.name=Null:C1517)
			continue
		End if 
		
		var $functionName : Text:=$toolCall.function.name
		var $handler : Object:=This:C1470._toolHandlers[$functionName]
		
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
		If (($toolCall.function.arguments#Null:C1517) && (Length:C16(String:C10($toolCall.function.arguments))>0))
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
		
		// Check function exist in handler object
		If ((Not:C34(OB Instance of:C1731($handler; 4D:C1709.Function))) && ($handler[$toolCall.function.name]=Null:C1517))
			var $missingFunctionResponse:=cs:C1710.OpenAIMessage.new()
			$missingFunctionResponse.role:="tool"
			$missingFunctionResponse.tool_call_id:=$toolCall.id
			$missingFunctionResponse.content:="Error: unknown function '"+$functionName+"'. Seems not implemented."
			$toolResponses.push($missingFunctionResponse)
			continue
		End if 
		
		// Execute the tool function
		Try
			var $resultHandler : Variant
			If (OB Instance of:C1731($handler; 4D:C1709.Function))
				$resultHandler:=$handler.call(This:C1470; $arguments)
			Else 
				$resultHandler:=$handler[$toolCall.function.name]($arguments)
			End if 
			
			var $toolResponse:=cs:C1710.OpenAIMessage.new()
			$toolResponse.role:="tool"
			$toolResponse.tool_call_id:=$toolCall.id
			
			// Convert result to string if necessary
			Case of 
				: (Value type:C1509($resultHandler)=Is text:K8:3)
					$toolResponse.content:=$resultHandler
				: (Value type:C1509($resultHandler)=Is object:K8:27) || (Value type:C1509($resultHandler)=Is collection:K8:32)
					$toolResponse.content:=JSON Stringify:C1217($resultHandler)
				Else 
					$toolResponse.content:=String:C10($resultHandler)
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
	
	return $toolResponses
	
	