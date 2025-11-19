//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if

// MARK:- Test basic response creation
var $modelName:=cs:C1710._TestModels.new($client).chats

// Test with simple string input
var $result:=$client.responses.create("What is 2+2?"; {model: $modelName})

If (Asserted:C1132(Bool:C1537($result.success); "Cannot create response: "+JSON Stringify:C1217($result)))

	ASSERT:C1129($result.output#Null:C1517; "Response did not return output")
	ASSERT:C1129(Length:C16(String:C10($result.output))>0; "Response output is empty")
	ASSERT:C1129(Length:C16($result.id)>0; "Response did not return an ID")
	ASSERT:C1129(Length:C16($result.model)>0; "Response did not return model name")

End if

// MARK:- Test with message objects
var $messages:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful math tutor."})]
$messages.push({role: "user"; content: "Explain why 42 is significant"})

var $params:=cs:C1710.OpenAIResponsesParameters.new()
$params.model:=$modelName
$params.temperature:=0.7

$result:=$client.responses.create($messages; $params)

If (Asserted:C1132(Bool:C1537($result.success); "Cannot create response with messages: "+JSON Stringify:C1217($result)))

	ASSERT:C1129($result.output#Null:C1517; "Response with messages did not return output")
	ASSERT:C1129(Length:C16(String:C10($result.output))>0; "Response output with messages is empty")

End if

// MARK:- Test with instructions
var $paramsWithInstructions:=cs:C1710.OpenAIResponsesParameters.new()
$paramsWithInstructions.model:=$modelName
$paramsWithInstructions.instructions:="Be concise and answer in one sentence"

$result:=$client.responses.create("What is the capital of France?"; $paramsWithInstructions)

If (Asserted:C1132(Bool:C1537($result.success); "Cannot create response with instructions: "+JSON Stringify:C1217($result)))

	ASSERT:C1129($result.output#Null:C1517; "Response with instructions did not return output")
	ASSERT:C1129(Length:C16(String:C10($result.output))>0; "Response output with instructions is empty")

End if

// MARK:- Test with response format
var $formatParams:=cs:C1710.OpenAIResponsesParameters.new()
$formatParams.model:=$modelName
$formatParams.response_format:={type: "json_object"}
$formatParams.instructions:="Respond with JSON containing a 'capital' field"

$result:=$client.responses.create("What is the capital of France?"; $formatParams)

If (Asserted:C1132(Bool:C1537($result.success); "Cannot create response with format: "+JSON Stringify:C1217($result)))

	If (Asserted:C1132($result.output#Null:C1517; "Response with format did not return output"))

		// Try to parse as JSON
		var $jsonOutput:=Try(JSON Parse:C1218(String:C10($result.output); Is object:K8:27))
		ASSERT:C1129($jsonOutput#Null:C1517; "Response output should be valid JSON")

	End if

End if

// MARK:- Test with max_tokens
var $tokensParams:=cs:C1710.OpenAIResponsesParameters.new()
$tokensParams.model:=$modelName
$tokensParams.max_tokens:=50

$result:=$client.responses.create("Tell me a very long story"; $tokensParams)

If (Asserted:C1132(Bool:C1537($result.success); "Cannot create response with max_tokens: "+JSON Stringify:C1217($result)))

	ASSERT:C1129($result.output#Null:C1517; "Response with max_tokens did not return output")

End if

// MARK:- Test error handling
var $invalidParams:=cs:C1710.OpenAIResponsesParameters.new()
$invalidParams.model:="fake-model-that-does-not-exist"

$result:=$client.responses.create("Test"; $invalidParams)

ASSERT:C1129(Not:C34($result.success); "Should fail with invalid model")
ASSERT:C1129($result.errors.length>0; "Should return error object")

// MARK:- Test with store parameter
var $storeParams:=cs:C1710.OpenAIResponsesParameters.new()
$storeParams.model:=$modelName
$storeParams.store:=True:C214
$storeParams.metadata:={test: "test_openai_responses"}

$result:=$client.responses.create("Hello, store this response"; $storeParams)

If (Asserted:C1132(Bool:C1537($result.success); "Cannot create stored response: "+JSON Stringify:C1217($result)))

	ASSERT:C1129(Length:C16($result.id)>0; "Stored response should have an ID")

	// Test retrieve
	var $retrievedResult:=$client.responses.retrieve($result.id)

	If (Asserted:C1132(Bool:C1537($retrievedResult.success); "Cannot retrieve response: "+JSON Stringify:C1217($retrievedResult)))

		ASSERT:C1129($retrievedResult.id=$result.id; "Retrieved response ID should match")

		// Test delete
		var $deleteResult:=$client.responses.delete($result.id)
		ASSERT:C1129(Bool:C1537($deleteResult.success); "Cannot delete response: "+JSON Stringify:C1217($deleteResult))

	End if

End if
