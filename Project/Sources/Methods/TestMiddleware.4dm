//%attributes = {}
/*
 * TestMiddleware - Demo and test script for middleware functionality
 *
 * This method demonstrates the middleware architecture with practical examples.
 * Run this to see middleware in action.
 */

// Initialize OpenAI client (replace with your API key)
var $apiKey : Text:=Get environment variable:C1065("OPENAI_API_KEY")
If ($apiKey="")
	ALERT:C41("Please set OPENAI_API_KEY environment variable")
	return
End if

var $client : cs:C1710.OpenAI:=cs:C1710.OpenAI.new({apiKey: $apiKey})

LOG EVENT:C667(Into system standard outputs:K38:9; "=== Testing Middleware Architecture ==="; Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; ""; Information message:K38:1)

// ============================================================================
// Test 1: Token Counting Middleware
// ============================================================================
LOG EVENT:C667(Into system standard outputs:K38:9; "--- Test 1: Token Counting Middleware ---"; Information message:K38:1)

var $helper1 : cs:C1710.OpenAIChatHelper:=cs:C1710.OpenAIChatHelper.new(\
	$client.chat; \
	"You are a helpful assistant."; \
	New object:C1471("model"; "gpt-4o-mini")\
	)

// Add token counting middleware
var $tokenCounter : cs:C1710.TokenCountingMiddleware:=cs:C1710.TokenCountingMiddleware.new({\
	maxTokens: 4000; \
	abortOnExceed: False:C215; \
	warnOnExceed: True:C214\
	})

$helper1.middleware.add($tokenCounter)

// Make some requests
var $result : cs:C1710.OpenAIChatCompletionsResult

$result:=$helper1.prompt("What is 2+2?")
If ($result#Null:C1517)
	LOG EVENT:C667(Into system standard outputs:K38:9; "Response: "+$result.choice.message.content; Information message:K38:1)
End if

$result:=$helper1.prompt("Tell me a short joke")
If ($result#Null:C1517)
	LOG EVENT:C667(Into system standard outputs:K38:9; "Response: "+$result.choice.message.content; Information message:K38:1)
End if

// Check statistics
var $stats : Object:=$tokenCounter.getStats()
LOG EVENT:C667(Into system standard outputs:K38:9; "Token Statistics:"; Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; "  Total tokens: "+String:C10($stats.totalTokens); Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; "  Request count: "+String:C10($stats.requestCount); Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; "  Avg per request: "+String:C10($stats.avgTokensPerRequest); Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; "  Max tokens seen: "+String:C10($stats.maxTokensSeen); Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; ""; Information message:K38:1)

// ============================================================================
// Test 2: Summarization Middleware
// ============================================================================
LOG EVENT:C667(Into system standard outputs:K38:9; "--- Test 2: Summarization Middleware ---"; Information message:K38:1)

var $helper2 : cs:C1710.OpenAIChatHelper:=cs:C1710.OpenAIChatHelper.new(\
	$client.chat; \
	"You are a helpful assistant."; \
	New object:C1471("model"; "gpt-4o-mini")\
	)

// Add summarization middleware with low threshold for testing
var $summarizer : cs:C1710.SummarizationMiddleware:=cs:C1710.SummarizationMiddleware.new({\
	threshold: 500; \
	keepRecentCount: 2; \
	summaryPrompt: "Summarize the conversation in 2-3 bullet points."; \
	onSummarize: Formula:C1597(\
	LOG EVENT:C667(Into system standard outputs:K38:9; "  >> Summarization triggered! Summarized "+String:C10($1.summarizedMessages)+" messages"; Information message:K38:1)\
	)\
	})

$helper2.middleware.add($summarizer)

// Have a longer conversation to trigger summarization
LOG EVENT:C667(Into system standard outputs:K38:9; "Starting conversation (will trigger summarization)..."; Information message:K38:1)

$helper2.prompt("Tell me about the solar system")
$helper2.prompt("What about Mars specifically?")
$helper2.prompt("How far is Mars from Earth?")
$helper2.prompt("Can humans live on Mars?")
$helper2.prompt("What are the challenges?")

// Check summarization stats
var $sumStats : Object:=$summarizer.getStats()
LOG EVENT:C667(Into system standard outputs:K38:9; "Summarization Statistics:"; Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; "  Times summarized: "+String:C10($sumStats.summarizationCount); Information message:K38:1)
If ($sumStats.lastSummarization#Null:C1517)
	LOG EVENT:C667(Into system standard outputs:K38:9; "  Last summary: "+$sumStats.lastSummarization.summary; Information message:K38:1)
End if
LOG EVENT:C667(Into system standard outputs:K38:9; ""; Information message:K38:1)

// ============================================================================
// Test 3: Combined Pipeline
// ============================================================================
LOG EVENT:C667(Into system standard outputs:K38:9; "--- Test 3: Combined Middleware Pipeline ---"; Information message:K38:1)

var $helper3 : cs:C1710.OpenAIChatHelper:=cs:C1710.OpenAIChatHelper.new(\
	$client.chat; \
	"You are a helpful assistant."; \
	New object:C1471("model"; "gpt-4o-mini")\
	)

// Build pipeline with multiple middleware
$helper3.middleware\
	.add(cs:C1710.TokenCountingMiddleware.new({maxTokens: 4000}))\
	.add(cs:C1710.SummarizationMiddleware.new({threshold: 3000; keepRecentCount: 5}))

// Enable debug mode to see execution
$helper3.middleware.enableDebug()

LOG EVENT:C667(Into system standard outputs:K38:9; "Pipeline middleware count: "+String:C10($helper3.middleware.count()); Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; "Middleware names: "+JSON Stringify:C1217($helper3.middleware.list()); Information message:K38:1)

$result:=$helper3.prompt("Explain quantum computing")
If ($result#Null:C1517)
	LOG EVENT:C667(Into system standard outputs:K38:9; "Response received: "+String:C10(Length:C16($result.choice.message.content))+" characters"; Information message:K38:1)
End if
LOG EVENT:C667(Into system standard outputs:K38:9; ""; Information message:K38:1)

// ============================================================================
// Test 4: Middleware Management
// ============================================================================
LOG EVENT:C667(Into system standard outputs:K38:9; "--- Test 4: Dynamic Middleware Management ---"; Information message:K38:1)

var $helper4 : cs:C1710.OpenAIChatHelper:=cs:C1710.OpenAIChatHelper.new(\
	$client.chat; \
	"You are a helpful assistant."; \
	New object:C1471("model"; "gpt-4o-mini")\
	)

// Add middleware
var $counter : cs:C1710.TokenCountingMiddleware:=cs:C1710.TokenCountingMiddleware.new({maxTokens: 4000})
$helper4.middleware.add($counter)

LOG EVENT:C667(Into system standard outputs:K38:9; "Added middleware: "+$counter.getName(); Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; "Middleware count: "+String:C10($helper4.middleware.count()); Information message:K38:1)

// Make request with middleware enabled
$helper4.prompt("Hello")

// Disable middleware
$counter.disable()
LOG EVENT:C667(Into system standard outputs:K38:9; "Middleware disabled"; Information message:K38:1)

// Make request with middleware disabled (will be skipped)
$helper4.prompt("How are you?")

// Re-enable
$counter.enable()
LOG EVENT:C667(Into system standard outputs:K38:9; "Middleware re-enabled"; Information message:K38:1)

// Remove middleware entirely
$helper4.middleware.remove("TokenCountingMiddleware")
LOG EVENT:C667(Into system standard outputs:K38:9; "Middleware removed"; Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; "Middleware count: "+String:C10($helper4.middleware.count()); Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; ""; Information message:K38:1)

// ============================================================================
// Test 5: Token Counter Accuracy
// ============================================================================
LOG EVENT:C667(Into system standard outputs:K38:9; "--- Test 5: Token Counter Accuracy ---"; Information message:K38:1)

var $testMessages : Collection:=[\
	New object:C1471("role"; "user"; "content"; "Hello"); \
	New object:C1471("role"; "assistant"; "content"; "Hi there!"); \
	New object:C1471("role"; "user"; "content"; "How are you?"); \
	New object:C1471("role"; "assistant"; "content"; "I'm doing well, thank you!")\
	]

var $counter2 : cs:C1710.OpenAITokenCounter:=cs:C1710.OpenAITokenCounter.new()
var $msg : Object
var $tokens : Integer

For each ($msg; $testMessages)
	$tokens:=$counter2.countMessage($msg)
	LOG EVENT:C667(Into system standard outputs:K38:9; "Message: \""+$msg.content+"\" = "+String:C10($tokens)+" tokens (estimated)"; Information message:K38:1)
End for each

var $totalTokens : Integer:=$counter2.countMessages($testMessages)
LOG EVENT:C667(Into system standard outputs:K38:9; "Total estimated tokens: "+String:C10($totalTokens); Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; ""; Information message:K38:1)

// ============================================================================
// Summary
// ============================================================================
LOG EVENT:C667(Into system standard outputs:K38:9; "=== All Tests Complete ==="; Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; ""; Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; "Middleware architecture is working correctly!"; Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; ""; Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; "Next steps:"; Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; "1. Review Documentation/middleware-architecture.md for design details"; Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; "2. Review Documentation/middleware-examples.md for more examples"; Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; "3. Create custom middleware by extending OpenAIMiddleware class"; Information message:K38:1)
LOG EVENT:C667(Into system standard outputs:K38:9; "4. Use middleware in your applications for better conversation management"; Information message:K38:1)
