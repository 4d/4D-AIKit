//%attributes = {}
// Test unregister tool functionality in OpenAIChatHelper

var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// Create a helper
var $helper:=$client.chat.create("You are a helpful assistant.")

// Define test tools
var $tool1:={type: "function"; \
function: {name: "test_tool_1"; \
description: "Test tool 1"; \
parameters: {}}; \
strict: True:C214}

var $tool2:={type: "function"; \
function: {name: "test_tool_2"; \
description: "Test tool 2"; \
parameters: {}}; \
strict: True:C214}

var $tool3:={name: "test_tool_3"; \
description: "Test tool 2"; \
additionalProperties: False:C215}

var $handler:=Formula:C1597("test response")
$tool3.handler:=$handler

// Register both tools
$helper.registerTool($tool1; $handler)
$helper.registerTool({tool: $tool2; handler: $handler})
$helper.registerTool($tool3)

// Verify tools are registered
ASSERT:C1129($helper.tools.length=3; "Should have 3 tools registered")
ASSERT:C1129($helper.parameters.tools.length=3; "Should have 3 tools in parameters")
ASSERT:C1129($helper._toolHandlers["test_tool_1"]#Null:C1517; "Handler 1 should be registered")
ASSERT:C1129($helper._toolHandlers["test_tool_2"]#Null:C1517; "Handler 2 should be registered")
ASSERT:C1129($helper._toolHandlers["test_tool_3"]#Null:C1517; "Handler 3 should be registered")

// Test unregisterTool - remove one tool
$helper.unregisterTool("test_tool_1")
$helper.unregisterTool("test_tool_3")

// Verify tool1 is removed
ASSERT:C1129($helper.tools.length=1; "Should have 1 tool after unregistering one")
ASSERT:C1129($helper.parameters.tools.length=1; "Should have 1 tool in parameters after unregistering")
ASSERT:C1129($helper._toolHandlers["test_tool_1"]=Null:C1517; "Handler 1 should be unregistered")
ASSERT:C1129($helper._toolHandlers["test_tool_2"]#Null:C1517; "Handler 2 should still be registered")
ASSERT:C1129($helper.tools[0].name="test_tool_2"; "Remaining tool should be test_tool_2")

// Test unregisterTools - remove all tools
$helper.unregisterTools()

// Verify all tools are removed
ASSERT:C1129($helper.tools.length=0; "Should have no tools after unregisterTools")
ASSERT:C1129($helper.parameters.tools.length=0; "Should have no tools in parameters after unregisterTools")
ASSERT:C1129($helper._toolHandlers["test_tool_2"]=Null:C1517; "All handlers should be unregistered")

// Test reset with unregister tools
$helper.registerTool($tool1; $handler)
$helper.registerTool($tool2; $handler)

// Reset tools
$helper.reset()
ASSERT:C1129($helper.tools.length=0; "Tools should be removed after reset()")
ASSERT:C1129($helper.parameters.tools.length=0; "Tools should be removed from parameters after reset()")

// Test edge cases
$helper.unregisterTool("")  // Empty string - should not crash
$helper.unregisterTool("non_existent_tool")  // Non-existent tool - should not crash

// MARK:- Test registerTools function

// Create a fresh helper for registerTools tests
$helper:=$client.chat.create("You are a helpful assistant.")

// Define test tools for registerTools
var $multiTool1:={type: "function"; \
function: {name: "multi_tool_1"; \
description: "Multi tool 1"; \
parameters: {}}; \
strict: True:C214}

var $multiTool2:={type: "function"; \
function: {name: "multi_tool_2"; \
description: "Multi tool 2"; \
parameters: {}}; \
strict: True:C214}

var $multiTool3:={name: "multi_tool_3"; \
description: "Multi tool 3"}

var $multiTool4:={name: "multi_tool_4"; \
description: "Multi tool 4"}

var $multiHandler:=Formula:C1597("multi test response")
$multiTool3.handler:=$multiHandler
$multiTool4.handler:=$multiHandler

// Test registerTools with Object format (including direct tool format)
var $toolsObject:={}
$toolsObject["multi_tool_1"]:={tool: $multiTool1; handler: $multiHandler}  // With "tool" key
$toolsObject["multi_tool_2"]:={tool: $multiTool2; handler: $multiHandler}  // With "tool" key
// Add direct tool format test (NEW CASE)
$toolsObject["multi_tool_3"]:=$multiTool3  // Direct tool (has handler property)

$helper.registerTools($toolsObject)

// Verify tools are registered correctly (should have 3 tools now)
ASSERT:C1129($helper.tools.length=3; "Should have 3 tools registered via object (including direct)")
ASSERT:C1129($helper.parameters.tools.length=3; "Should have 3 tools in parameters via object")
ASSERT:C1129($helper._toolHandlers["multi_tool_1"]#Null:C1517; "Handler 1 should be registered via object")
ASSERT:C1129($helper._toolHandlers["multi_tool_2"]#Null:C1517; "Handler 2 should be registered via object")
ASSERT:C1129($helper._toolHandlers["multi_tool_3"]#Null:C1517; "Direct tool handler should be registered via object")

// Clear tools for next test
$helper.unregisterTools()

// Test registerTools with Collection format (including direct tool format)
var $toolsCollection:=[]
$toolsCollection.push({tool: $multiTool1; handler: $multiHandler})  // With "tool" key
$toolsCollection.push({tool: $multiTool2; handler: $multiHandler})  // With "tool" key
$toolsCollection.push({tool: $multiTool3})  // This has handler in tool.handler
// Add direct tool format test
$multiTool4.handler:=$multiHandler  // Add handler directly to tool
$toolsCollection.push($multiTool4)  // Direct tool (NEW CASE)

$helper.registerTools($toolsCollection)

// Verify tools are registered correctly (should have 4 tools now)
ASSERT:C1129($helper.tools.length=4; "Should have 4 tools registered via collection (including direct)")
ASSERT:C1129($helper.parameters.tools.length=4; "Should have 4 tools in parameters via collection")
ASSERT:C1129($helper._toolHandlers["multi_tool_1"]#Null:C1517; "Handler 1 should be registered via collection")
ASSERT:C1129($helper._toolHandlers["multi_tool_2"]#Null:C1517; "Handler 2 should be registered via collection")
ASSERT:C1129($helper._toolHandlers["multi_tool_3"]#Null:C1517; "Handler 3 should be registered via collection")

// Test registerTools edge cases
$helper.registerTools(Null:C1517)  // Should not crash with null
ASSERT:C1129($helper.tools.length=4; "Tools should remain unchanged after registerTools(null)")

// Test registerTools with empty object
$helper.registerTools({})  // Should not crash with empty object
ASSERT:C1129($helper.tools.length=4; "Tools should remain unchanged after registerTools({})")

// Test registerTools with empty collection
$helper.registerTools([])  // Should not crash with empty collection
ASSERT:C1129($helper.tools.length=4; "Tools should remain unchanged after registerTools([])")

// Test registerTools with invalid parameter (should trigger assertion)
var $invalidParam:="invalid"
// Note: This would trigger an ASSERT, so we skip it in tests
// $helper.registerTools($invalidParam)

// Test registerTools with object containing incomplete tool info
var $incompleteObject:={}
$incompleteObject["incomplete_tool"]:={tool: $multiTool1}  // Missing handler
// $incompleteObject["another_incomplete"]:={handler: $multiHandler}  // Missing tool, will be ok, with name another_incomplete, maybe filter if no description?

$helper.registerTools($incompleteObject)
// Should remain unchanged because entries are incomplete
ASSERT:C1129($helper.tools.length=4; "Tools should remain unchanged with incomplete object entries")

// Test registerTools with collection containing incomplete tool info
var $incompleteCollection:=[]
$incompleteCollection.push({tool: {type: "function"; function: {name: "multi_tool_misssinghandler"; \
description: "Multi tool "; parameters: {}}; strict: True:C214}})  // Missing handler
$incompleteCollection.push({handler: $multiHandler})  // Missing tool

$helper.registerTools($incompleteCollection)
// Should remain unchanged because entries are incomplete
ASSERT:C1129($helper.tools.length=4; "Tools should remain unchanged with incomplete collection entries")

// Test direct tool without handler (should be ignored or fail gracefully)
var $directToolNoHandler:={type: "function"; \
function: {name: "no_handler_tool"; \
description: "Tool without handler"; \
parameters: {}; \
required: []; \
additionalProperties: False:C215}; \
strict: True:C214}

var $noHandlerObject:={}
$noHandlerObject["no_handler_tool"]:=$directToolNoHandler

$helper.unregisterTools()
$helper.registerTools($noHandlerObject)

// Should not register the tool without handler
ASSERT:C1129($helper.tools.length=0; "Should not register direct tool without handler")

// Test mixed registration - registerTools after individual registerTool
$helper.unregisterTools()
$helper.registerTool($tool1; $handler)  // Register one tool individually

var $mixedObject:={}
$mixedObject["multi_tool_1"]:={tool: $multiTool1; handler: $multiHandler}
$helper.registerTools($mixedObject)

ASSERT:C1129($helper.tools.length=2; "Should have 2 tools after mixed registration")
ASSERT:C1129($helper._toolHandlers["test_tool_1"]#Null:C1517; "Individual tool should remain registered")
ASSERT:C1129($helper._toolHandlers["multi_tool_1"]#Null:C1517; "Batch registered tool should be registered")

// Test tool replacement via registerTools
var $replacementTool:={type: "function"; \
function: {name: "multi_tool_1"; \
description: "Replaced multi tool 1"; \
parameters: {}; \
required: []; \
additionalProperties: False:C215}; \
strict: True:C214}

var $replacementHandler:=Formula:C1597("replacement response")
var $replaceObject:={}
$replaceObject["multi_tool_1"]:={tool: $replacementTool; handler: $replacementHandler}

$helper.registerTools($replaceObject)

// Should still have 2 tools, but the multi_tool_1 should be replaced
ASSERT:C1129($helper.tools.length=2; "Should still have 2 tools after replacement")
ASSERT:C1129($helper._toolHandlers["multi_tool_1"]#Null:C1517; "Replaced tool handler should exist")

// Verify the tool was actually replaced by checking description
var $foundReplacedTool:=False:C215
var $testTool:={}
For each ($testTool; $helper.tools)
	If ($testTool.name="multi_tool_1")
		If ($testTool.description="Replaced multi tool 1")
			$foundReplacedTool:=True:C214
		End if 
		break
	End if 
End for each 
ASSERT:C1129($foundReplacedTool; "Tool should be replaced with new description")
