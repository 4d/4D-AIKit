/*
 * OpenAITokenCounter - Utility for estimating token counts
 *
 * Provides multiple strategies for counting tokens in text:
 * 1. Character-based estimation (~4 chars per token for English)
 * 2. Word-based estimation (~0.75 tokens per word)
 * 3. Custom formula for more accurate counting
 *
 * Note: These are approximations. For exact counts, use OpenAI's tiktoken
 * or check the 'usage' field in API responses.
 *
 * Usage:
 *   $counter:=OpenAITokenCounter.new()
 *   $tokens:=$counter.countText("Hello world")
 *   $tokens:=$counter.countMessages($messages)
 */

Class constructor($config : Object)
	This:C1470.config:=($config#Null:C1517) ? $config : {}

	// Default strategy: "chars" (fastest, ~75% accurate)
	// Other options: "words", "custom"
	This:C1470.strategy:=This:C1470.config.strategy#Null:C1517 ? This:C1470.config.strategy : "chars"

	// Custom counting formula (if strategy="custom")
	This:C1470.customCounter:=This:C1470.config.customCounter  // Formula($1.text)->tokens

	// Characters per token (default: 4 for English, 2-3 for code)
	This:C1470.charsPerToken:=This:C1470.config.charsPerToken#Null:C1517 ? This:C1470.config.charsPerToken : 4

	// Words per token (default: ~0.75)
	This:C1470.tokensPerWord:=This:C1470.config.tokensPerWord#Null:C1517 ? This:C1470.config.tokensPerWord : 0.75

/*
 * Count tokens in text
 *
 * @param $text Text - Text to count
 * @return Integer - Estimated token count
 */
Function countText($text : Text)->$tokens : Integer
	If ($text="")
		return 0
	End if

	Case of
		: (This:C1470.strategy="chars")
			return This:C1470._countByChars($text)

		: (This:C1470.strategy="words")
			return This:C1470._countByWords($text)

		: (This:C1470.strategy="custom")
			If (This:C1470.customCounter#Null:C1517)
				return This:C1470.customCounter.call(New object:C1471("text"; $text))
			Else
				// Fallback to chars
				return This:C1470._countByChars($text)
			End if

		Else
			// Default to chars
			return This:C1470._countByChars($text)
	End case

/*
 * Count tokens in a single message
 *
 * @param $message Object - OpenAIMessage or message object
 * @return Integer - Estimated token count
 */
Function countMessage($message : Object)->$tokens : Integer
	var $content : Text
	var $toolCallTokens : Integer

	If ($message=Null:C1517)
		return 0
	End if

	// Base tokens for message structure (~4 tokens per message)
	$tokens:=4

	// Count content
	If ($message.content#Null:C1517)
		$content:=String:C10($message.content)
		$tokens:=$tokens+This:C1470.countText($content)
	End if

	// Count role (~1 token)
	If ($message.role#Null:C1517)
		$tokens:=$tokens+1
	End if

	// Count tool calls (if present)
	If ($message.tool_calls#Null:C1517)
		$toolCallTokens:=This:C1470._countToolCalls($message.tool_calls)
		$tokens:=$tokens+$toolCallTokens
	End if

	// Count tool call response
	If ($message.tool_call_id#Null:C1517)
		$tokens:=$tokens+1  // tool_call_id
	End if

	// Count name (if present)
	If ($message.name#Null:C1517)
		$tokens:=$tokens+1
	End if

	return $tokens

/*
 * Count tokens in collection of messages
 *
 * @param $messages Collection - Collection of message objects
 * @return Integer - Total estimated token count
 */
Function countMessages($messages : Collection)->$tokens : Integer
	var $message : Object

	$tokens:=0

	If ($messages=Null:C1517)
		return 0
	End if

	For each ($message; $messages)
		$tokens:=$tokens+This:C1470.countMessage($message)
	End for each

	// Add a few tokens for the system message overhead
	If ($messages.length>0)
		$tokens:=$tokens+3  // priming tokens
	End if

	return $tokens

/*
 * Count tokens by character length
 *
 * @param $text Text
 * @return Integer - Estimated tokens
 */
Function _countByChars($text : Text)->$tokens : Integer
	return Length:C16($text)\This:C1470.charsPerToken

/*
 * Count tokens by word count
 *
 * @param $text Text
 * @return Integer - Estimated tokens
 */
Function _countByWords($text : Text)->$tokens : Integer
	var $wordCount : Integer

	// Simple word count: split by spaces
	$wordCount:=Num:C11(Split string:C1554($text; " "; sk ignore empty strings:K86:1).length)

	return Round:C94($wordCount*This:C1470.tokensPerWord; 0)

/*
 * Count tokens in tool calls
 *
 * @param $toolCalls Collection - Collection of tool call objects
 * @return Integer - Estimated tokens
 */
Function _countToolCalls($toolCalls : Collection)->$tokens : Integer
	var $toolCall : Object

	$tokens:=0

	For each ($toolCall; $toolCalls)
		// Function name
		If ($toolCall.function#Null:C1517)
			If ($toolCall.function.name#Null:C1517)
				$tokens:=$tokens+2  // function name
			End if

			// Function arguments (JSON string)
			If ($toolCall.function.arguments#Null:C1517)
				$tokens:=$tokens+This:C1470.countText(String:C10($toolCall.function.arguments))
			End if
		End if

		// Tool call ID
		If ($toolCall.id#Null:C1517)
			$tokens:=$tokens+1
		End if

		// Base overhead for tool call structure
		$tokens:=$tokens+3
	End for each

	return $tokens

/*
 * Get approximate cost for token count
 *
 * @param $tokens Integer - Token count
 * @param $model Text - Model name (default: gpt-3.5-turbo)
 * @param $type Text - "input" or "output"
 * @return Real - Cost in USD
 */
Function estimateCost($tokens : Integer; $model : Text; $type : Text)->$cost : Real
	// Prices per 1K tokens (as of 2024)
	var $pricesPer1K : Object

	If ($model="")
		$model:="gpt-3.5-turbo"
	End if

	If ($type="")
		$type:="input"
	End if

	// Simplified pricing (update with actual prices)
	$pricesPer1K:={\
		"gpt-3.5-turbo": {input: 0.0005; output: 0.0015}; \
		"gpt-4": {input: 0.03; output: 0.06}; \
		"gpt-4-turbo": {input: 0.01; output: 0.03}\
		}

	If ($pricesPer1K[$model]=Null:C1517)
		return 0  // Unknown model
	End if

	$cost:=($tokens/1000)*$pricesPer1K[$model][$type]

	return $cost
