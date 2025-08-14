property _responsesAPI : cs:C1710.OpenAIResponsesAPI
property instructions : Text
property parameters : cs:C1710.OpenAIResponsesParameters
property conversationHistory : Collection

Class constructor($responsesAPI : cs:C1710.OpenAIResponsesAPI; $instructions : Text; $parameters : cs:C1710.OpenAIResponsesParameters)
	This:C1470._responsesAPI:=$responsesAPI
	This:C1470.instructions:=$instructions || ""
	This:C1470.parameters:=$parameters || cs:C1710.OpenAIResponsesParameters.new()
	This:C1470.conversationHistory:=[]
	
	// Set default instructions if provided
	If (Length:C16(This:C1470.instructions)>0)
		This:C1470.parameters.instructions:=This:C1470.instructions
	End if 
	
/*
* Send a message and get a response
 */
Function send($input : Variant) : cs:C1710.OpenAIResponsesResult
	
	// Use previous response ID if we have conversation history
	If (This:C1470.conversationHistory.length>0)
		var $lastResponse : Object:=This:C1470.conversationHistory.last()
		If ($lastResponse.success) && ($lastResponse.response#Null:C1517)
			This:C1470.parameters.previous_response_id:=$lastResponse.response.id
		End if 
	End if 
	
	// Create the response
	var $result : cs:C1710.OpenAIResponsesResult
	$result:=This:C1470._responsesAPI.create($input; This:C1470.parameters)
	
	// Add to conversation history
	This:C1470.conversationHistory.push({input: $input; result: $result; timestamp: Timestamp:C1445})
	
	return $result
	
/*
* Send a message and return just the text output
 */
Function ask($input : Variant) : Text
	var $result : cs:C1710.OpenAIResponsesResult
	$result:=This:C1470.send($input)
	
	If ($result.success)
		return $result.output_text
	End if 
	
	return ""
	
/*
* Clear conversation history
 */
Function reset()
	This:C1470.conversationHistory:=[]
	This:C1470.parameters.previous_response_id:=""
	
/*
* Get the last response
 */
Function get lastResponse : cs:C1710.OpenAIResponsesResult
	If (This:C1470.conversationHistory.length>0)
		var $lastEntry : Object:=This:C1470.conversationHistory.last()
		return $lastEntry.result
	End if 
	
	return Null:C1517
	
/*
* Get conversation summary
 */
Function get summary : Object
	var $summary : Object:=New object:C1471
	$summary.messageCount:=This:C1470.conversationHistory.length
	$summary.totalTokens:=0
	$summary.totalCost:=0
	var $entry : Object
	For each ($entry; This:C1470.conversationHistory)
		If ($entry.result.success) && ($entry.result.response#Null:C1517) && ($entry.result.response.usage#Null:C1517)
			$summary.totalTokens:=$summary.totalTokens+$entry.result.response.usage.total_tokens
		End if 
	End for each 
	
	return $summary
	