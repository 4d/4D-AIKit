//%attributes = {"invisible":true}
// Test model alias resolution

var $tempFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2)
var $configFile:=$tempFolder.file("test-ai-providers.json")

// Set up test environment variable
var $testApiKey:="test-api-key-12345"
cs:C1710._Env.me["TEST_OPENAI_API_KEY"]:=$testApiKey

// Create test configuration
var $config:={\
providers: {\
test_openai: {\
baseURL: "https://api.openai.com/v1"; \
apiKeyEnv: "TEST_OPENAI_API_KEY"\
}; \
test_local: {\
baseURL: "http://localhost:11434/v1"\
}; \
test_custom: {\
models: {\
chat: {\
baseURL: "https://api.openai.com/v1"; \
apiKeyEnv: "TEST_OPENAI_API_KEY"; \
modelName: "gpt-4o-mini"\
}; \
embeddings: {\
baseURL: "https://api.openai.com/v1"; \
apiKeyEnv: "TEST_OPENAI_API_KEY"; \
modelName: "text-embedding-3-small"\
}\
}\
}\
}\
}

$configFile.setText(JSON Stringify:C1217($config))

// Test the resolver
var $client:=cs:C1710.OpenAI.new()
$client.providersList:=[cs:C1710.OpenAIProviders.new($configFile)]

// MARK:- Test simple provider resolution
var $resolved:=$client.resolveModel("test_openai:gpt-4o")
If (Asserted:C1132($resolved.success; "Failed to resolve test_openai:gpt-4o"))
	ASSERT:C1129($resolved.baseURL="https://api.openai.com/v1"; "Wrong baseURL")
	ASSERT:C1129($resolved.model="gpt-4o"; "Wrong model name")
	ASSERT:C1129($resolved.apiKey=$testApiKey; "API key should be resolved from env")
End if 

// MARK:- Test local provider (no apiKey)
$resolved:=$client.resolveModel("test_local:llama3")
If (Asserted:C1132($resolved.success; "Failed to resolve test_local:llama3"))
	ASSERT:C1129($resolved.baseURL="http://localhost:11434/v1"; "Wrong baseURL for local")
	ASSERT:C1129($resolved.model="llama3"; "Wrong model name for local")
	ASSERT:C1129(Length:C16($resolved.apiKey)=0; "Local should have no API key")
End if 

// MARK:- Test custom model alias with modelName mapping
$resolved:=$client.resolveModel("test_custom:chat")
If (Asserted:C1132($resolved.success; "Failed to resolve test_custom:chat"))
	ASSERT:C1129($resolved.baseURL="https://api.openai.com/v1"; "Wrong baseURL for custom")
	ASSERT:C1129($resolved.model="gpt-4o-mini"; "Model should be mapped to gpt-4o-mini")
	ASSERT:C1129($resolved.apiKey=$testApiKey; "Custom model should have API key from env")
End if 

$resolved:=$client.resolveModel("test_custom:embeddings")
If (Asserted:C1132($resolved.success; "Failed to resolve test_custom:embeddings"))
	ASSERT:C1129($resolved.model="text-embedding-3-small"; "Embeddings model should be mapped")
End if 

// MARK:- Test model without prefix (should failed with empty config)
$resolved:=$client.resolveModel("gpt-4o")
If (Asserted:C1132(Not:C34($resolved.success); "Model without prefix should failed"))
	ASSERT:C1129($resolved.model="gpt-4o"; "Model name should remain unchanged")
	ASSERT:C1129(Length:C16($resolved.baseURL)=0; "No baseURL for unprefixed model")
End if 

// MARK:- Test non-existent provider
$resolved:=$client.resolveModel("nonexistent:model")
ASSERT:C1129(Not:C34($resolved.success); "Non-existent provider should fail")
ASSERT:C1129($resolved.error#Null:C1517; "Should have error message")

// Clean up
$configFile.delete()
