# Middleware Examples for 4D AIKit

This document provides practical examples of using middleware with OpenAIChatHelper.

## Table of Contents

1. [Basic Setup](#basic-setup)
2. [Token Counting Middleware](#token-counting-middleware)
3. [Summarization Middleware](#summarization-middleware)
4. [Combined Middleware Pipeline](#combined-middleware-pipeline)
5. [Custom Middleware](#custom-middleware)
6. [Real-World Use Cases](#real-world-use-cases)

## Basic Setup

First, create an OpenAI client and chat helper:

```4d
// Initialize OpenAI client
$client:=cs.OpenAI.new({apiKey: "your-api-key"})

// Create chat helper
$helper:=cs.OpenAIChatHelper.new(\
    $client.chat; \
    "You are a helpful assistant."; \
    New object("model"; "gpt-4o-mini")\
)
```

## Token Counting Middleware

### Example 1: Basic Token Tracking

Track token usage without enforcing limits:

```4d
// Create token counting middleware
$tokenCounter:=cs.TokenCountingMiddleware.new({\
    maxTokens: 4000; \
    abortOnExceed: False; \
    warnOnExceed: True\
})

// Add to pipeline
$helper.middleware.add($tokenCounter)

// Use normally
$result:=$helper.prompt("Tell me about quantum computing")

// Check statistics
$stats:=$tokenCounter.getStats()
TRACE("Total tokens used: "+String($stats.totalTokens))
TRACE("Average per request: "+String($stats.avgTokensPerRequest))
```

### Example 2: Enforce Token Limit

Abort requests that exceed token limit:

```4d
// Create middleware that aborts on exceed
$tokenCounter:=cs.TokenCountingMiddleware.new({\
    maxTokens: 3000; \
    abortOnExceed: True; \
    onExceed: Formula(\
        ALERT("Token limit exceeded: "+String($1.tokens)+" > "+String($1.limit))\
    )\
})

$helper.middleware.add($tokenCounter)

// This will abort if conversation exceeds 3000 tokens
$result:=$helper.prompt("Long conversation...")

If ($result=Null)
    TRACE("Request aborted due to token limit")
End if
```

### Example 3: Custom Token Counter

Use a custom formula for more accurate token counting:

```4d
// Custom counter that uses external service
$customCounter:=Formula(\
    // Call external tokenizer service\
    var $request:=New object("text"; $1.text; "model"; "gpt-4")\
    var $response:=HTTP Request(HTTP POST method; "https://tokenizer.example.com/count"; $request)\
    return $response.token_count\
)

$tokenCounter:=cs.TokenCountingMiddleware.new({\
    maxTokens: 4000; \
    countStrategy: "custom"; \
    customCounter: $customCounter\
})

$helper.middleware.add($tokenCounter)
```

## Summarization Middleware

### Example 4: Basic Summarization

Automatically summarize when conversation gets long:

```4d
// Create summarization middleware
$summarizer:=cs.SummarizationMiddleware.new({\
    threshold: 3000; \
    keepRecentCount: 5; \
    summaryPrompt: "Summarize the conversation in concise bullet points."\
})

$helper.middleware.add($summarizer)

// Have a long conversation - summarization happens automatically
For ($i; 1; 20)
    $result:=$helper.prompt("Question "+String($i)+"...")
End for

// Check if summarization occurred
$stats:=$summarizer.getStats()
If ($stats.summarizationCount>0)
    TRACE("Conversation was summarized "+String($stats.summarizationCount)+" times")
End if
```

### Example 5: Structured Summary

Use a structured prompt for better summaries:

```4d
$summaryPrompt:="Create a structured summary of the conversation:\n"+\
    "\n"+\
    "## User Goals:\n"+\
    "[Main objectives and questions]\n"+\
    "\n"+\
    "## Key Information:\n"+\
    "[Important facts and data provided]\n"+\
    "\n"+\
    "## Progress:\n"+\
    "[What has been accomplished]\n"+\
    "\n"+\
    "## Outstanding:\n"+\
    "[Unresolved issues or next steps]\n"+\
    "\n"+\
    "Be concise and factual."

$summarizer:=cs.SummarizationMiddleware.new({\
    threshold: 3000; \
    keepRecentCount: 5; \
    summaryPrompt: $summaryPrompt; \
    onSummarize: Formula(\
        TRACE("Summarized "+String($1.summarizedMessages)+" messages")\
        TRACE("Summary: "+$1.summary)\
    )\
})

$helper.middleware.add($summarizer)
```

### Example 6: Conditional Summarization

Only enable summarization for long conversations:

```4d
// Start without summarization
$helper:=cs.OpenAIChatHelper.new($client.chat; "You are helpful"; New object)

// Have some conversation
For ($i; 1; 10)
    $result:=$helper.prompt("Short question "+String($i))
End for

// Enable summarization after conversation grows
If ($helper.messages.length>15)
    $summarizer:=cs.SummarizationMiddleware.new({\
        threshold: 3000; \
        keepRecentCount: 5\
    })
    $helper.middleware.add($summarizer)
    TRACE("Summarization enabled")
End if

// Continue conversation with summarization
For ($i; 11; 30)
    $result:=$helper.prompt("Question "+String($i))
End for
```

## Combined Middleware Pipeline

### Example 7: Full Pipeline

Combine multiple middleware for comprehensive conversation management:

```4d
// Initialize helper
$helper:=cs.OpenAIChatHelper.new(\
    $client.chat; \
    "You are a helpful assistant."; \
    New object("model"; "gpt-4o-mini")\
)

// Build pipeline with multiple middleware
// Order matters! Execute from first to last

// 1. Token counting (check limits first)
$helper.middleware.add(cs.TokenCountingMiddleware.new({\
    maxTokens: 4000; \
    abortOnExceed: False; \
    warnOnExceed: True\
}))

// 2. Summarization (if tokens approaching limit)
$helper.middleware.add(cs.SummarizationMiddleware.new({\
    threshold: 3000; \
    keepRecentCount: 5\
}))

// Enable debug mode to see middleware execution
$helper.middleware.enableDebug()

// Use normally - middleware runs automatically
$result:=$helper.prompt("Tell me about AI")
```

### Example 8: Dynamic Middleware Management

Add/remove middleware dynamically:

```4d
// Start with basic token counting
$tokenCounter:=cs.TokenCountingMiddleware.new({maxTokens: 4000})
$helper.middleware.add($tokenCounter)

// Have some conversation
For ($i; 1; 10)
    $result:=$helper.prompt("Question "+String($i))
End for

// Check if we need summarization
$stats:=$tokenCounter.getStats()
If ($stats.avgTokensPerRequest>500)
    // Add summarization for long messages
    $summarizer:=cs.SummarizationMiddleware.new({\
        threshold: 3000; \
        keepRecentCount: 5\
    })
    $helper.middleware.add($summarizer)
    TRACE("Added summarization middleware")
End if

// Continue conversation
For ($i; 11; 20)
    $result:=$helper.prompt("Question "+String($i))
End for

// Later: disable token counter temporarily
$tokenCounter.disable()
TRACE("Token counter disabled")

// Re-enable
$tokenCounter.enable()
TRACE("Token counter re-enabled")
```

## Custom Middleware

### Example 9: Logging Middleware

Create custom middleware to log all interactions:

```4d
// Define custom logging middleware
Class extends cs.OpenAIMiddleware

Class constructor($config : Object)
    Super($config)
    This._name:="LoggingMiddleware"
    This.logFile:=This.config.logFile || "chat.log"

Function processBeforeRequest($context : Object)->$result : Object
    // Log request
    var $logEntry : Object:=New object(\
        "timestamp"; Timestamp; \
        "type"; "request"; \
        "messageCount"; $context.messages.length; \
        "lastMessage"; $context.messages[$context.messages.length-1]\
    )
    This._writeLog($logEntry)

    return $context

Function processAfterResponse($context : Object)->$result : Object
    // Log response
    var $logEntry : Object:=New object(\
        "timestamp"; Timestamp; \
        "type"; "response"; \
        "success"; $context.result.success; \
        "usage"; $context.result.usage; \
        "message"; $context.newMessage.content\
    )
    This._writeLog($logEntry)

    return $context

Function _writeLog($entry : Object)
    var $text : Text:=JSON Stringify($entry)
    TEXT TO DOCUMENT(This.logFile; $text+"\n"; *)
End Function
```

Use it:

```4d
$logger:=LoggingMiddleware.new({logFile: "my-chat.log"})
$helper.middleware.add($logger)

$result:=$helper.prompt("Hello")
// Check my-chat.log for logs
```

### Example 10: Content Filter Middleware

Filter or modify messages before sending:

```4d
// Define content filter middleware
Class extends cs.OpenAIMiddleware

Class constructor($config : Object)
    Super($config)
    This._name:="ContentFilterMiddleware"
    This.blockedWords:=This.config.blockedWords || []

Function processBeforeRequest($context : Object)->$result : Object
    // Check last message for blocked words
    var $lastMsg : Object:=$context.messages[$context.messages.length-1]

    If ($lastMsg.role="user")
        var $content : Text:=$lastMsg.content
        var $word : Text

        For each ($word; This.blockedWords)
            If (Position($word; $content)>0)
                ALERT("Blocked word detected: "+$word)
                return Null  // Abort request
            End if
        End for each
    End if

    return $context
End function
```

Use it:

```4d
$filter:=ContentFilterMiddleware.new({\
    blockedWords: ["badword1"; "badword2"]\
})
$helper.middleware.add($filter)

// This will be blocked
$result:=$helper.prompt("Message with badword1")
// $result is Null
```

### Example 11: Response Transformation Middleware

Modify responses after receiving them:

```4d
// Define response transformer
Class extends cs.OpenAIMiddleware

Class constructor($config : Object)
    Super($config)
    This._name:="ResponseTransformerMiddleware"

Function processAfterResponse($context : Object)->$result : Object
    // Add timestamp to all assistant messages
    If ($context.newMessage.role="assistant")
        $context.newMessage.content:="["+String(Current time)+"] "+\
            $context.newMessage.content
    End if

    return $context
End function
```

Use it:

```4d
$transformer:=ResponseTransformerMiddleware.new()
$helper.middleware.add($transformer)

$result:=$helper.prompt("Hello")
// Response will have timestamp prepended
```

## Real-World Use Cases

### Use Case 1: Customer Support Bot

Long conversations with automatic summarization and logging:

```4d
// Setup
$helper:=cs.OpenAIChatHelper.new(\
    $client.chat; \
    "You are a customer support agent."; \
    New object("model"; "gpt-4o-mini")\
)

// Add middleware
$helper.middleware\
    .add(LoggingMiddleware.new({logFile: "support-"+String(Current date)+".log"}))\
    .add(cs.TokenCountingMiddleware.new({maxTokens: 4000; warnOnExceed: True}))\
    .add(cs.SummarizationMiddleware.new({\
        threshold: 3000; \
        keepRecentCount: 5; \
        summaryPrompt: "Summarize this support conversation:\n"+\
            "- Customer issue\n"+\
            "- Steps taken\n"+\
            "- Current status"\
    }))

// Use in support session
$result:=$helper.prompt("Customer message...")
```

### Use Case 2: Code Assistant

Technical conversations with high token limits:

```4d
$helper:=cs.OpenAIChatHelper.new(\
    $client.chat; \
    "You are a programming assistant."; \
    New object("model"; "gpt-4-turbo")\
)

// Configure for code (more tokens needed)
$helper.middleware\
    .add(cs.TokenCountingMiddleware.new({\
        maxTokens: 8000; \
        countStrategy: "chars"; \
        charsPerToken: 3  // Code is denser\
    }))\
    .add(cs.SummarizationMiddleware.new({\
        threshold: 7000; \
        keepRecentCount: 3; \
        summaryPrompt: "Summarize the technical discussion:\n"+\
            "- Problem being solved\n"+\
            "- Code approach\n"+\
            "- Current implementation status"\
    }))

$result:=$helper.prompt("How do I implement a binary tree?")
```

### Use Case 3: Educational Tutor

Track learning progress across long sessions:

```4d
$helper:=cs.OpenAIChatHelper.new(\
    $client.chat; \
    "You are an educational tutor."; \
    New object("model"; "gpt-4o-mini")\
)

// Custom middleware to track topics covered
Class extends cs.OpenAIMiddleware
    Function processAfterResponse($context : Object)->$result : Object
        // Extract and store topics discussed
        // Update student progress
        return $context
    End function

$helper.middleware\
    .add(TopicTrackerMiddleware.new())\
    .add(cs.TokenCountingMiddleware.new({maxTokens: 4000}))\
    .add(cs.SummarizationMiddleware.new({\
        threshold: 3000; \
        keepRecentCount: 4; \
        summaryPrompt: "Summarize the learning session:\n"+\
            "- Topics covered\n"+\
            "- Key concepts learned\n"+\
            "- Questions answered\n"+\
            "- Next steps"\
    }))
```

## Best Practices

1. **Order Matters**: Place fast middleware (validation) before slow ones (summarization)
2. **Token Counting First**: Always count tokens before other operations
3. **Summarize Before Trim**: Let summarization compress history before trimming
4. **Debug Mode**: Enable debug during development to see middleware execution
5. **Statistics**: Track and monitor middleware statistics for optimization
6. **Error Handling**: Middleware should be resilient - errors in one shouldn't break others
7. **Configuration**: Make middleware configurable for different use cases
8. **Testing**: Test middleware in isolation before combining

## Debugging

Enable debug mode to see middleware execution:

```4d
// Enable debug for pipeline
$helper.middleware.enableDebug()

// Enable debug for specific middleware
$tokenCounter.config.debug:=True

// Now see detailed logs
$result:=$helper.prompt("Test message")
// Logs show: [Pipeline] Executing BEFORE middleware...
//             [TokenCountingMiddleware] Token count: 50 / 4000
//             etc.
```

## Performance Considerations

1. **Token Counting**: Character-based estimation is fast (~75% accurate)
2. **Summarization**: Adds one extra API call - use threshold wisely
3. **Middleware Count**: Each middleware adds overhead - only use what you need
4. **Caching**: Consider caching summaries or token counts
5. **Async**: Middleware executes synchronously - keep processing fast

## Migration from Existing Code

If you have existing code using `numberOfMessages` trimming:

```4d
// Old way
$helper:=cs.OpenAIChatHelper.new($client.chat; "System"; New object)
$helper.numberOfMessages:=10

// New way with middleware (more control)
$helper:=cs.OpenAIChatHelper.new($client.chat; "System"; New object)
$helper.middleware.add(cs.SummarizationMiddleware.new({\
    threshold: 3000; \
    keepRecentCount: 5\
}))

// Old trimming still works as fallback
$helper.numberOfMessages:=20
```

## Further Reading

- [Middleware Architecture](middleware-architecture.md)
- [OpenAI Token Limits](https://platform.openai.com/docs/models)
- [Best Practices for LLM Memory](https://cookbook.openai.com/)
