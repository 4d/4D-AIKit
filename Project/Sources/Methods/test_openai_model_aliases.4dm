//%attributes = {"invisible":true}
// Test model alias resolution

// Test API key value
var $testApiKey:="test-api-key-12345"

// Create test configuration (in-memory, no file needed)
var $config:={\
test_openai: {baseURL: "https://api.openai.com/v1"; apiKey: $testApiKey}; \
test_local: {baseURL: "http://localhost:11434/v1"}\
}

// Test the resolver using OpenAIProviders with injected test config
var $providers:=cs:C1710.OpenAIProviders.new()
// Inject test configuration by directly setting _providers attribute
$providers._providers:=$config

// MARK:- Test simple provider resolution
var $resolved:=$providers._resolveModel("test_openai:gpt-4o")
If (Asserted:C1132($resolved.success; "Failed to resolve test_openai:gpt-4o"))
	ASSERT:C1129($resolved.baseURL="https://api.openai.com/v1"; "Wrong baseURL")
	ASSERT:C1129($resolved.model="gpt-4o"; "Wrong model name")
	ASSERT:C1129($resolved.apiKey=$testApiKey; "API key should be resolved from env")
End if 

// MARK:- Test local provider (no apiKey)
$resolved:=$providers._resolveModel("test_local:llama3")
If (Asserted:C1132($resolved.success; "Failed to resolve test_local:llama3"))
	ASSERT:C1129($resolved.baseURL="http://localhost:11434/v1"; "Wrong baseURL for local")
	ASSERT:C1129($resolved.model="llama3"; "Wrong model name for local")
	ASSERT:C1129(Length:C16($resolved.apiKey)=0; "Local should have no API key")
End if 

// MARK:- Test model without prefix (should return success=false with original model)
$resolved:=$providers._resolveModel("gpt-4o")
If (Asserted:C1132(Not:C34($resolved.success); "Model without prefix should return success=false"))
	ASSERT:C1129($resolved.model="gpt-4o"; "Model name should remain unchanged")
	ASSERT:C1129(Length:C16($resolved.baseURL)=0; "No baseURL for unprefixed model")
End if 

// MARK:- Test non-existent provider
$resolved:=$providers._resolveModel("nonexistent:model")
ASSERT:C1129(Not:C34($resolved.success); "Non-existent provider should fail")
ASSERT:C1129($resolved.error#Null:C1517; "Should have error message")
