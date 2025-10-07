//%attributes = {}
// Test automatic tool call handling in OpenAIChatHelper

var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// Create a helper with auto tool handling enabled
var $helper:=$client.chat.create("You are a helpful assistant that can access database information."; {model: "gpt-4o-mini"})
$helper.autoHandleToolCalls:=True:C214

// Define a simple tool that returns database table list
var $getDatabaseTablesTool:={type: "function"; \
function: {name: "get_database_tables"; \
description: "Get the list of all database tables"; \
parameters: {}; \
required: []; \
additionalProperties: False:C215}; \
strict: True:C214}

// Register the tool with its handler using pre-constructed response
var $toolHandler:=Formula:C1597(JSON Stringify:C1217(["Users"; "Orders"; "Products"; "Categories"]))
// This function will be called when OpenAI requests to use the tool

$helper.registerTool($getDatabaseTablesTool; $toolHandler)

// Test the tool call by asking a question that should trigger it
var $result:=$helper.prompt("What tables are available in the database?")

If (Asserted:C1132($result.success; JSON Stringify:C1217($result)))
	
	// Check that messages contain tool calls and responses
	var $foundToolCall : Boolean:=False:C215
	var $foundToolResponse : Boolean:=False:C215
	var $message : cs:C1710.OpenAIMessage
	For each ($message; $helper.messages)
		If ($message.role="assistant") && ($message.tool_calls#Null:C1517) && ($message.tool_calls.length>0)
			$foundToolCall:=True:C214
			
			// Check if the tool call is for our registered function
			var $toolCall : Object:=$message.tool_calls.first()
			ASSERT:C1129($toolCall.function.name="get_database_tables"; "Tool call should be for get_database_tables function")
		End if 
		
		If ($message.role="tool") && ($message.tool_call_id#Null:C1517)
			$foundToolResponse:=True:C214
			ASSERT:C1129(Length:C16($message.content)>0; "Tool response should have content")
		End if 
	End for each 
	
	ASSERT:C1129($foundToolCall; "Should have found a message with tool_calls")
	ASSERT:C1129($foundToolResponse; "Should have found a tool response message")
	
	
	ASSERT:C1129(String:C10($helper.messages.last().text)=String:C10($result.choice.message.text); "Check result is last message")
	
End if 

// MARK:- Test tool with arguments

// Reset the helper for a new conversation
$helper.reset()

// Define a tool that takes arguments - get table info for a specific table
var $getTableInfoTool : Object:={}
$getTableInfoTool.type:="function"
$getTableInfoTool.strict:=True:C214
$getTableInfoTool.function:={}
$getTableInfoTool.function.name:="get_table_info"
$getTableInfoTool.function.description:="Get detailed information about a specific database table"
$getTableInfoTool.function.parameters:={}
$getTableInfoTool.function.parameters.type:="object"
$getTableInfoTool.function.parameters.properties:={}
$getTableInfoTool.function.parameters.properties.tableName:={type: "string"; description: "The name of the table to get information about"}
$getTableInfoTool.function.parameters.required:=["tableName"]
$getTableInfoTool.function.parameters.additionalProperties:=False:C215

// Register the tool with a handler that uses pre-constructed table info response
$helper.registerTool($getTableInfoTool; Formula:C1597(JSON Stringify:C1217({tableName: $1.tableName; columns: ["id"; "name"; "email"; "created_at"]; fieldCount: 4; recordCount: 42; fields: ["id"; "name"; "email"; "created_at"]; description: "User accounts table"})))

// Test the tool call with arguments
var $result2:=$helper.prompt("Can you give me detailed information about the Users table?")

If (Asserted:C1132($result2.success; JSON Stringify:C1217($result2)))
	
	$foundToolCall:=False:C215
	$foundToolResponse:=False:C215
	
	For each ($message; $helper.messages)
		If ($message.role="assistant") && ($message.tool_calls#Null:C1517) && ($message.tool_calls.length>0)
			$foundToolCall:=True:C214
			
			// Check if the tool call is for our registered function
			$toolCall:=$message.tool_calls.first()
			ASSERT:C1129($toolCall.function.name="get_table_info"; "Tool call should be for get_table_info function")
		End if 
		
		If ($message.role="tool") && ($message.tool_call_id#Null:C1517)
			$foundToolResponse:=True:C214
			ASSERT:C1129(Length:C16($message.content)>0; "Tool response should have content")
		End if 
	End for each 
	
	ASSERT:C1129($foundToolCall; "Should have found a message with tool_calls")
	ASSERT:C1129($foundToolResponse; "Should have found a tool response message")
	
	
	ASSERT:C1129(String:C10($helper.messages.last().text)=String:C10($result2.choice.message.text); "Check result is last message")
	
End if 

// MARK:- Test tool with error handling

// Reset the helper for a new conversation
$helper.reset()

// Define a tool that will throw an error to test error handling
var $errorTool:={type: "function"; \
function: {name: "error_function"; \
description: "A function that throws an error for testing"; \
parameters: {type: "object"; \
properties: {should_fail: {type: "boolean"; description: "Whether the function should fail"}}; \
required: ["should_fail"]; \
additionalProperties: False:C215}}; \
strict: True:C214}

// Register the tool with a handler that throws an assertion error
var $errorHandler:=Formula:C1597(ASSERT:C1129(Not:C34($1.should_fail); "Tool assertion failed - this is an intentional test error"))
$helper.registerTool($errorTool; $errorHandler)

// Test the tool call that should trigger an error
var $result3:=$helper.prompt("Please call the error_function with should_fail set to true to test error handling")

If (Asserted:C1132($result3.success; JSON Stringify:C1217($result3)))
	
	var $foundErrorToolCall:=False:C215
	var $foundErrorToolResponse:=False:C215
	var $errorMessage : cs:C1710.OpenAIMessage
	
	For each ($errorMessage; $helper.messages)
		If ($errorMessage.role="assistant") && ($errorMessage.tool_calls#Null:C1517) && ($errorMessage.tool_calls.length>0)
			$foundErrorToolCall:=True:C214
			
			// Check if the tool call is for our error function
			var $errorToolCall : Object:=$errorMessage.tool_calls.first()
			ASSERT:C1129($errorToolCall.function.name="error_function"; "Tool call should be for error_function")
		End if 
		
		// Look for the tool response that should contain the error message
		If ($errorMessage.role="tool") && ($errorMessage.tool_call_id#Null:C1517)
			$foundErrorToolResponse:=True:C214
			ASSERT:C1129(Length:C16($errorMessage.content)>0; "Tool error response should have content")
			// Check that the error message contains expected error text
			ASSERT:C1129(Position:C15("Error executing function"; $errorMessage.content)>0; "Tool response should contain error execution message")
			ASSERT:C1129(Position:C15("Tool assertion failed"; $errorMessage.content)>0; "Tool response should contain the assertion error message")
		End if 
	End for each 
	
	ASSERT:C1129($foundErrorToolCall; "Should have found a message with error tool_calls")
	ASSERT:C1129($foundErrorToolResponse; "Should have found an error tool response message")
	
	// Verify that the LLM received the error and can acknowledge it
	ASSERT:C1129(String:C10($helper.messages.last().text)=String:C10($result3.choice.message.text); "Check result is last message")
	
End if 

Try(True:C214)  // reset errors

If ((Position:C15("127.0.0.1"; $client.baseURL)>0) && ($client.apiKey="none"))  // mock has no implemented wrong tool call
	return 
End if 


// MARK:- Test autoHandleToolCalls disabled

// Reset the helper for a new conversation
$helper.reset()

// Disable automatic tool call handling
$helper.autoHandleToolCalls:=False:C215

// Define a simple tool for testing
var $noAutoTool:={type: "function"; \
function: {name: "no_auto_function"; \
description: "A function that should not be called automatically"; \
parameters: {type: "object"; \
properties: {test_param: {type: "string"; description: "A test parameter"}}; \
required: ["test_param"]; \
additionalProperties: False:C215}}; \
strict: True:C214}

// Register the tool with a handler
var $noAutoHandler:=Formula:C1597("This should not be called automatically")
$helper.registerTool($noAutoTool; $noAutoHandler)

// Test that tool calls are not handled automatically
var $result4:=$helper.prompt("Please call the no_auto_function with test_param set to 'test_value'")

If (Asserted:C1132($result4.success; JSON Stringify:C1217($result4)))
	
	var $foundToolCallOnly:=False:C215
	var $foundToolResponseOnly:=False:C215
	var $noAutoMessage : cs:C1710.OpenAIMessage
	
	For each ($noAutoMessage; $helper.messages)
		If ($noAutoMessage.role="assistant") && ($noAutoMessage.tool_calls#Null:C1517) && ($noAutoMessage.tool_calls.length>0)
			$foundToolCallOnly:=True:C214
			
			// Check if the tool call is for our registered function
			var $noAutoToolCall : Object:=$noAutoMessage.tool_calls.first()
			ASSERT:C1129($noAutoToolCall.function.name="no_auto_function"; "Tool call should be for no_auto_function")
		End if 
		
		// There should be NO tool response message when autoHandleToolCalls is false
		If ($noAutoMessage.role="tool") && ($noAutoMessage.tool_call_id#Null:C1517)
			$foundToolResponseOnly:=True:C214
		End if 
	End for each 
	
	// We should find the tool call but NOT the tool response (since auto handling is disabled)
	ASSERT:C1129($foundToolCallOnly; "Should have found a message with tool_calls even when auto handling is disabled")
	ASSERT:C1129(Not:C34($foundToolResponseOnly); "Should NOT have found a tool response message when auto handling is disabled")
	
	// The last message should be the assistant's message with tool_calls, not a follow-up response
	var $lastMessage : cs:C1710.OpenAIMessage:=$helper.messages.last()
	ASSERT:C1129($lastMessage.role="assistant"; "Last message should be from assistant")
	ASSERT:C1129($lastMessage.tool_calls#Null:C1517; "Last message should contain tool_calls")
	ASSERT:C1129($lastMessage.tool_calls.length>0; "Last message should have at least one tool call")
	
End if 