/*
 * TokenCountingMiddleware - Monitor and enforce token limits
 *
 * Tracks token usage in conversations and enforces limits before API calls.
 *
 * Config options:
 *   - maxTokens: Integer (max tokens allowed, default: 4000)
 *   - abortOnExceed: Boolean (abort request if exceeded, default: false)
 *   - warnOnExceed: Boolean (log warning if exceeded, default: true)
 *   - countStrategy: Text ("chars" or "words", default: "chars")
 *   - onExceed: Formula (callback when limit exceeded, receives {tokens, limit})
 *   - trackStats: Boolean (track usage statistics, default: true)
 *
 * Usage:
 *   $middleware:=TokenCountingMiddleware.new({
 *       maxTokens: 3000;
 *       abortOnExceed: true
 *   })
 *   $helper.middleware.add($middleware)
 *
 * Access stats:
 *   $stats:=$middleware.getStats()
 *   // {totalTokens, requestCount, avgTokensPerRequest, maxTokensSeen}
 */

Class extends OpenAIMiddleware

Class constructor($config : Object)
	Super:C1705($config)

	// Default configuration
	This:C1470.maxTokens:=This:C1470.config.maxTokens#Null:C1517 ? This:C1470.config.maxTokens : 4000
	This:C1470.abortOnExceed:=This:C1470.config.abortOnExceed#Null:C1517 ? This:C1470.config.abortOnExceed : False:C215
	This:C1470.warnOnExceed:=This:C1470.config.warnOnExceed#Null:C1517 ? This:C1470.config.warnOnExceed : True:C214
	This:C1470.trackStats:=This:C1470.config.trackStats#Null:C1517 ? This:C1470.config.trackStats : True:C214

	// Callback when limit exceeded
	This:C1470.onExceed:=This:C1470.config.onExceed  // Formula

	// Initialize token counter
	$counterConfig:=New object:C1471(\
		"strategy"; This:C1470.config.countStrategy#Null:C1517 ? This:C1470.config.countStrategy : "chars"; \
		"charsPerToken"; This:C1470.config.charsPerToken; \
		"tokensPerWord"; This:C1470.config.tokensPerWord; \
		"customCounter"; This:C1470.config.customCounter\
		)
	This:C1470.counter:=OpenAITokenCounter.new($counterConfig)

	// Statistics tracking
	If (This:C1470.trackStats)
		This:C1470.stats:={\
			totalTokens: 0; \
			requestCount: 0; \
			avgTokensPerRequest: 0; \
			maxTokensSeen: 0; \
			totalInputTokens: 0; \
			totalOutputTokens: 0\
			}
	End if

	This:C1470._name:="TokenCountingMiddleware"

/*
 * Process before request - count tokens and check limits
 */
Function processBeforeRequest($context : Object)->$result : Object
	var $tokenCount : Integer
	var $exceedInfo : Object

	// Count tokens in current messages
	$tokenCount:=This:C1470.counter.countMessages($context.messages)

	This:C1470._log("Token count: "+String:C10($tokenCount)+" / "+String:C10(This:C1470.maxTokens))

	// Store in metadata for other middleware
	$context.metadata.tokenCount:=$tokenCount

	// Update statistics
	If (This:C1470.trackStats)
		This:C1470._updateStats($tokenCount; 0)
	End if

	// Check if limit exceeded
	If ($tokenCount>This:C1470.maxTokens)
		$exceedInfo:=New object:C1471(\
			"tokens"; $tokenCount; \
			"limit"; This:C1470.maxTokens; \
			"exceeded"; $tokenCount-This:C1470.maxTokens\
			)

		// Log warning
		If (This:C1470.warnOnExceed)
			TRACE:C157("[TokenCountingMiddleware] Token limit exceeded: "+String:C10($tokenCount)+" > "+String:C10(This:C1470.maxTokens))
		End if

		// Call callback if provided
		If (This:C1470.onExceed#Null:C1517)
			This:C1470.onExceed.call($exceedInfo)
		End if

		// Abort if configured
		If (This:C1470.abortOnExceed)
			TRACE:C157("[TokenCountingMiddleware] Aborting request due to token limit")
			return Null:C1517  // Abort pipeline
		End if
	End if

	return $context

/*
 * Process after response - track output tokens
 */
Function processAfterResponse($context : Object)->$result : Object
	var $outputTokens : Integer

	// Try to get actual token count from API response
	If ($context.result#Null:C1517)
		If ($context.result.usage#Null:C1517)
			// Update stats with actual usage from API
			If (This:C1470.trackStats)
				This:C1470._updateStatsFromAPI($context.result.usage)
			End if

			// Store in metadata
			$context.metadata.actualUsage:=$context.result.usage

			This:C1470._log("Actual usage - Input: "+String:C10($context.result.usage.prompt_tokens)+", Output: "+String:C10($context.result.usage.completion_tokens))
		Else
			// Estimate output tokens if API doesn't provide
			If ($context.newMessage#Null:C1517)
				$outputTokens:=This:C1470.counter.countMessage($context.newMessage)
				If (This:C1470.trackStats)
					This:C1470._updateStats(0; $outputTokens)
				End if
			End if
		End if
	End if

	return $context

/*
 * Get current statistics
 *
 * @return Object - Stats object
 */
Function getStats()->$stats : Object
	If (This:C1470.trackStats)
		return OB Copy:C1225(This:C1470.stats)
	End if
	return Null:C1517

/*
 * Reset statistics
 */
Function resetStats()
	If (This:C1470.trackStats)
		This:C1470.stats:={\
			totalTokens: 0; \
			requestCount: 0; \
			avgTokensPerRequest: 0; \
			maxTokensSeen: 0; \
			totalInputTokens: 0; \
			totalOutputTokens: 0\
			}
	End if

/*
 * Update statistics with estimated counts
 */
Function _updateStats($inputTokens : Integer; $outputTokens : Integer)
	var $totalRequest : Integer

	$totalRequest:=$inputTokens+$outputTokens

	This:C1470.stats.totalTokens:=This:C1470.stats.totalTokens+$totalRequest
	This:C1470.stats.totalInputTokens:=This:C1470.stats.totalInputTokens+$inputTokens
	This:C1470.stats.totalOutputTokens:=This:C1470.stats.totalOutputTokens+$outputTokens
	This:C1470.stats.requestCount:=This:C1470.stats.requestCount+1

	If ($totalRequest>This:C1470.stats.maxTokensSeen)
		This:C1470.stats.maxTokensSeen:=$totalRequest
	End if

	This:C1470.stats.avgTokensPerRequest:=This:C1470.stats.totalTokens\This:C1470.stats.requestCount

/*
 * Update statistics from actual API usage
 */
Function _updateStatsFromAPI($usage : Object)
	var $totalRequest : Integer

	If ($usage=Null:C1517)
		return
	End if

	$totalRequest:=$usage.total_tokens

	This:C1470.stats.totalTokens:=This:C1470.stats.totalTokens+$totalRequest
	This:C1470.stats.totalInputTokens:=This:C1470.stats.totalInputTokens+$usage.prompt_tokens
	This:C1470.stats.totalOutputTokens:=This:C1470.stats.totalOutputTokens+$usage.completion_tokens
	This:C1470.stats.requestCount:=This:C1470.stats.requestCount+1

	If ($totalRequest>This:C1470.stats.maxTokensSeen)
		This:C1470.stats.maxTokensSeen:=$totalRequest
	End if

	This:C1470.stats.avgTokensPerRequest:=This:C1470.stats.totalTokens\This:C1470.stats.requestCount
