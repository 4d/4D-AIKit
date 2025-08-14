//%attributes = {}

var $client : cs:C1710.OpenAI
$client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// Test basic response creation
var $parameters : cs:C1710.OpenAIResponsesParameters
$parameters:=cs:C1710.OpenAIResponsesParameters.new()
$parameters.model:="gpt-4o-mini"
$parameters.instructions:="You are a helpful assistant."
$parameters.max_output_tokens:=100

var $result : cs:C1710.OpenAIResponsesResult
$result:=$client.responses.create("Hello, how are you?"; $parameters)

If (Asserted:C1132($result.success; "Response creation failed: "+JSON Stringify:C1217($result.errors)))
	var $response : cs:C1710.OpenAIResponse
	$response:=$result.response
	
	If (Asserted:C1132($response#Null:C1517; "Response object should not be null"))
		ASSERT:C1129(Length:C16($response.id)>0; "Response should have an ID")
		ASSERT:C1129($response.object="response"; "Object type should be 'response'")
		ASSERT:C1129(Length:C16($response.model)>0; "Response should have a model")
		ASSERT:C1129(Length:C16($response.output_text)>0; "Response should have output text")
		
		// Log the response
		TRACE:C157
	End if 
End if 

// Test with previous response ID (multi-turn conversation)
If ($result.success) && ($result.response#Null:C1517)
	var $secondParameters : cs:C1710.OpenAIResponsesParameters
	$secondParameters:=cs:C1710.OpenAIResponsesParameters.new()
	$secondParameters.model:="gpt-4o-mini"
	$secondParameters.previous_response_id:=$result.response.id
	$secondParameters.max_output_tokens:=100
	
	var $secondResult : cs:C1710.OpenAIResponsesResult
	$secondResult:=$client.responses.create("What was my previous question?"; $secondParameters)
	
	If (Asserted:C1132($secondResult.success; "Second response creation failed: "+JSON Stringify:C1217($secondResult.errors)))
		ASSERT:C1129(Length:C16($secondResult.output_text)>0; "Second response should have output text")
		TRACE:C157
	End if 
End if
