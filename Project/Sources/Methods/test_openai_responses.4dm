//%attributes = {}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

var $modelName:=cs:C1710._TestModels.new($client).chats

// MARK:- basic responses.create
var $result:=$client.responses.create("Explain why 42 is a special number."; {model: $modelName})

If (Asserted:C1132(Bool:C1537($result.success); "Cannot create response : "+JSON Stringify:C1217($result)))
	
	var $response:=$result.response
	If (Asserted:C1132($response#Null:C1517; "responses.create do not return response"))
		
		ASSERT:C1129(Length:C16($response.outputText)>0; "responses.create do not return text")
		ASSERT:C1129(Length:C16($response.id)>0; "response id is missing")
		ASSERT:C1129($response.created_at>0; "response created_at is missing")
		
		// Check status flags (completed or processing)
		ASSERT:C1129($response.isComplete || $response.isProcessing; "response status is invalid: "+$response.status)
		
	End if 
	
End if 


// MARK:- JSON schema response format
var $jsonSchema:=New object:C1471(\
"type"; "object"; \
"properties"; New object:C1471(\
"name"; New object:C1471("type"; "string"); \
"age"; New object:C1471("type"; "integer"); \
"city"; New object:C1471("type"; "string")\
); \
"required"; New collection:C1472("name"; "age"; "city"); \
"additionalProperties"; False:C215\
)

var $params:=cs:C1710.OpenAIResponsesParameters.new()
$params.model:=$modelName
$params.text:=New object:C1471(\
"format"; New object:C1471(\
"type"; "json_schema"; \
"name"; "person_info"; \
"schema"; $jsonSchema\
)\
)

$result:=$client.responses.create("Generate information about a person named John Smith."; $params)

If (Asserted:C1132(Bool:C1537($result.success); "Cannot create response with JSON schema: "+JSON Stringify:C1217($result)))
	
	ASSERT:C1129(Length:C16($result.outputText)>0; "JSON schema response should return text")
	
	var $structuredResponse:=Try(JSON Parse:C1218($result.outputText; Is object:K8:27))
	If (Asserted:C1132($structuredResponse#Null:C1517; "Structured response should be valid JSON"))
		
		ASSERT:C1129(($structuredResponse.name#Null:C1517) && (Value type:C1509($structuredResponse.name)=Is text:K8:3); "Response should contain 'name' as text")
		ASSERT:C1129(($structuredResponse.age#Null:C1517) && (Value type:C1509($structuredResponse.age)=Is real:K8:4); "Response should contain 'age' as real")
		ASSERT:C1129(($structuredResponse.city#Null:C1517) && (Value type:C1509($structuredResponse.city)=Is text:K8:3); "Response should contain 'city' as text")
		
	End if 
	
End if 


// MARK:- parameter serialization test
var $includeParams:=cs:C1710.OpenAIResponsesParameters.new({model: $modelName; include: New collection:C1472("output[0].content[0].annotations")})
var $body:=$includeParams.body()
ASSERT:C1129(($body.include#Null:C1517) && ($body.include.length=1); "include should be serialized when provided")

// MARK:- built-in tool serialization
var $builtInToolParams:=cs:C1710.OpenAIResponsesParameters.new({ \
	model: $modelName; \
	tools: [ \
		{type: "web_search"}; \
		{type: "shell"; environment: { \
			type: "container_auto"; \
			skills: [ \
				{type: "skill_reference"; skill_id: "skill_1"}; \
				{type: "skill_reference"; skill_id: "skill_2"; version: 2} \
			] \
		}} \
	] \
})
var $toolsBody:=$builtInToolParams.body()
If (Asserted:C1132(($toolsBody.tools#Null:C1517) && ($toolsBody.tools.length=2); "built-in tools should be serialized"))
	ASSERT:C1129($toolsBody.tools[0].type="web_search"; "web_search tool type should be preserved")
	ASSERT:C1129($toolsBody.tools[1].type="shell"; "shell tool type should be preserved")
	ASSERT:C1129(($toolsBody.tools[1].environment#Null:C1517) && ($toolsBody.tools[1].environment.type="container_auto"); "shell environment should be preserved")
	ASSERT:C1129(($toolsBody.tools[1].environment.skills#Null:C1517) && ($toolsBody.tools[1].environment.skills.length=2); "shell skills should be preserved")
	ASSERT:C1129($toolsBody.tools[1].environment.skills[1].version=2; "nested skill version should be preserved")
End if

// MARK:- count input tokens
var $countResult:=$client.responses.countInputTokens("Explain why 42 is a special number."; {model: $modelName})
If (Asserted:C1132(Bool:C1537($countResult.success); "Cannot count response input tokens : "+JSON Stringify:C1217($countResult)))
	ASSERT:C1129($countResult.input_tokens>0; "input token count should be positive")
End if

// MARK:- retrieve/update result typing
If (Bool:C1537($result.success))
	var $createdResponse:=$result.response
	If (Asserted:C1132($createdResponse#Null:C1517; "response should be available for retrieve/update checks"))
		var $retrievedResult : cs:C1710.OpenAIResponsesResult:=$client.responses.retrieve($createdResponse.id)
		If (Asserted:C1132(Bool:C1537($retrievedResult.success); "Cannot retrieve stored response : "+JSON Stringify:C1217($retrievedResult)))
			ASSERT:C1129(($retrievedResult.response#Null:C1517) && ($retrievedResult.response.id=$createdResponse.id); "retrieve should return the stored response")
		End if 
		
		var $inputItemsResult:=$client.responses.listInputItems($createdResponse.id)
		var $canListInputItems:=Bool:C1537($inputItemsResult.success)
		If (Not:C34($canListInputItems))
			var $inputItemsError:=$inputItemsResult.errors.first()
			$canListInputItems:=($inputItemsError#Null:C1517) && ($inputItemsError.code="missing_scope")
		End if 
		If (Asserted:C1132($canListInputItems; "Cannot list response input items : "+JSON Stringify:C1217($inputItemsResult)))
			If (Bool:C1537($inputItemsResult.success))
				ASSERT:C1129($inputItemsResult.items.length>0; "input items list should not be empty")
			End if 
		End if 
		
		var $metadata:={test_suite: "responses"; stage: "updated"}
		var $updatedResult : cs:C1710.OpenAIResponsesResult:=$client.responses.update($createdResponse.id; $metadata)
		var $canUpdate:=Bool:C1537($updatedResult.success)
		If (Not:C34($canUpdate))
			var $updateError:=$updatedResult.errors.first()
			$canUpdate:=($updateError#Null:C1517) && ($updateError.code="missing_scope")
		End if 
		If (Asserted:C1132($canUpdate; "Cannot update stored response : "+JSON Stringify:C1217($updatedResult)))
			If (Not:C34(Bool:C1537($updatedResult.success)))
				return 
			End if 
			ASSERT:C1129(($updatedResult.response#Null:C1517) && ($updatedResult.response.metadata#Null:C1517); "update should return a response object")
			ASSERT:C1129($updatedResult.response.metadata.stage="updated"; "updated response metadata should be returned")
		End if 
	End if 
End if
