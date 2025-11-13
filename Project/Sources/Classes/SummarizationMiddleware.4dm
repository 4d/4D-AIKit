/*
 * SummarizationMiddleware - Compress conversation history via summarization
 *
 * Implements the "sliding window + summary" pattern for managing long conversations:
 * 1. Keeps recent N messages verbatim (for immediate context)
 * 2. Summarizes older messages into a single assistant message
 * 3. Preserves system message if present
 *
 * This prevents information loss from naive trimming while staying within token limits.
 *
 * Config options:
 *   - threshold: Integer (trigger summarization at N tokens, default: 3000)
 *   - keepRecentCount: Integer (messages to keep verbatim, default: 5)
 *   - summaryPrompt: Text (prompt for summarization, default: built-in)
 *   - model: Text (model to use for summarization, default: same as helper)
 *   - onSummarize: Formula (callback when summarization occurs)
 *   - preserveSystemMessage: Boolean (keep system message, default: true)
 *   - minMessagesToSummarize: Integer (minimum messages before summarizing, default: 3)
 *
 * Usage:
 *   $middleware:=SummarizationMiddleware.new({
 *       threshold: 3000;
 *       keepRecentCount: 5;
 *       summaryPrompt: "Summarize key points as bullet points."
 *   })
 *   $helper.middleware.add($middleware)
 */

property threshold : Integer
property keepRecentCount : Integer
property preserveSystemMessage : Boolean
property minMessagesToSummarize : Integer
property model : Text
property summaryPrompt : Text
property onSummarize : 4D:C1709.Function
property counter : cs:C1710.OpenAITokenCounter
property summarizationCount : Integer
property lastSummarization : Object

Class extends cs:C1710.OpenAIMiddleware

Class constructor($config : Object)
	Super:C1705($config)

	// Default configuration
	This:C1470.threshold:=This:C1470.config.threshold#Null:C1517 ? This:C1470.config.threshold : 3000
	This:C1470.keepRecentCount:=This:C1470.config.keepRecentCount#Null:C1517 ? This:C1470.config.keepRecentCount : 5
	This:C1470.preserveSystemMessage:=This:C1470.config.preserveSystemMessage#Null:C1517 ? This:C1470.config.preserveSystemMessage : True:C214
	This:C1470.minMessagesToSummarize:=This:C1470.config.minMessagesToSummarize#Null:C1517 ? This:C1470.config.minMessagesToSummarize : 3
	This:C1470.model:=This:C1470.config.model  // Optional: specify different model for summarization

	// Summary prompt
	This:C1470.summaryPrompt:=This:C1470.config.summaryPrompt#Null:C1517 ? This:C1470.config.summaryPrompt : This:C1470._getDefaultSummaryPrompt()

	// Callback
	This:C1470.onSummarize:=This:C1470.config.onSummarize  // Formula

	// Token counter for checking threshold
	This:C1470.counter:=cs:C1710.OpenAITokenCounter.new(New object:C1471("strategy"; "chars"))

	// Track summarizations
	This:C1470.summarizationCount:=0
	This:C1470.lastSummarization:=Null:C1517

	This:C1470._name:="SummarizationMiddleware"

/*
 * Process before request - check if summarization needed
 */
Function processBeforeRequest($context : Object)->$result : Object
	var $tokenCount : Integer
	var $shouldSummarize : Boolean

	// Get token count (from TokenCountingMiddleware if present, or calculate)
	If ($context.metadata.tokenCount#Null:C1517)
		$tokenCount:=$context.metadata.tokenCount
	Else
		$tokenCount:=This:C1470.counter.countMessages($context.messages)
	End if

	This:C1470._log("Token count: "+String:C10($tokenCount)+" / Threshold: "+String:C10(This:C1470.threshold))

	// Check if summarization needed
	$shouldSummarize:=$tokenCount>=This:C1470.threshold

	// Additional checks
	If ($shouldSummarize)
		// Need enough messages to make summarization worthwhile
		If ($context.messages.length<(This:C1470.keepRecentCount+This:C1470.minMessagesToSummarize))
			$shouldSummarize:=False:C215
			This:C1470._log("Not enough messages to summarize")
		End if
	End if

	If ($shouldSummarize)
		This:C1470._log("Summarization triggered")
		$context:=This:C1470._summarizeConversation($context)

		// Store summarization info in metadata
		$context.metadata.wasSummarized:=True:C214
		$context.metadata.summarizationCount:=This:C1470.summarizationCount
	End if

	return $context

/*
 * Summarize conversation by keeping recent messages and compressing older ones
 */
Function _summarizeConversation($context : Object)->$result : Object
	var $systemMessage; $summaryMessage; $msg : Object
	var $messagesToSummarize; $recentMessages; $newMessages : Collection
	var $summary : Text
	var $splitIndex : Integer

	This:C1470._log("Starting summarization process")

	// 1. Separate messages into: system | old (to summarize) | recent (keep verbatim)
	$systemMessage:=Null:C1517
	$messagesToSummarize:=[]
	$recentMessages:=[]

	// Extract system message if present and preserving
	If (This:C1470.preserveSystemMessage && ($context.messages.length>0))
		If ($context.messages[0].role="system")
			$systemMessage:=$context.messages[0]
			$splitIndex:=1
		Else
			$splitIndex:=0
		End if
	Else
		$splitIndex:=0
	End if

	// Calculate split point for recent messages
	$splitIndex:=Max:C3($splitIndex; $context.messages.length-This:C1470.keepRecentCount)

	// Split messages
	If ($splitIndex>0)
		$messagesToSummarize:=$context.messages.slice(This:C1470.preserveSystemMessage ? 1 : 0; $splitIndex)
	End if
	$recentMessages:=$context.messages.slice($splitIndex)

	This:C1470._log("Messages to summarize: "+String:C10($messagesToSummarize.length)+", Recent to keep: "+String:C10($recentMessages.length))

	// 2. Check if there's anything to summarize
	If ($messagesToSummarize.length<This:C1470.minMessagesToSummarize)
		This:C1470._log("Not enough messages to summarize, skipping")
		return $context
	End if

	// 3. Generate summary
	$summary:=This:C1470._generateSummary($messagesToSummarize; $context)

	If ($summary="")
		This:C1470._log("Failed to generate summary, keeping original messages")
		return $context
	End if

	// 4. Create summary message
	$summaryMessage:=New object:C1471(\
		"role"; "assistant"; \
		"content"; $summary; \
		"_isSummary"; True:C214; \
		"_summarizedCount"; $messagesToSummarize.length; \
		"_summarizedAt"; Timestamp:C1600\
		)

	// 5. Reconstruct messages: [system?] + [summary] + [recent messages]
	$newMessages:=[]

	If ($systemMessage#Null:C1517)
		$newMessages.push($systemMessage)
	End if

	$newMessages.push($summaryMessage)

	For each ($msg; $recentMessages)
		$newMessages.push($msg)
	End for each

	// 6. Update context
	$context.messages:=$newMessages

	// 7. Track summarization
	This:C1470.summarizationCount:=This:C1470.summarizationCount+1
	This:C1470.lastSummarization:=New object:C1471(\
		"timestamp"; Timestamp:C1600; \
		"messageCount"; $messagesToSummarize.length; \
		"summary"; $summary\
		)

	This:C1470._log("Summarization complete. New message count: "+String:C10($newMessages.length))

	// 8. Call callback if provided
	If (This:C1470.onSummarize#Null:C1517)
		This:C1470.onSummarize.call(New object:C1471(\
			"count"; This:C1470.summarizationCount; \
			"summarizedMessages"; $messagesToSummarize.length; \
			"summary"; $summary\
			))
	End if

	return $context

/*
 * Generate summary by calling LLM with summarization prompt
 */
Function _generateSummary($messages : Collection; $context : Object)->$summary : Text
	var $summaryPrompt : Text
	var $conversationText : Text
	var $result : Object
	var $chatAPI : Object
	var $parameters : Object

	This:C1470._log("Generating summary for "+String:C10($messages.length)+" messages")

	// 1. Build conversation text from messages
	$conversationText:=This:C1470._buildConversationText($messages)

	// 2. Build summary request prompt
	$summaryPrompt:=This:C1470.summaryPrompt+"\n\n"+\
		"Conversation to summarize:\n"+\
		"---\n"+\
		$conversationText+\
		"\n---\n\n"+\
		"Provide a concise summary:"

	This:C1470._log("Summary prompt length: "+String:C10(Length:C16($summaryPrompt)))

	// 3. Call API to generate summary
	try
		// Use the helper's chat API or create new one
		If ($context.helper#Null:C1517)
			$chatAPI:=$context.helper.chat
		Else
			// Should not happen, but fallback
			LOG EVENT:C667(Into system standard outputs:K38:9; "[SummarizationMiddleware] ERROR: No helper in context"; Error message:K38:2)
			return ""
		End if

		// Create parameters for summary request
		$parameters:=New object:C1471(\
			"model"; This:C1470.model#Null:C1517 ? This:C1470.model : $context.parameters.model; \
			"messages"; [New object:C1471("role"; "user"; "content"; $summaryPrompt)]; \
			"temperature"; 0.3; \
			"max_tokens"; 500\
			)

		// Make API call
		$result:=$chatAPI.completions.create($parameters)

		If ($result.success && ($result.choices.length>0))
			$summary:=$result.choices[0].message.content
			This:C1470._log("Summary generated: "+String:C10(Length:C16($summary))+" chars")
			return $summary
		Else
			LOG EVENT:C667(Into system standard outputs:K38:9; "[SummarizationMiddleware] Failed to generate summary: "+JSON Stringify:C1217($result.error); Error message:K38:2)
			return ""
		End if

	catch
		LOG EVENT:C667(Into system standard outputs:K38:9; "[SummarizationMiddleware] Exception generating summary: "+Last errors:C1799[0].message; Error message:K38:2)
		return ""
	End try

/*
 * Build readable conversation text from messages
 */
Function _buildConversationText($messages : Collection)->$text : Text
	var $message : Object
	var $lines : Collection
	var $role; $content : Text

	$lines:=[]

	For each ($message; $messages)
		$role:=$message.role
		$content:=String:C10($message.content)

		// Format: "Role: Content"
		Case of
			: ($role="user")
				$lines.push("User: "+$content)

			: ($role="assistant")
				$lines.push("Assistant: "+$content)

			: ($role="system")
				$lines.push("System: "+$content)

			: ($role="tool")
				// Include tool responses
				$lines.push("Tool ("+String:C10($message.name)+"): "+$content)

			Else
				$lines.push($role+": "+$content)
		End case
	End for each

	return $lines.join("\n")

/*
 * Get default summary prompt
 */
Function _getDefaultSummaryPrompt()->$prompt : Text
	$prompt:="You are a helpful assistant tasked with summarizing a conversation.\n\n"+\
		"Instructions:\n"+\
		"- Summarize the conversation below, focusing on:\n"+\
		"  * User's main goals and questions\n"+\
		"  * Key information and facts provided\n"+\
		"  * Important decisions or conclusions reached\n"+\
		"  * Current status and any unresolved issues\n"+\
		"- Present the summary as clear, concise bullet points\n"+\
		"- Be factual - do not invent or assume information not in the conversation\n"+\
		"- Focus on continuity - someone reading this summary should be able to continue the conversation naturally\n"+\
		"- Keep the summary brief (2-5 bullet points)\n"

	return $prompt

/*
 * Get summarization statistics
 */
Function getStats()->$stats : Object
	return New object:C1471(\
		"summarizationCount"; This:C1470.summarizationCount; \
		"lastSummarization"; This:C1470.lastSummarization\
		)
