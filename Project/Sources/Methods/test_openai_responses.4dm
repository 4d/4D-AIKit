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

