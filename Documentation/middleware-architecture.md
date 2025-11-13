# Middleware Architecture for 4D AIKit

## Overview

This document describes the middleware architecture for managing conversation context, summarization, and other processing tasks in 4D AIKit.

## Design Principles

### 1. Separation of Concerns
- **Callbacks**: Event notifications (onData, onResponse, onError) - observer pattern
- **Middleware**: Message transformation and processing - chain of responsibility pattern

### 2. Middleware Pipeline

```
User Message Input
    ↓
[Before Middleware Pipeline]
    ↓ TokenCountingMiddleware → Check token limits
    ↓ SummarizationMiddleware → Summarize if needed
    ↓ ValidationMiddleware → Validate messages
    ↓ LoggingMiddleware → Log for analytics
    ↓
API Call (OpenAIChatCompletionsAPI.create)
    ↓
[After Middleware Pipeline]
    ↓ ResponseProcessingMiddleware → Process response
    ↓ TrimMiddleware → Trim if needed
    ↓
Assistant Message Added
```

### 3. Middleware Interface

Each middleware implements:
```4d
Class constructor($config : Object)
    // Initialize with configuration

Function processBeforeRequest($context : Object) -> $context : Object
    // Transform context before API call
    // $context = {helper, messages, parameters}
    // Return modified context or Null to abort

Function processAfterResponse($context : Object) -> $context : Object
    // Transform context after API call
    // $context = {helper, messages, result, newMessage}
    // Return modified context

Function getName() -> $name : Text
    // Return middleware name for debugging
```

### 4. Context Object

The context object passed through middleware:
```4d
{
    helper: OpenAIChatHelper,           // Reference to helper instance
    messages: Collection,                // Current message history
    parameters: OpenAIParameters,        // Request parameters
    result: OpenAIResult,                // API response (after only)
    newMessage: OpenAIMessage,          // New assistant message (after only)
    metadata: {}                         // Shared data between middleware
}
```

## Architecture Components

### 1. OpenAIMiddleware (Base Class)
- Abstract base class for all middleware
- Provides default implementations (pass-through)
- Handles common error handling

### 2. OpenAIMiddlewarePipeline
- Manages collection of middleware
- Executes middleware in order
- Handles errors and abort scenarios
- Methods:
  - `add($middleware)`: Add middleware to pipeline
  - `remove($name)`: Remove middleware by name
  - `executeBeforeRequest($context)`: Run before-request pipeline
  - `executeAfterResponse($context)`: Run after-response pipeline

### 3. Built-in Middleware

#### TokenCountingMiddleware
- **Purpose**: Track token usage and enforce limits
- **Before**: Count tokens in messages, abort if exceeds limit
- **After**: Update token statistics
- **Config**: `{maxTokens: Integer, tokenCounter: Formula}`

#### SummarizationMiddleware
- **Purpose**: Summarize old conversations when approaching limit
- **Before**: Check if summarization needed, create summary message
- **After**: N/A
- **Config**: `{threshold: Integer, summaryPrompt: Text, keepRecentCount: Integer}`

#### TrimMiddleware
- **Purpose**: Remove old messages (replaces current _trim method)
- **Before**: N/A
- **After**: Trim messages based on strategy
- **Config**: `{maxMessages: Integer, strategy: Text}` (strategies: "fifo", "priority", "smart")

#### LoggingMiddleware
- **Purpose**: Log conversations for debugging/analytics
- **Before**: Log request
- **After**: Log response and metrics
- **Config**: `{logger: Formula, logLevel: Text}`

#### ValidationMiddleware
- **Purpose**: Validate messages before sending
- **Before**: Check content, roles, format
- **After**: N/A
- **Config**: `{rules: Collection}`

#### CacheMiddleware
- **Purpose**: Cache responses for identical requests
- **Before**: Check cache, return cached response if found
- **After**: Store response in cache
- **Config**: `{cache: Object, ttl: Integer}`

## Integration with OpenAIChatHelper

### Modified Flow

```4d
Function prompt($message : Text; $parameters : Object) -> $result : Object

    // 1. Add user message
    This._pushMessage(OpenAIMessage.new({role: "user"; content: $message}))

    // 2. Create context
    $context:={
        helper: This
        messages: This.messages.copy()
        parameters: $parameters!=Null ? $parameters : This.defaultParameters
        metadata: {}
    }

    // 3. Execute BEFORE middleware pipeline
    $context:=This.middleware.executeBeforeRequest($context)

    If ($context=Null)  // Middleware aborted
        return Null
    End if

    // 4. Make API call with potentially modified context
    $result:=This.chat.completions.create($context.parameters)

    // 5. Add to context for AFTER middleware
    $context.result:=$result
    $context.newMessage:=OpenAIMessage.new($result.choices[0].message)

    // 6. Execute AFTER middleware pipeline
    $context:=This.middleware.executeAfterResponse($context)

    If ($context!=Null)
        // 7. Add assistant message
        This._pushMessage($context.newMessage)
    End if

    return $result
End Function
```

### Backward Compatibility

- Middleware is optional (can be empty pipeline)
- Existing code without middleware continues to work
- Callbacks still fire as before
- `_trim()` method moved to TrimMiddleware but old method remains as fallback

## Usage Examples

### Example 1: Basic Summarization

```4d
// Create helper
$helper:=OpenAIChatHelper.new($client)

// Add summarization middleware
$summarizer:=SummarizationMiddleware.new({
    threshold: 3000;  // tokens
    keepRecentCount: 5;  // Keep last 5 messages verbatim
    summaryPrompt: "Summarize the conversation so far in concise bullet points."
})
$helper.middleware.add($summarizer)

// Use normally - summarization happens automatically
$result:=$helper.prompt("Tell me about quantum computing")
```

### Example 2: Full Pipeline

```4d
$helper:=OpenAIChatHelper.new($client)

// Add multiple middleware in order
$helper.middleware\
    .add(LoggingMiddleware.new({logLevel: "debug"}))\
    .add(ValidationMiddleware.new({maxContentLength: 10000}))\
    .add(TokenCountingMiddleware.new({maxTokens: 4000}))\
    .add(SummarizationMiddleware.new({threshold: 3000; keepRecentCount: 5}))\
    .add(TrimMiddleware.new({maxMessages: 50; strategy: "smart"}))

// All middleware runs automatically
$result:=$helper.prompt("Hello")
```

### Example 3: Conditional Middleware

```4d
// Only add summarization in production
If (Not(Is compiled mode(*)))
    $helper.middleware.add(LoggingMiddleware.new({logLevel: "debug"}))
Else
    $helper.middleware.add(LoggingMiddleware.new({logLevel: "error"}))
End if

// Only summarize for long conversations
If ($helper.messages.length>20)
    $helper.middleware.add(SummarizationMiddleware.new({threshold: 3000}))
End if
```

### Example 4: Custom Middleware

```4d
// Create custom middleware
Class constructor
    // Initialize

Function processBeforeRequest($context : Object) -> $result : Object
    // Add timestamp to metadata
    $context.metadata.requestTime:=Current time

    // Add custom system message
    $systemMsg:=OpenAIMessage.new({
        role: "system"
        content: "Current time: "+String(Current time)
    })
    $context.messages.insert(0; $systemMsg)

    return $context
End Function

Function processAfterResponse($context : Object) -> $result : Object
    // Calculate latency
    $latency:=Current time-$context.metadata.requestTime
    TRACE("Request took: "+String($latency)+" ms")

    return $context
End Function

Function getName() -> $name : Text
    return "TimestampMiddleware"
End Function

// Use it
$helper.middleware.add(TimestampMiddleware.new())
```

## Token Counting Implementation

Since 4D doesn't have built-in tokenizers, we provide multiple strategies:

### 1. Approximation (Fast, ~75% accurate)
```4d
Function estimateTokens($text : Text) -> $tokens : Integer
    // Rough estimate: ~4 characters per token for English
    return Length($text)/4
End Function
```

### 2. API-based (Accurate, requires extra API call)
```4d
// Use OpenAI's tiktoken endpoint or embeddings API
// Count tokens from usage in response
```

### 3. External Service (Most accurate)
```4d
// Call external tokenizer service
// https://www.npmjs.com/package/tiktoken or similar
```

## Summarization Strategies

### 1. Simple Prompt (Recommended)
```4d
{
    summaryPrompt: "Summarize the conversation so far, focusing on:\n"+
                   "- User's main goals and questions\n"+
                   "- Key information provided\n"+
                   "- Current status and next steps\n"+
                   "Present as concise bullet points."
}
```

### 2. Structured Summary
```4d
{
    summaryPrompt: "Create a structured summary:\n"+
                   "## User Goals:\n[List main objectives]\n"+
                   "## Progress:\n[What has been accomplished]\n"+
                   "## Outstanding Issues:\n[What remains]\n"+
                   "Be concise and factual."
}
```

### 3. Sliding Window (Hybrid)
- Keep last N messages verbatim
- Summarize everything before that
- Implemented via `keepRecentCount` config

## Migration Path

### Phase 1: Create Middleware Infrastructure (Week 1)
- [ ] Implement OpenAIMiddleware base class
- [ ] Implement OpenAIMiddlewarePipeline
- [ ] Add middleware property to OpenAIChatHelper
- [ ] Update prompt() method to execute pipeline

### Phase 2: Build Core Middleware (Week 2)
- [ ] Implement TokenCountingMiddleware (with estimation)
- [ ] Implement SummarizationMiddleware
- [ ] Implement TrimMiddleware (migrate from _trim)
- [ ] Implement LoggingMiddleware

### Phase 3: Testing & Documentation (Week 3)
- [ ] Unit tests for each middleware
- [ ] Integration tests for pipeline
- [ ] Performance benchmarks
- [ ] Usage examples and documentation

### Phase 4: Advanced Features (Week 4+)
- [ ] CacheMiddleware
- [ ] ValidationMiddleware
- [ ] External tokenizer integration
- [ ] Vector memory store integration

## Performance Considerations

1. **Middleware Order Matters**: Place fast middleware (validation) before slow ones (summarization)
2. **Lazy Execution**: Only execute middleware that affects current request
3. **Caching**: Cache token counts, summaries, etc.
4. **Async Support**: Consider async middleware for external calls

## Security Considerations

1. **Validation**: Always validate before sending to API
2. **Sanitization**: Remove sensitive data in logging middleware
3. **Rate Limiting**: Implement in middleware to protect API keys
4. **Audit Trail**: Log all transformations for debugging

## Comparison with LangChain

| Feature | LangChain | 4D AIKit Middleware |
|---------|-----------|---------------------|
| Chain of responsibility | ✅ | ✅ |
| Before/after hooks | ✅ | ✅ |
| Composable | ✅ | ✅ |
| Built-in summarization | ✅ | ✅ (planned) |
| Token counting | ✅ | ✅ (estimated) |
| Streaming support | ✅ | 🔄 (callbacks) |
| Vector memory | ✅ | ❌ (future) |

## Future Enhancements

1. **Async Middleware**: Support for async processing
2. **Conditional Execution**: Execute middleware based on rules
3. **Middleware Marketplace**: Share custom middleware
4. **Visual Pipeline Builder**: GUI for configuring pipeline
5. **Streaming Middleware**: Process streaming responses
6. **Memory Store Integration**: Connect to vector DBs for long-term memory

## References

- LangChain Middleware: https://docs.langchain.com/oss/python/langchain/middleware
- OpenAI Agents Cookbook: https://cookbook.openai.com/
- Semantic Kernel Memory: https://learn.microsoft.com/semantic-kernel/
- mem0.ai: https://mem0.ai/
