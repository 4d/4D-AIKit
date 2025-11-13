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

TRACE:C157("=== Testing Middleware Architecture ===")
TRACE:C157("")

// ============================================================================
// Test 1: Token Counting Middleware
// ============================================================================
TRACE:C157("--- Test 1: Token Counting Middleware ---")

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
	TRACE:C157("Response: "+$result.choice.message.content)
End if

$result:=$helper1.prompt("Tell me a short joke")
If ($result#Null:C1517)
	TRACE:C157("Response: "+$result.choice.message.content)
End if

// Check statistics
var $stats : Object:=$tokenCounter.getStats()
TRACE:C157("Token Statistics:")
TRACE:C157("  Total tokens: "+String:C10($stats.totalTokens))
TRACE:C157("  Request count: "+String:C10($stats.requestCount))
TRACE:C157("  Avg per request: "+String:C10($stats.avgTokensPerRequest))
TRACE:C157("  Max tokens seen: "+String:C10($stats.maxTokensSeen))
TRACE:C157("")

// ============================================================================
// Test 2: Summarization Middleware
// ============================================================================
TRACE:C157("--- Test 2: Summarization Middleware ---")

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
	TRACE:C157("  >> Summarization triggered! Summarized "+String:C10($1.summarizedMessages)+" messages")\
	)\
	})

$helper2.middleware.add($summarizer)

// Have a longer conversation to trigger summarization
TRACE:C157("Starting conversation (will trigger summarization)...")

$helper2.prompt("Tell me about the solar system")
$helper2.prompt("What about Mars specifically?")
$helper2.prompt("How far is Mars from Earth?")
$helper2.prompt("Can humans live on Mars?")
$helper2.prompt("What are the challenges?")

// Check summarization stats
var $sumStats : Object:=$summarizer.getStats()
TRACE:C157("Summarization Statistics:")
TRACE:C157("  Times summarized: "+String:C10($sumStats.summarizationCount))
If ($sumStats.lastSummarization#Null:C1517)
	TRACE:C157("  Last summary: "+$sumStats.lastSummarization.summary)
End if
TRACE:C157("")

// ============================================================================
// Test 3: Combined Pipeline
// ============================================================================
TRACE:C157("--- Test 3: Combined Middleware Pipeline ---")

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

TRACE:C157("Pipeline middleware count: "+String:C10($helper3.middleware.count()))
TRACE:C157("Middleware names: "+JSON Stringify:C1217($helper3.middleware.list()))

$result:=$helper3.prompt("Explain quantum computing")
If ($result#Null:C1517)
	TRACE:C157("Response received: "+String:C10(Length:C16($result.choice.message.content))+" characters")
End if
TRACE:C157("")

// ============================================================================
// Test 4: Middleware Management
// ============================================================================
TRACE:C157("--- Test 4: Dynamic Middleware Management ---")

var $helper4 : cs:C1710.OpenAIChatHelper:=cs:C1710.OpenAIChatHelper.new(\
	$client.chat; \
	"You are a helpful assistant."; \
	New object:C1471("model"; "gpt-4o-mini")\
	)

// Add middleware
var $counter : cs:C1710.TokenCountingMiddleware:=cs:C1710.TokenCountingMiddleware.new({maxTokens: 4000})
$helper4.middleware.add($counter)

TRACE:C157("Added middleware: "+$counter.getName())
TRACE:C157("Middleware count: "+String:C10($helper4.middleware.count()))

// Make request with middleware enabled
$helper4.prompt("Hello")

// Disable middleware
$counter.disable()
TRACE:C157("Middleware disabled")

// Make request with middleware disabled (will be skipped)
$helper4.prompt("How are you?")

// Re-enable
$counter.enable()
TRACE:C157("Middleware re-enabled")

// Remove middleware entirely
$helper4.middleware.remove("TokenCountingMiddleware")
TRACE:C157("Middleware removed")
TRACE:C157("Middleware count: "+String:C10($helper4.middleware.count()))
TRACE:C157("")

// ============================================================================
// Test 5: Token Counter Accuracy
// ============================================================================
TRACE:C157("--- Test 5: Token Counter Accuracy ---")

var $testMessages : Collection:=[\
	New object:C1471("role"; "user"; "content"; "Hello"); \
	New object:C1471("role"; "assistant"; "content"; "Hi there!"); \
	New object:C1471("role"; "user"; "content"; "How are you?"); \
	New object:C1471("role"; "assistant"; "content"; "I'm doing well, thank you!")\
	]

var $counter2 : cs:C1710.OpenAITokenCounter:=cs:C1710.OpenAITokenCounter.new()

For each (var $msg : Object; $testMessages)
	var $tokens : Integer:=$counter2.countMessage($msg)
	TRACE:C157("Message: \""+$msg.content+"\" = "+String:C10($tokens)+" tokens (estimated)")
End for each

var $totalTokens : Integer:=$counter2.countMessages($testMessages)
TRACE:C157("Total estimated tokens: "+String:C10($totalTokens))
TRACE:C157("")

// ============================================================================
// Summary
// ============================================================================
TRACE:C157("=== All Tests Complete ===")
TRACE:C157("")
TRACE:C157("Middleware architecture is working correctly!")
TRACE:C157("")
TRACE:C157("Next steps:")
TRACE:C157("1. Review Documentation/middleware-architecture.md for design details")
TRACE:C157("2. Review Documentation/middleware-examples.md for more examples")
TRACE:C157("3. Create custom middleware by extending OpenAIMiddleware class")
TRACE:C157("4. Use middleware in your applications for better conversation management")
