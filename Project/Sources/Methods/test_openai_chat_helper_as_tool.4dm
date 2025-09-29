//%attributes = {}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

var $modelName:=cs:C1710._TestModels.new($client).chats

If ((Position:C15("127.0.0.1"; $client.baseURL)>0) && ($client.apiKey="none"))  // mock not implemented
	KILL WORKER:C1390(Current method name:C684)
	return 
End if 
// MARK:- automatic tools response test with stream


cs:C1710._TestSignal.me.init()

var $toolsHelper:=$client.chat.create("You are a helpful assistant that can access database information."; {stream: True:C214; model: $modelName; onData: Formula:C1597(cs:C1710._TestSignal.me.pushChunk($1)); onTerminate: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})
$toolsHelper.autoHandleToolCalls:=True:C214

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
$toolsHelper.registerTool($getDatabaseTablesTool; $toolHandler)

// Test async tool call
CALL WORKER:C1389(Current method name:C684; Formula:C1597($toolsHelper.prompt("What tables are available in the database?")))

cs:C1710._TestSignal.me.wait(15*1000)  // Longer timeout for tool calls

var $toolResult : cs:C1710.OpenAIChatCompletionsResult:=cs:C1710._TestSignal.me.result
var $streamResults : Collection:=cs:C1710._TestSignal.me.chunks

If (Asserted:C1132(Bool:C1537($toolResult.success); "Cannot complete chat with tools : "+JSON Stringify:C1217($toolResult)))
	
	// Check that messages contain tool calls and responses
	var $foundToolCall : Boolean:=False:C215
	var $foundToolResponse : Boolean:=False:C215
	var $toolMessage : cs:C1710.OpenAIMessage
	For each ($toolMessage; $toolsHelper.messages)
		If ($toolMessage.role="assistant") && ($toolMessage.tool_calls#Null:C1517) && ($toolMessage.tool_calls.length>0)
			$foundToolCall:=True:C214
			
			// Check if the tool call is for our registered function
			var $toolCall : Object:=$toolMessage.tool_calls.first()
			ASSERT:C1129($toolCall.function.name="get_database_tables"; "Tool call should be for get_database_tables function")
		End if 
		
		If ($toolMessage.role="tool") && ($toolMessage.tool_call_id#Null:C1517)
			$foundToolResponse:=True:C214
			ASSERT:C1129(Length:C16($toolMessage.content)>0; "Tool response should have content")
		End if 
	End for each 
	
	ASSERT:C1129($foundToolCall; "Should have found a message with tool_calls in async test")
	ASSERT:C1129($foundToolResponse; "Should have found a tool response message in async test")
	
	If (Asserted:C1132($toolResult.choice#Null:C1517))
		//ASSERT(String($toolResult.choice.finish_reason)="stop"; "finish reason must be stop "+String($toolResult.choice.finish_reason))
	End if 
	
End if 

// MARK:- automatic tools response test with parameters and stream

cs:C1710._TestSignal.me.init()

var $toolsHelperWithParams:=$client.chat.create("You are a helpful assistant that can access database information."; {stream: True:C214; model: $modelName; onData: Formula:C1597(cs:C1710._TestSignal.me.pushChunk($1)); onTerminate: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})
$toolsHelperWithParams.autoHandleToolCalls:=True:C214

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
var $toolHandlerWithParams:=Formula:C1597(JSON Stringify:C1217({tableName: $1.tableName; columns: ["id"; "name"; "email"; "created_at"]; fieldCount: 4; recordCount: 42; fields: ["id"; "name"; "email"; "created_at"]; description: "User accounts table"}))
$toolsHelperWithParams.registerTool($getTableInfoTool; $toolHandlerWithParams)

/*$getTableInfoTool2:=OB Copy($getTableInfoTool)
$getTableInfoTool2.function.name+="2"
$getTableInfoTool3:=OB Copy($getTableInfoTool)
$getTableInfoTool2.function.name+="3"
$getTableInfoTool4:=OB Copy($getTableInfoTool)
$getTableInfoTool2.function.name+="4"
$getTableInfoTool5:=OB Copy($getTableInfoTool)
$getTableInfoTool2.function.name+="5"

$toolsHelperWithParams.registerTool($getTableInfoTool2; $toolHandlerWithParams)
$toolsHelperWithParams.registerTool($getTableInfoTool3; $toolHandlerWithParams)
$toolsHelperWithParams.registerTool($getTableInfoTool4; $toolHandlerWithParams)
$toolsHelperWithParams.registerTool($getTableInfoTool5; $toolHandlerWithParams)*/


// Test async tool call with parameters
CALL WORKER:C1389(Current method name:C684; Formula:C1597($toolsHelperWithParams.prompt("Can you give me detailed information about the Users table?")))

cs:C1710._TestSignal.me.wait(15*1000)  // Longer timeout for tool calls

var $toolResultWithParams : cs:C1710.OpenAIChatCompletionsResult:=cs:C1710._TestSignal.me.result
var $streamResultsWithParams : Collection:=cs:C1710._TestSignal.me.chunks

If (Asserted:C1132(Bool:C1537($toolResultWithParams.success); "Cannot complete chat with parametric tools : "+JSON Stringify:C1217($toolResultWithParams)))
	
	// Check that messages contain tool calls and responses
	var $foundToolCallWithParams : Boolean:=False:C215
	var $foundToolResponseWithParams : Boolean:=False:C215
	var $toolMessageWithParams : cs:C1710.OpenAIMessage
	For each ($toolMessageWithParams; $toolsHelperWithParams.messages)
		If ($toolMessageWithParams.role="assistant") && ($toolMessageWithParams.tool_calls#Null:C1517) && ($toolMessageWithParams.tool_calls.length>0)
			$foundToolCallWithParams:=True:C214
			
			// Check if the tool call is for our registered function and has arguments
			var $toolCallWithParams : Object:=$toolMessageWithParams.tool_calls.first()
			ASSERT:C1129($toolCallWithParams.function.name="get_table_info"; "Tool call should be for get_table_info function")
			
			// Verify that arguments were passed correctly
			var $arguments : Object:=JSON Parse:C1218($toolCallWithParams.function.arguments)
			ASSERT:C1129($arguments.tableName#Null:C1517; "Tool call should have tableName argument")
			ASSERT:C1129(Length:C16($arguments.tableName)>0; "tableName argument should not be empty")
		End if 
		
		If ($toolMessageWithParams.role="tool") && ($toolMessageWithParams.tool_call_id#Null:C1517)
			$foundToolResponseWithParams:=True:C214
			ASSERT:C1129(Length:C16($toolMessageWithParams.content)>0; "Tool response should have content")
			
			// Verify that the response contains expected table info structure
			ASSERT:C1129(Length:C16(String:C10($toolMessageWithParams.content))>0; "No content returned after tool call")
			
		End if 
	End for each 
	
	ASSERT:C1129($foundToolCallWithParams; "Should have found a message with tool_calls in async parametric test")
	ASSERT:C1129($foundToolResponseWithParams; "Should have found a tool response message in async parametric test")
	
	If (Asserted:C1132($toolResultWithParams.choice#Null:C1517))
		//ASSERT(String($toolResultWithParams.choice.finish_reason)="stop"; "finish reason must be stop "+String($toolResultWithParams.choice.finish_reason))
	End if 
	
End if 

KILL WORKER:C1390(Current method name:C684)