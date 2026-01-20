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
$providers._providers:={providers: $config}

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

// MARK:- Get list of all provider names
var $names : Collection:=$providers.list()
ASSERT:C1129($names.includes("test_openai"); "Should contain test_openai")
ASSERT:C1129($names.includes("test_local"); "Should contain test_local")
ASSERT:C1129($names.length=2; "Should have exactly 2 providers")

// MARK:- Empty list when no providers
var $emptyProviders:=cs:C1710.OpenAIProviders.new()
$emptyProviders._providers:={providers: {}}
var $emptyNames : Collection:=$emptyProviders.list()
ASSERT:C1129($emptyNames.length=0; "Should return empty collection")

// MARK:- List reflects added providers
$providers._providers.providers["newProvider"]:={baseURL: "https :   //new.api.com/v1"}
var $updatedNames : Collection:=$providers.list()
ASSERT:C1129($updatedNames.includes("newProvider"); "Should include newly added provider")
ASSERT:C1129($updatedNames.length=3; "Should now have 3 providers")

// MARK:- Get provider config by name
var $configRetrieved : Object:=$providers.get("test_openai")
ASSERT:C1129($configRetrieved#Null:C1517; "Should return config object")
ASSERT:C1129($configRetrieved.baseURL="https://api.openai.com/v1"; "Should have correct baseURL")

// MARK:- Returns null for unknown provider
var $unknown : Object:=$providers.get("nonexistent")
ASSERT:C1129($unknown=Null:C1517; "Should return null for unknown provider")

// MARK:- Config includes all fields
var $fullConfig:={baseURL: "https://api.test.com/v1"; apiKey: "key123"; organization: "org-456"; project: "proj-789"}
$providers._providers.providers["fullProvider"]:=$fullConfig
var $retrieved : Object:=$providers.get("fullProvider")
ASSERT:C1129($retrieved.baseURL=$fullConfig.baseURL; "baseURL should match")
ASSERT:C1129($retrieved.apiKey=$fullConfig.apiKey; "apiKey should match")
ASSERT:C1129($retrieved.organization=$fullConfig.organization; "organization should match")
ASSERT:C1129($retrieved.project=$fullConfig.project; "project should match")

// MARK:- Organization included in resolved config
var $configWithOrg:={baseURL: "https://api.openai.com/v1"; apiKey: "key"; organization: "org-123"}
$providers._providers.providers["orgProvider"]:=$configWithOrg
$resolved:=$providers._resolveModel("orgProvider:gpt-4o")
ASSERT:C1129($resolved.success; "Should resolve orgProvider")
ASSERT:C1129($resolved.organization="org-123"; "Organization should be included in resolved config")

// MARK:- Project included in resolved config
var $configWithProject:={baseURL: "https://api.openai.com/v1"; apiKey: "key"; project: "proj-456"}
$providers._providers.providers["projectProvider"]:=$configWithProject
$resolved:=$providers._resolveModel("projectProvider:gpt-4o")
ASSERT:C1129($resolved.success; "Should resolve projectProvider")
ASSERT:C1129($resolved.project="proj-456"; "Project should be included in resolved config")

