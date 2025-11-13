# Middleware Architecture for 4D AIKit

> **New in version 2.0**: Composable middleware pipeline for advanced conversation management

## Overview

The middleware architecture provides a flexible, composable way to manage LLM conversations. It enables features like automatic summarization, token counting, logging, and custom processing through a clean pipeline pattern inspired by LangChain.

## Quick Start

```4d
// Create helper
$helper:=cs.OpenAIChatHelper.new($client.chat; "You are helpful"; New object)

// Add middleware
$helper.middleware\
    .add(cs.TokenCountingMiddleware.new({maxTokens: 4000}))\
    .add(cs.SummarizationMiddleware.new({threshold: 3000; keepRecentCount: 5}))

// Use normally - middleware runs automatically
$result:=$helper.prompt("Your question here")
```

## Why Middleware?

Large language models have strict token limits. Long conversations must be managed carefully:

- **Naive trimming** (dropping old messages) loses important context
- **Manual management** is error-prone and repetitive
- **Summarization** preserves information while staying within limits

Middleware provides:

✅ **Composability** - Stack multiple processors
✅ **Separation of Concerns** - Each middleware has one job
✅ **Reusability** - Share middleware across projects
✅ **Extensibility** - Create custom middleware easily
✅ **Transparency** - See exactly what's happening with debug mode

## Built-in Middleware

### TokenCountingMiddleware

Tracks and enforces token limits:

```4d
$tokenCounter:=cs.TokenCountingMiddleware.new({\
    maxTokens: 4000; \
    abortOnExceed: False; \
    warnOnExceed: True\
})

$helper.middleware.add($tokenCounter)

// Check stats
$stats:=$tokenCounter.getStats()
// {totalTokens, requestCount, avgTokensPerRequest, maxTokensSeen}
```

**Features:**
- Estimates token count using character/word-based heuristics
- Optionally abort requests exceeding limit
- Track usage statistics
- Custom counting formulas

### SummarizationMiddleware

Automatically compresses old conversation history:

```4d
$summarizer:=cs.SummarizationMiddleware.new({\
    threshold: 3000; \
    keepRecentCount: 5; \
    summaryPrompt: "Summarize key points as bullets"\
})

$helper.middleware.add($summarizer)
```

**How it works:**
1. Monitors token count (from TokenCountingMiddleware or estimates)
2. When threshold exceeded, triggers summarization
3. Keeps recent N messages verbatim (for immediate context)
4. Summarizes older messages into single assistant message
5. Replaces old messages with summary

**Result:** "Sliding window + summary" pattern - preserves both recent context and historical information.

## Pipeline Execution

Middleware executes in two phases:

### Before Request (processBeforeRequest)

Runs before API call:

```
User Message → [Before Pipeline] → API Call
                ↓
            Token Counting → Summarization → Validation → ...
```

Each middleware can:
- Inspect/modify messages
- Inspect/modify parameters
- Share data via metadata
- Abort request by returning Null

### After Response (processAfterResponse)

Runs after API call:

```
API Response → [After Pipeline] → Add Message
                ↓
            Process Response → Trim → Log → ...
```

Each middleware can:
- Inspect/modify new message
- Update statistics
- Trigger side effects
- Abort message addition by returning Null

## Creating Custom Middleware

Extend `OpenAIMiddleware`:

```4d
Class extends cs.OpenAIMiddleware

Class constructor($config : Object)
    Super($config)
    This._name:="MyMiddleware"

Function processBeforeRequest($context : Object)->$result : Object
    // $context = {helper, messages, parameters, metadata}

    // Your logic here

    return $context  // or Null to abort

Function processAfterResponse($context : Object)->$result : Object
    // $context = {helper, messages, result, newMessage, metadata}

    // Your logic here

    return $context  // or Null to abort
```

**Example - Logging Middleware:**

```4d
Class extends cs.OpenAIMiddleware

Function processBeforeRequest($context : Object)->$result : Object
    TRACE("REQUEST: "+$context.messages[$context.messages.length-1].content)
    return $context

Function processAfterResponse($context : Object)->$result : Object
    TRACE("RESPONSE: "+$context.newMessage.content)
    return $context
```

## Middleware Management

### Add Middleware

```4d
$middleware:=MyMiddleware.new({config})
$helper.middleware.add($middleware)

// Or chain
$helper.middleware\
    .add($middleware1)\
    .add($middleware2)\
    .add($middleware3)
```

### Remove Middleware

```4d
$helper.middleware.remove("MyMiddleware")
```

### Enable/Disable Middleware

```4d
$middleware.disable()  // Skip in pipeline
$middleware.enable()   // Re-enable
```

### List Middleware

```4d
$count:=$helper.middleware.count()
$names:=$helper.middleware.list()
```

### Get Middleware

```4d
$middleware:=$helper.middleware.get("TokenCountingMiddleware")
```

### Clear All

```4d
$helper.middleware.clear()
```

## Context Object

The context object flows through the pipeline:

```4d
{
    helper: OpenAIChatHelper,           // Helper instance
    messages: Collection,                // Message history
    parameters: OpenAIParameters,        // Request parameters
    result: OpenAIResult,                // API response (after only)
    newMessage: OpenAIMessage,          // New message (after only)
    metadata: {}                         // Shared data between middleware
}
```

**Metadata** enables middleware communication:

```4d
// TokenCountingMiddleware sets:
$context.metadata.tokenCount:=3500

// SummarizationMiddleware reads:
If ($context.metadata.tokenCount>This.threshold)
    // Summarize
End if
```

## Real-World Examples

### Customer Support Bot

```4d
$helper:=cs.OpenAIChatHelper.new(\
    $client.chat; \
    "You are a customer support agent."; \
    New object("model"; "gpt-4o-mini")\
)

$helper.middleware\
    .add(cs.TokenCountingMiddleware.new({maxTokens: 4000}))\
    .add(cs.SummarizationMiddleware.new({\
        threshold: 3000; \
        keepRecentCount: 5; \
        summaryPrompt: "Summarize this support conversation:\n"+\
            "- Customer issue\n"+\
            "- Steps taken\n"+\
            "- Current status"\
    }))\
    .add(LoggingMiddleware.new({logFile: "support.log"}))
```

### Long-running Analysis

```4d
$helper.middleware\
    .add(cs.TokenCountingMiddleware.new({\
        maxTokens: 8000; \
        countStrategy: "chars"; \
        charsPerToken: 3  // For code/technical content\
    }))\
    .add(cs.SummarizationMiddleware.new({\
        threshold: 7000; \
        keepRecentCount: 3; \
        summaryPrompt: "Technical summary:\n"+\
            "- Problem statement\n"+\
            "- Approach\n"+\
            "- Current status"\
    }))
```

## Best Practices

### 1. Order Matters

Place fast middleware before slow ones:

```4d
// Good
$helper.middleware\
    .add(ValidationMiddleware.new())     // Fast
    .add(TokenCountingMiddleware.new())  // Fast
    .add(SummarizationMiddleware.new())  // Slow (API call)

// Bad
$helper.middleware\
    .add(SummarizationMiddleware.new())  // Slow first!
    .add(ValidationMiddleware.new())
```

### 2. Token Counting First

Always count tokens before other operations:

```4d
$helper.middleware\
    .add(TokenCountingMiddleware.new({...}))  // First
    .add(SummarizationMiddleware.new({...}))  // Uses token count
```

### 3. Debug During Development

```4d
$helper.middleware.enableDebug()
// See detailed execution logs
```

### 4. Track Statistics

```4d
$stats:=$tokenCounter.getStats()
$stats:=$summarizer.getStats()
// Monitor and optimize
```

### 5. Test in Isolation

Test each middleware separately before combining:

```4d
// Test token counter alone
$helper.middleware.add($tokenCounter)
// ... test ...

// Then add summarization
$helper.middleware.add($summarizer)
// ... test ...
```

### 6. Handle Errors Gracefully

Middleware catches errors and continues:

```4d
Function processBeforeRequest($context : Object)->$result : Object
    try
        // Your logic
    catch
        TRACE("Error in middleware: "+Last errors[0].message)
        // Return context to continue (or Null to abort)
    End try
    return $context
```

## Performance

### Token Counting

- **Character-based**: ~75% accurate, very fast
- **Word-based**: ~80% accurate, fast
- **Custom formula**: Accurate, depends on implementation
- **API-based**: 100% accurate, slow (extra API call)

Recommendation: Use character-based estimation for real-time. Use API response usage for accurate tracking.

### Summarization

- Adds one API call per summarization
- Set threshold wisely (e.g., 3000 tokens for 4000 limit)
- Summarize infrequently (only when needed)

### Pipeline Overhead

- Each middleware adds small overhead
- Only use middleware you need
- Disable unused middleware instead of removing

## Debugging

Enable debug mode for detailed logs:

```4d
// Pipeline debug
$helper.middleware.enableDebug()

// Individual middleware debug
$middleware.config.debug:=True

// Example output:
// [Pipeline] Executing BEFORE middleware pipeline (2 middleware)
// [Pipeline] Executing BEFORE: TokenCountingMiddleware
// [TokenCountingMiddleware] Token count: 1234 / 4000
// [Pipeline] Executing BEFORE: SummarizationMiddleware
// [SummarizationMiddleware] Token count: 1234 / Threshold: 3000
// [Pipeline] BEFORE pipeline completed in 5ms
```

## Migration Guide

### From numberOfMessages Trimming

Old way:

```4d
$helper:=cs.OpenAIChatHelper.new(...)
$helper.numberOfMessages:=10
```

New way:

```4d
$helper:=cs.OpenAIChatHelper.new(...)
$helper.middleware.add(cs.SummarizationMiddleware.new({\
    threshold: 3000; \
    keepRecentCount: 5\
}))
```

**Note:** `numberOfMessages` still works as a fallback. Middleware provides more control.

### From Manual Trimming

Old way:

```4d
// Manual management
If ($helper.messages.length>10)
    // Remove old messages manually
End if
```

New way:

```4d
// Automatic management
$helper.middleware.add(cs.SummarizationMiddleware.new({...}))
```

## API Reference

### OpenAIMiddleware

Base class for all middleware.

**Methods:**
- `processBeforeRequest($context)` - Process before API call
- `processAfterResponse($context)` - Process after API call
- `getName()` - Get middleware name
- `enable()` - Enable middleware
- `disable()` - Disable middleware
- `isEnabled()` - Check if enabled

### OpenAIMiddlewarePipeline

Manages middleware collection.

**Methods:**
- `add($middleware)` - Add middleware (chainable)
- `remove($name)` - Remove by name
- `get($name)` - Get by name
- `clear()` - Remove all
- `count()` - Get count
- `list()` - Get names
- `executeBeforeRequest($context)` - Run before pipeline
- `executeAfterResponse($context)` - Run after pipeline
- `enableDebug()` - Enable debug logs
- `disableDebug()` - Disable debug logs

### TokenCountingMiddleware

Tracks and enforces token limits.

**Constructor Options:**
- `maxTokens` (Integer) - Max tokens allowed (default: 4000)
- `abortOnExceed` (Boolean) - Abort if exceeded (default: false)
- `warnOnExceed` (Boolean) - Log warning (default: true)
- `countStrategy` (Text) - "chars", "words", or "custom"
- `charsPerToken` (Integer) - Characters per token (default: 4)
- `tokensPerWord` (Real) - Tokens per word (default: 0.75)
- `customCounter` (Formula) - Custom counting formula
- `onExceed` (Formula) - Callback on exceed
- `trackStats` (Boolean) - Track statistics (default: true)

**Methods:**
- `getStats()` - Get statistics
- `resetStats()` - Reset statistics

### SummarizationMiddleware

Compresses conversation history.

**Constructor Options:**
- `threshold` (Integer) - Token threshold to trigger (default: 3000)
- `keepRecentCount` (Integer) - Messages to keep verbatim (default: 5)
- `summaryPrompt` (Text) - Prompt for summarization
- `model` (Text) - Model for summarization (default: same as helper)
- `preserveSystemMessage` (Boolean) - Keep system message (default: true)
- `minMessagesToSummarize` (Integer) - Minimum to summarize (default: 3)
- `onSummarize` (Formula) - Callback on summarization

**Methods:**
- `getStats()` - Get statistics

### OpenAITokenCounter

Utility for estimating tokens.

**Constructor Options:**
- `strategy` (Text) - "chars", "words", or "custom"
- `charsPerToken` (Integer) - Characters per token
- `tokensPerWord` (Real) - Tokens per word
- `customCounter` (Formula) - Custom counting formula

**Methods:**
- `countText($text)` - Count tokens in text
- `countMessage($message)` - Count tokens in message
- `countMessages($messages)` - Count tokens in collection
- `estimateCost($tokens; $model; $type)` - Estimate cost

## Troubleshooting

### Middleware not executing

Check:
1. Is middleware added to pipeline? `$helper.middleware.list()`
2. Is middleware enabled? `$middleware.isEnabled()`
3. Enable debug: `$helper.middleware.enableDebug()`

### Summarization not triggering

Check:
1. Token count above threshold?
2. Enough messages? (need `keepRecentCount + minMessagesToSummarize`)
3. Enable debug to see token counts

### Token count inaccurate

- Character-based estimation is ~75% accurate
- For better accuracy, use API response `usage` field
- Consider custom counter with external tokenizer

### Performance issues

- Check middleware order (fast before slow)
- Reduce summarization frequency (higher threshold)
- Disable unused middleware
- Profile with debug mode

## Architecture Comparison

| Feature | LangChain | 4D AIKit |
|---------|-----------|----------|
| Chain of responsibility | ✅ | ✅ |
| Before/after hooks | ✅ | ✅ |
| Composable | ✅ | ✅ |
| Built-in summarization | ✅ | ✅ |
| Token counting | ✅ | ✅ (estimated) |
| Streaming support | ✅ | 🔄 (via callbacks) |
| Vector memory | ✅ | ❌ (future) |
| Custom middleware | ✅ | ✅ |

## Resources

- **Architecture Guide**: [middleware-architecture.md](middleware-architecture.md)
- **Examples**: [middleware-examples.md](middleware-examples.md)
- **Test Script**: [TestMiddleware.4dm](../Project/Sources/Methods/TestMiddleware.4dm)
- **LangChain Docs**: https://docs.langchain.com/oss/python/langchain/middleware
- **OpenAI Cookbook**: https://cookbook.openai.com/
- **Semantic Kernel**: https://learn.microsoft.com/semantic-kernel/

## Support

For questions or issues:
1. Check documentation and examples
2. Enable debug mode to diagnose
3. Run TestMiddleware.4dm to verify setup
4. Open issue on GitHub if problem persists

## Future Enhancements

Planned features:
- Async middleware support
- Streaming middleware processing
- Vector memory integration
- Middleware marketplace
- Visual pipeline builder
- Performance profiling tools

---

**Version**: 2.0.0
**Last Updated**: 2025-11-13
**License**: MIT
