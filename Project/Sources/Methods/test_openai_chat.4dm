//%attributes = {}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// MARK:- chat
var $modelName:=cs:C1710._TestModels.new($client).chats
var $messages:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant."})]
$messages.push({role: "user"; content: "Could you explain me why 42 is a special number"})
var $result:=$client.chat.completions.create($messages; {model: $modelName})

If (Asserted:C1132(Bool:C1537($result.success); "Cannot complete chat : "+JSON Stringify:C1217($result)))
	
	// Test usage object exists
	If (Asserted:C1132($result.usage#Null:C1517; "chat must return usage object"))
		ASSERT:C1129($result.usage.total_tokens#Null:C1517; "usage must have total_tokens")
	End if 
	
	If (Asserted:C1132($result.choice#Null:C1517; "chat do not return a choice"))
		
		If (Asserted:C1132($result.choice.message#Null:C1517; "chat do not return a message"))
			
			ASSERT:C1129(Length:C16($result.choice.message.text)>0; "chat do not return a message text")
			
			$messages.push($result.choice.message)
			$messages.push({role: "user"; content: "and could you decompose this number"})
			
			$result:=$client.chat.completions.create($messages; {model: $modelName})
			
			If ((Asserted:C1132($result.choice#Null:C1517)) && (Asserted:C1132($result.choice.message#Null:C1517)))
				
				ASSERT:C1129(Length:C16($result.choice.message.text)>0; "chat do not return a message text")
				
			End if 
			
		End if 
		
	End if 
	
End if 

// MARK:- response_format tests

// Test JSON response format
var $jsonMessages:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant that always responds in JSON format."})]
$jsonMessages.push({role: "user"; content: "Give me information about the number 42 in JSON format with keys 'significance' and 'facts'."})

var $jsonParams:=cs:C1710.OpenAIChatCompletionsParameters.new(New object:C1471("model"; $modelName; "response_format"; New object:C1471("type"; "json_object")))
$result:=$client.chat.completions.create($jsonMessages; $jsonParams)

If (Asserted:C1132(Bool:C1537($result.success); "Cannot complete chat with JSON response format: "+JSON Stringify:C1217($result)))
	
	If (Asserted:C1132($result.choice#Null:C1517; "JSON chat do not return a choice"))
		
		If (Asserted:C1132($result.choice.message#Null:C1517; "JSON chat do not return a message"))
			
			ASSERT:C1129(Length:C16($result.choice.message.text)>0; "JSON chat do not return a message text")
			
			// Try to parse the response as JSON to verify it's valid JSON
			var $jsonResponse:=Try(JSON Parse:C1218($result.choice.message.text; Is object:K8:27))
			ASSERT:C1129($jsonResponse#Null:C1517; "Response should be valid JSON")  // XXX: add last errors
			
		End if 
		
	End if 
	
End if 

// Test structured JSON schema response format
var $schemaMessages:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant."})]
$schemaMessages.push({role: "user"; content: "Generate information about a person named John Smith."})

var $jsonSchema:=New object:C1471(\
"type"; "object"; \
"properties"; New object:C1471(\
"name"; New object:C1471("type"; "string"); \
"age"; New object:C1471("type"; "integer"); \
"occupation"; New object:C1471("type"; "string"); \
"city"; New object:C1471("type"; "string")\
); \
"required"; New collection:C1472("name"; "age"; "occupation"; "city"); \
"additionalProperties"; False:C215\
)

var $schemaParams:=cs:C1710.OpenAIChatCompletionsParameters.new(New object:C1471(\
"model"; $modelName; \
"response_format"; New object:C1471(\
"type"; "json_schema"; \
"json_schema"; New object:C1471(\
"name"; "person_info"; \
"description"; "Information about a person"; \
"schema"; $jsonSchema; \
"strict"; True:C214\
)\
)\
))

$result:=$client.chat.completions.create($schemaMessages; $schemaParams)

If (Asserted:C1132(Bool:C1537($result.success); "Cannot complete chat with JSON schema response format: "+JSON Stringify:C1217($result)))
	
	If (Asserted:C1132($result.choice#Null:C1517; "JSON schema chat do not return a choice"))
		
		If (Asserted:C1132($result.choice.message#Null:C1517; "JSON schema chat do not return a message"))
			
			ASSERT:C1129(Length:C16($result.choice.message.text)>0; "JSON schema chat do not return a message text")
			
			// Parse and validate the structured response
			var $structuredResponse:=Try(JSON Parse:C1218($result.choice.message.text; Is object:K8:27))
			If (Asserted:C1132($structuredResponse#Null:C1517; "Structured response should be valid JSON"))  // add Last errors?
				
				// Verify required fields are present
				ASSERT:C1129(($structuredResponse.name#Null:C1517) && (Value type:C1509($structuredResponse.name)=Is text:K8:3); "Response should contain 'name' as text")
				ASSERT:C1129(($structuredResponse.age#Null:C1517) && (Value type:C1509($structuredResponse.age)=Is real:K8:4); "Response should contain 'age' as real(no integer storage in 4D)")
				ASSERT:C1129(($structuredResponse.occupation#Null:C1517) && (Value type:C1509($structuredResponse.occupation)=Is text:K8:3); "Response should contain 'occupation' as text")
				ASSERT:C1129(($structuredResponse.city#Null:C1517) && (Value type:C1509($structuredResponse.city)=Is text:K8:3); "Response should contain 'city' as text")
				
			End if 
			
		End if 
		
	End if 
	
End if 

// Test text response format (default behavior)
var $textMessages:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant."})]
$textMessages.push({role: "user"; content: "Explain the importance of the number 42 in a brief paragraph."})

var $textParams:=cs:C1710.OpenAIChatCompletionsParameters.new(New object:C1471("model"; $modelName; "response_format"; New object:C1471("type"; "text")))
$result:=$client.chat.completions.create($textMessages; $textParams)

If (Asserted:C1132(Bool:C1537($result.success); "Cannot complete chat with text response format: "+JSON Stringify:C1217($result)))
	
	If (Asserted:C1132($result.choice#Null:C1517; "Text chat do not return a choice"))
		
		If (Asserted:C1132($result.choice.message#Null:C1517; "Text chat do not return a message"))
			
			ASSERT:C1129(Length:C16($result.choice.message.text)>0; "Text chat do not return a message text")
			
			// For text format, we just ensure we get a meaningful response
			ASSERT:C1129(Length:C16($result.choice.message.text)>10; "Text response should be substantial")
			
		End if 
		
	End if 
	
End if 

// MARK:- top_p parameter tests

// Test top_p parameter is included when set to a valid value
var $topPMessages:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant."})]
$topPMessages.push({role: "user"; content: "What is the capital of France?"})

var $topPParams:=cs:C1710.OpenAIChatCompletionsParameters.new(New object:C1471("model"; $modelName; "top_p"; 0.5))
$result:=$client.chat.completions.create($topPMessages; $topPParams)

If (Asserted:C1132(Bool:C1537($result.success); "Cannot complete chat with top_p parameter: "+JSON Stringify:C1217($result)))
	
	If (Asserted:C1132($result.choice#Null:C1517; "top_p chat do not return a choice"))
		
		If (Asserted:C1132($result.choice.message#Null:C1517; "top_p chat do not return a message"))
			
			ASSERT:C1129(Length:C16($result.choice.message.text)>0; "top_p chat do not return a message text")
			
		End if 
		
	End if 
	
End if 

// Test that top_p=0 is not sent to server (verify by checking body construction)
var $zeroTopPParams:=cs:C1710.OpenAIChatCompletionsParameters.new(New object:C1471("model"; $modelName; "top_p"; 0))
var $body:=$zeroTopPParams.body()
ASSERT:C1129($body.top_p=Null:C1517; "top_p should not be in body when set to 0")