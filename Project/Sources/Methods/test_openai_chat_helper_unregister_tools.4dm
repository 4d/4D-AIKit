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
parameters: {}; \
required: []; \
additionalProperties: False:C215}; \
strict: True:C214}

var $tool2:={type: "function"; \
function: {name: "test_tool_2"; \
description: "Test tool 2"; \
parameters: {}; \
required: []; \
additionalProperties: False:C215}; \
strict: True:C214}

var $handler:=Formula:C1597("test response")

// Register both tools
$helper.registerTool($tool1; $handler)
$helper.registerTool($tool2; $handler)

// Verify tools are registered
ASSERT:C1129($helper.tools.length=2; "Should have 2 tools registered")
ASSERT:C1129($helper.parameters.tools.length=2; "Should have 2 tools in parameters")
ASSERT:C1129($helper.toolHandlers["test_tool_1"]#Null:C1517; "Handler 1 should be registered")
ASSERT:C1129($helper.toolHandlers["test_tool_2"]#Null:C1517; "Handler 2 should be registered")

// Test unregisterTool - remove one tool
$helper.unregisterTool("test_tool_1")

// Verify tool1 is removed
ASSERT:C1129($helper.tools.length=1; "Should have 1 tool after unregistering one")
ASSERT:C1129($helper.parameters.tools.length=1; "Should have 1 tool in parameters after unregistering")
ASSERT:C1129($helper.toolHandlers["test_tool_1"]=Null:C1517; "Handler 1 should be unregistered")
ASSERT:C1129($helper.toolHandlers["test_tool_2"]#Null:C1517; "Handler 2 should still be registered")
ASSERT:C1129($helper.tools[0].function.name="test_tool_2"; "Remaining tool should be test_tool_2")

// Test unregisterTools - remove all tools
$helper.unregisterTools()

// Verify all tools are removed
ASSERT:C1129($helper.tools.length=0; "Should have no tools after unregisterTools")
ASSERT:C1129($helper.parameters.tools.length=0; "Should have no tools in parameters after unregisterTools")
ASSERT:C1129($helper.toolHandlers["test_tool_2"]=Null:C1517; "All handlers should be unregistered")

// Test reset with unregister tools
$helper.registerTool($tool1; $handler)
$helper.registerTool($tool2; $handler)

// Reset without unregistering tools
$helper.reset()
ASSERT:C1129($helper.tools.length=2; "Tools should remain after reset() without unregister")

// Reset with unregistering tools
$helper.reset(True:C214)
ASSERT:C1129($helper.tools.length=0; "Tools should be removed after reset(True)")
ASSERT:C1129($helper.parameters.tools.length=0; "Tools should be removed from parameters after reset(True)")

// Test edge cases
$helper.unregisterTool("")  // Empty string - should not crash
$helper.unregisterTool("non_existent_tool")  // Non-existent tool - should not crash

// Test unregisterTool with Null parameter
Try
	$helper.unregisterTool(Null:C1517)
	ASSERT:C1129(True:C214; "unregisterTool(Null) should not crash")
Catch
	ASSERT:C1129(False:C215; "unregisterTool(Null) should not throw error")
End try