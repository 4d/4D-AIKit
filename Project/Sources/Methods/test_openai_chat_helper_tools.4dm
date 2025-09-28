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

// Register the tool with its handler
var $toolHandler:=Formula:C1597(JSON Stringify:C1217(OB Keys:C1719(ds:C1482)))
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

// Register the tool with a handler that uses the arguments
$helper.registerTool($getTableInfoTool; Formula:C1597(_table_info_handler_test($1)))

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