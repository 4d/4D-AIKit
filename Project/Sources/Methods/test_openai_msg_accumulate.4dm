//%attributes = {}

// MARK:- Test Delta Accumulation in OpenAI Messages

// Test 1: Basic text accumulation
var $originalMessage : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "assistant"; content: "Hello"})
var $deltaMessage : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({content: " world"})

$originalMessage._accumulateDelta($deltaMessage)
ASSERT:C1129($originalMessage.content="Hello world"; "Text accumulation should concatenate strings, got: '"+String:C10($originalMessage.content)+"'")

// Test 2: Tool calls accumulation with index-based updates
var $message : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "assistant"; tool_calls: []})
var $delta1 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({tool_calls: [{index: 0; id: "call_1"; type: "function"; function: {name: "get_weather"}}]})
var $delta2 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({tool_calls: [{index: 0; function: {arguments: "{\"location\": \"Paris\"}"}}]})

$message._accumulateDelta($delta1)
$message._accumulateDelta($delta2)

ASSERT:C1129($message.tool_calls.length=1; "Should have one tool call, got: "+String:C10($message.tool_calls.length))
ASSERT:C1129($message.tool_calls[0].id="call_1"; "Tool call ID should be preserved, got: '"+String:C10($message.tool_calls[0].id)+"'")
ASSERT:C1129($message.tool_calls[0].function.name="get_weather"; "Function name should be preserved, got: '"+String:C10($message.tool_calls[0].function.name)+"'")
ASSERT:C1129($message.tool_calls[0].function.arguments="{\"location\": \"Paris\"}"; "Function arguments should be accumulated, got: '"+String:C10($message.tool_calls[0].function.arguments)+"'")

// Test 3: Multiple tool calls with different indices
var $messageMulti : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "assistant"; tool_calls: []})
var $deltaA : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({tool_calls: [{index: 0; id: "call_1"; type: "function"; function: {name: "func1"}}]})
var $deltaB : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({tool_calls: [{index: 1; id: "call_2"; type: "function"; function: {name: "func2"}}]})
var $deltaC : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({tool_calls: [{index: 0; function: {arguments: "{\"a\": 1}"}}]})

$messageMulti._accumulateDelta($deltaA)
$messageMulti._accumulateDelta($deltaB)
$messageMulti._accumulateDelta($deltaC)

ASSERT:C1129($messageMulti.tool_calls.length=2; "Should have two tool calls, got: "+String:C10($messageMulti.tool_calls.length))
ASSERT:C1129($messageMulti.tool_calls[0].id="call_1"; "First tool call ID correct, got: '"+String:C10($messageMulti.tool_calls[0].id)+"'")
ASSERT:C1129($messageMulti.tool_calls[1].id="call_2"; "Second tool call ID correct, got: '"+String:C10($messageMulti.tool_calls[1].id)+"'")
ASSERT:C1129($messageMulti.tool_calls[0].function.arguments="{\"a\": 1}"; "First tool call arguments accumulated, got: '"+String:C10($messageMulti.tool_calls[0].function.arguments)+"'")

// Test 4: Content collection accumulation (for vision/multimodal messages)
var $visionMessage : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: [{type: "text"; text: "What is"}]})
var $visionDelta : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({content: [{index: 0; text: " in this image?"}]})

$visionMessage._accumulateDelta($visionDelta)
ASSERT:C1129($visionMessage.content[0].text="What is in this image?"; "Vision content text should be accumulated, got: '"+String:C10($visionMessage.content[0].text)+"'")

// Test 5: Numeric accumulation
var $numericMessage : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "assistant"; score: 85})
var $numericDelta : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({score: 15})

$numericMessage._accumulateDelta($numericDelta)
ASSERT:C1129($numericMessage["score"]=100; "Numeric values should be added together, got: "+String:C10($numericMessage["score"]))

// Test 6: Object merging
var $objMessage : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "assistant"; metadata: {source: "api"; version: 1}})
var $objDelta : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({metadata: {timestamp: "2023-01-01"; version: 2}})

$objMessage._accumulateDelta($objDelta)
ASSERT:C1129($objMessage["metadata"].source="api"; "Original object properties should be preserved, got: '"+String:C10($objMessage["metadata"].source)+"'")
ASSERT:C1129($objMessage["metadata"].version=3; "Numeric object properties should be added, got: "+String:C10($objMessage["metadata"].version))  // 1 + 2 = 3
ASSERT:C1129($objMessage["metadata"].timestamp="2023-01-01"; "New object properties should be added, got: '"+String:C10($objMessage["metadata"].timestamp)+"'")

// Test 7: Null handling
var $nullMessage : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "assistant"; content: Null:C1517})
var $nullDelta : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({content: "Hello"})

$nullMessage._accumulateDelta($nullDelta)
ASSERT:C1129($nullMessage.content="Hello"; "Null values should be replaced by delta values, got: '"+String:C10($nullMessage.content)+"'")

// Test 8: Empty collections handling
var $emptyMessage : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "assistant"; tool_calls: []})
var $emptyDelta : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({tool_calls: [{index: 0; id: "call_1"}]})

$emptyMessage._accumulateDelta($emptyDelta)
ASSERT:C1129($emptyMessage.tool_calls.length=1; "Empty collections should accept new entries, got: "+String:C10($emptyMessage.tool_calls.length))
ASSERT:C1129($emptyMessage.tool_calls[0].id="call_1"; "New entries should be properly added, got: '"+String:C10($emptyMessage.tool_calls[0].id)+"'")

// Test 9: Index and type property handling (special case)
var $specialMessage : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "assistant"; index: 0; type: "old"})
var $specialDelta : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({index: 1; type: "new"})

$specialMessage._accumulateDelta($specialDelta)
ASSERT:C1129($specialMessage["index"]=1; "Index property should be replaced, not added, got: "+String:C10($specialMessage["index"]))
ASSERT:C1129($specialMessage["type"]="new"; "Type property should be replaced, not concatenated, got: '"+String:C10($specialMessage["type"])+"'")

// Test 10: Complex streaming scenario simulation
var $streamMessage : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "assistant"; content: ""})

// Simulate streaming chunks
var $chunk1 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({content: "I'll help"})
var $chunk2 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({content: " you with"})
var $chunk3 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({content: " that question."})

$streamMessage._accumulateDelta($chunk1)
$streamMessage._accumulateDelta($chunk2)
$streamMessage._accumulateDelta($chunk3)

ASSERT:C1129($streamMessage.content="I'll help you with that question."; "Streaming text should accumulate correctly, got: '"+String:C10($streamMessage.content)+"'")

// Test 11: Tool call arguments streaming
var $toolMessage : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "assistant"; tool_calls: []})
var $toolInit : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({tool_calls: [{index: 0; id: "call_1"; type: "function"; function: {name: "calculate"; arguments: ""}}]})
var $toolArg1 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({tool_calls: [{index: 0; function: {arguments: "{\"operation\": \"add\","}}]})
var $toolArg2 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({tool_calls: [{index: 0; function: {arguments: " \"numbers\": [1, 2, 3]}"}}]})

$toolMessage._accumulateDelta($toolInit)
$toolMessage._accumulateDelta($toolArg1)
$toolMessage._accumulateDelta($toolArg2)

var $expectedArgs : Text:="{\"operation\": \"add\", \"numbers\": [1, 2, 3]}"
ASSERT:C1129($toolMessage.tool_calls[0].function.arguments=$expectedArgs; "Tool call arguments should stream correctly, got: '"+String:C10($toolMessage.tool_calls[0].function.arguments)+"'")

// Test 12: Collection expansion beyond initial size
var $expandMessage : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "assistant"; tool_calls: []})
var $expandDelta : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({tool_calls: [{index: 5; id: "call_6"}]})  // Large index

$expandMessage._accumulateDelta($expandDelta)
If (Asserted:C1132($expandMessage.tool_calls.length=6; "Collection should expand to accommodate large indices, got: "+String:C10($expandMessage.tool_calls.length)))
	ASSERT:C1129($expandMessage.tool_calls[5].id="call_6"; "Item should be placed at correct index, got: '"+String:C10($expandMessage.tool_calls[5].id)+"'")
End if 

// Verify null entries were created for intermediate indices
var $i : Integer
For ($i; 0; 4)
	ASSERT:C1129($expandMessage.tool_calls[$i]=Null:C1517; "Intermediate indices should be null: index "+String:C10($i)+", got: "+String:C10($expandMessage.tool_calls[$i]))
End for 

// MARK:- Test _accumulateDeltaBetween method directly
var $acc : Object:={text: "Hello"; count: 5}
var $delta : Object:={text: " World"; count: 3; newProp: "test"}
var $result : Object:=cs:C1710.OpenAIMessage.new()._accumulateDeltaBetween($acc; $delta)

ASSERT:C1129($result.text="Hello World"; "Direct accumulation should concatenate text, got: '"+String:C10($result.text)+"'")
ASSERT:C1129($result.count=8; "Direct accumulation should add numbers, got: "+String:C10($result.count))
ASSERT:C1129($result.newProp="test"; "Direct accumulation should add new properties, got: '"+String:C10($result.newProp)+"'")

// Test with null accumulator
var $nullResult : Object:=cs:C1710.OpenAIMessage.new()._accumulateDeltaBetween(Null:C1517; $delta)
ASSERT:C1129($nullResult.text=" World"; "Null accumulator should be replaced by delta, got: '"+String:C10($nullResult.text)+"'")
ASSERT:C1129($nullResult.count=3; "Null accumulator should be replaced by delta, got: "+String:C10($nullResult.count))
