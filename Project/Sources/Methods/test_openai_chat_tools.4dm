//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// MARK:- chat with tools
var $modelName:=cs:C1710._TestModels.new($client).chats

// Define a simple tool that returns database table list
var $getDatabaseTablesTool:={type: "function"; \
function: {name: "get_database_tables"; \
description: "Get the list of all database tables"; \
parameters: {}}; \
strict: True:C214}

var $messages:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant that can access database information."})]
$messages.push({role: "user"; content: "What tables are available in the database?"})

var $result:=$client.chat.completions.create($messages; {model: $modelName; tools: [$getDatabaseTablesTool]})

If (Asserted:C1132(Bool:C1537($result.success); "Cannot complete chat : "+JSON Stringify:C1217($result)))
	
	If (Asserted:C1132($result.choice#Null:C1517; "chat do not return a choice"))
		
		If (Asserted:C1132($result.choice.message#Null:C1517; "chat do not return a message"))
			
			// Check if the assistant made a tool call
			If ($result.choice.message.tool_calls#Null:C1517) & ($result.choice.message.tool_calls.length>0)
				
				// Add the assistant's message with tool call to messages
				$messages.push($result.choice.message)
				
				// Get the first tool call
				var $toolCall:=$result.choice.message.tool_calls.first()
				ASSERT:C1129($toolCall.function.name="get_database_tables"; "Tool call should be for get_database_tables function")
				
				// Create tool response message using pre-constructed response
				var $toolResponse:=cs:C1710.OpenAIMessage.new()
				$toolResponse.role:="tool"
				$toolResponse.tool_call_id:=$toolCall.id
				$toolResponse.content:=JSON Stringify:C1217(["Users"; "Orders"; "Products"; "Categories"])  // Return mock database table names
				
				$messages.push($toolResponse)
				
				// Continue the conversation with the tool response
				$result:=$client.chat.completions.create($messages; {model: $modelName; tools: [$getDatabaseTablesTool]})
				
				If ((Asserted:C1132($result.choice#Null:C1517)) && (Asserted:C1132($result.choice.message#Null:C1517)))
					
					ASSERT:C1129(Length:C16($result.choice.message.text)>0; "Final chat response should have content")
					
				End if 
				
			Else 
				
				// If no tool call was made, just check we got a response
				ASSERT:C1129(Length:C16($result.choice.message.text)>0; "chat do not return a message text")
				
			End if 
			
		End if 
		
	End if 
	
End if 

// MARK:- Test tool with parameters

// Define a tool that takes arguments - get table info for a specific table
var $getTableInfoTool : Object:={}
var $function:=$getTableInfoTool
If (Shift down:C543)  // to test with full format
	$getTableInfoTool.type:="function"
	$getTableInfoTool.strict:=True:C214
	$getTableInfoTool.function:={}
	$function:=$getTableInfoTool.function
	// else simplyfied format
End if 
$function.name:="get_table_info"
$function.description:="Get detailed information about a specific database table"
$function.parameters:={}
$function.parameters.type:="object"
$function.parameters.properties:={}
$function.parameters.properties.tableName:={type: "string"; description: "The name of the table to get information about"}
$function.parameters.required:=["tableName"]
$function.parameters.additionalProperties:=False:C215

var $messages2:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant that can access database information."})]
$messages2.push({role: "user"; content: "Can you give me detailed information about the Users table?"})

var $result2:=$client.chat.completions.create($messages2; {model: $modelName; tools: [$getTableInfoTool]})

If (Asserted:C1132(Bool:C1537($result2.success); "Cannot complete chat with parameters : "+JSON Stringify:C1217($result2)))
	
	If (Asserted:C1132($result2.choice#Null:C1517; "chat with parameters do not return a choice"))
		
		If (Asserted:C1132($result2.choice.message#Null:C1517; "chat with parameters do not return a message"))
			
			// Check if the assistant made a tool call
			If ($result2.choice.message.tool_calls#Null:C1517) & ($result2.choice.message.tool_calls.length>0)
				
				// Add the assistant's message with tool call to messages
				$messages2.push($result2.choice.message)
				
				// Get the first tool call
				var $toolCall2:=$result2.choice.message.tool_calls.first()
				ASSERT:C1129($toolCall2.function.name="get_table_info"; "Tool call should be for get_table_info function")
				
				// Check that arguments were passed correctly
				var $arguments:=JSON Parse:C1218($toolCall2.function.arguments)
				ASSERT:C1129($arguments.tableName#Null:C1517; "Tool call should have tableName argument")
				ASSERT:C1129(Length:C16($arguments.tableName)>0; "tableName argument should not be empty")
				
				// Create tool response message with table information
				var $toolResponse2:=cs:C1710.OpenAIMessage.new()
				$toolResponse2.role:="tool"
				$toolResponse2.tool_call_id:=$toolCall2.id
				
				// Simulate getting table info (in a real scenario, this would query the database)
				var $tableInfo:={tableName: $arguments.tableName; \
					columns: ["id"; "name"; "email"; "created_at"]; \
					recordCount: 42; \
					description: "User accounts table"}
				$toolResponse2.content:=JSON Stringify:C1217($tableInfo)
				
				$messages2.push($toolResponse2)
				
				// Continue the conversation with the tool response
				$result2:=$client.chat.completions.create($messages2; {model: $modelName; tools: [$getTableInfoTool]})
				
				If ((Asserted:C1132($result2.choice#Null:C1517)) && (Asserted:C1132($result2.choice.message#Null:C1517)))
					
					ASSERT:C1129(Length:C16($result2.choice.message.text)>0; "Final chat response with parameters should have content")
					
				End if 
				
			Else 
				
				// If no tool call was made, just check we got a response
				ASSERT:C1129(Length:C16($result2.choice.message.text)>0; "chat with parameters do not return a message text")
				
			End if 
			
		End if 
		
	End if 
	
End if 


If ((Position:C15("127.0.0.1"; $client.baseURL)>0) && ($client.apiKey="none"))  // mock has no implemented wrong tool call
	return 
End if 

// MARK:- Test with wrong tool_call_id (error case)

// Define a simple tool for testing wrong tool_call_id
var $testWrongIdTool:={type: "function"; \
function: {name: "test_function"; \
description: "A simple test function"; \
parameters: {}}; \
strict: True:C214}

var $messages3:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant."})]
$messages3.push({role: "user"; content: "Call the test function."})

var $result3:=$client.chat.completions.create($messages3; {model: $modelName; tools: [$testWrongIdTool]})

If (Asserted:C1132(Bool:C1537($result3.success); "Cannot complete chat for wrong tool_call_id test : "+JSON Stringify:C1217($result3)))
	
	If (Asserted:C1132($result3.choice#Null:C1517; "chat for wrong tool_call_id test do not return a choice"))
		
		If (Asserted:C1132($result3.choice.message#Null:C1517; "chat for wrong tool_call_id test do not return a message"))
			
			// Check if the assistant made a tool call
			If ($result3.choice.message.tool_calls#Null:C1517) & ($result3.choice.message.tool_calls.length>0)
				
				// Add the assistant's message with tool call to messages
				$messages3.push($result3.choice.message)
				
				// Get the first tool call
				var $toolCall3:=$result3.choice.message.tool_calls.first()
				ASSERT:C1129($toolCall3.function.name="test_function"; "Tool call should be for test_function")
				
				// Create tool response message with WRONG tool_call_id
				var $toolResponse3:=cs:C1710.OpenAIMessage.new()
				$toolResponse3.role:="tool"
				$toolResponse3.tool_call_id:="wrong_id_12345"  // This is intentionally wrong
				$toolResponse3.content:="Function executed successfully"
				
				$messages3.push($toolResponse3)
				
				// Continue the conversation with the wrong tool_call_id
				// This should result in an error from the API
				var $result3b:=$client.chat.completions.create($messages3; {model: $modelName; tools: [$testWrongIdTool]})
				
				// We expect this to fail due to wrong tool_call_id
				If ($result3b.success)
					ASSERT:C1129(False:C215; "API should reject wrong tool_call_id, but it didn't")
				Else 
					// Check that we got an appropriate error
					ASSERT:C1129($result3b.errors.length>0; "Should have error information when using wrong tool_call_id")
					// The error should indicate something about invalid tool_call_id
					var $errorMessage:=""
					If ($result3b.errors.length>0)
						var $firstError:=$result3b.errors.first()
						If ($firstError.message#Null:C1517)
							$errorMessage:=String:C10($firstError.message)
						End if 
						If ($firstError.content#Null:C1517)
							$errorMessage:=$errorMessage+" "+String:C10($firstError.content)
						End if 
					End if 
					ASSERT:C1129(Length:C16($errorMessage)>0; "Error should have a message describing the problem")
				End if 
				
			Else 
				
				ASSERT:C1129(False:C215; "Assistant should make a tool call for this test")
				
			End if 
			
		End if 
		
	End if 
	
End if 