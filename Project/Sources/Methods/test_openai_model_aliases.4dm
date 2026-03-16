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
var $resolved:=$providers._resolveModel("test_openai:gpt-5.1")
If (Asserted:C1132($resolved.success; "Failed to resolve test_openai:gpt-5.1"))
	ASSERT:C1129($resolved.baseURL="https://api.openai.com/v1"; "Wrong baseURL")
	ASSERT:C1129($resolved.model="gpt-5.1"; "Wrong model name")
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
$resolved:=$providers._resolveModel("gpt-5.1")
If (Asserted:C1132(Not:C34($resolved.success); "Model without prefix should return success=false"))
	ASSERT:C1129($resolved.model="gpt-5.1"; "Model name should remain unchanged")
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
$resolved:=$providers._resolveModel("orgProvider:gpt-5.1")
ASSERT:C1129($resolved.success; "Should resolve orgProvider")
ASSERT:C1129($resolved.organization="org-123"; "Organization should be included in resolved config")

// MARK:- Project included in resolved config
var $configWithProject:={baseURL: "https://api.openai.com/v1"; apiKey: "key"; project: "proj-456"}
$providers._providers.providers["projectProvider"]:=$configWithProject
$resolved:=$providers._resolveModel("projectProvider:gpt-5.1")
ASSERT:C1129($resolved.success; "Should resolve projectProvider")
ASSERT:C1129($resolved.project="proj-456"; "Project should be included in resolved config")

// ============================================================
// MARK:- Model alias tests (:modelAlias syntax)
// ============================================================

// Inject test models configuration
$providers._providers.models:={\
myGPT: {provider: "test_openai"; model: "gpt-4o"}; \
myLocal: {provider: "test_local"; model: "llama3.2"}; \
myEmbedding: {provider: "test_openai"; model: "text-embedding-3-small"; capabilities: {supportsEmbedding: True:C214}}; \
noProvider: {model: "some-model"}; \
badProvider: {provider: "nonexistent"; model: "some-model"}\
}

// MARK:- Resolve model alias
$resolved:=$providers._resolveModel(":myGPT")
If (Asserted:C1132($resolved.success; "Failed to resolve :myGPT"))
	ASSERT:C1129($resolved.baseURL="https://api.openai.com/v1"; "Wrong baseURL for model alias")
	ASSERT:C1129($resolved.model="gpt-4o"; "Wrong model for alias, expected gpt-4o")
	ASSERT:C1129($resolved.apiKey=$testApiKey; "API key should come from provider")
End if 

// MARK:- Resolve model alias with local provider (no apiKey)
$resolved:=$providers._resolveModel(":myLocal")
If (Asserted:C1132($resolved.success; "Failed to resolve :myLocal"))
	ASSERT:C1129($resolved.baseURL="http://localhost:11434/v1"; "Wrong baseURL for local model alias")
	ASSERT:C1129($resolved.model="llama3.2"; "Wrong model for local alias")
	ASSERT:C1129(Length:C16($resolved.apiKey)=0; "Local model alias should have no API key")
End if 

// MARK:- Model alias inherits organization & project from provider
$providers._providers.providers["fullProvider2"]:={baseURL: "https://api.openai.com/v1"; apiKey: "key"; organization: "org-abc"; project: "proj-xyz"}
$providers._providers.models["myFull"]:={provider: "fullProvider2"; model: "gpt-5.1"}
$resolved:=$providers._resolveModel(":myFull")
If (Asserted:C1132($resolved.success; "Failed to resolve :myFull"))
	ASSERT:C1129($resolved.organization="org-abc"; "Organization should be inherited from provider")
	ASSERT:C1129($resolved.project="proj-xyz"; "Project should be inherited from provider")
End if 

// MARK:- Model alias with no provider defined
$resolved:=$providers._resolveModel(":noProvider")
ASSERT:C1129(Not:C34($resolved.success); "Model alias without provider should fail")
ASSERT:C1129($resolved.error#Null:C1517; "Should have error message for missing provider")

// MARK:- Model alias referencing non-existent provider
$resolved:=$providers._resolveModel(":badProvider")
ASSERT:C1129(Not:C34($resolved.success); "Model alias with unknown provider should fail")
ASSERT:C1129($resolved.error#Null:C1517; "Should have error message for unknown provider")

// MARK:- Non-existent model alias
$resolved:=$providers._resolveModel(":doesNotExist")
ASSERT:C1129(Not:C34($resolved.success); "Non-existent model alias should fail")
ASSERT:C1129($resolved.error#Null:C1517; "Should have error for non-existent alias")

// MARK:- Models list
var $models : Collection:=$providers.models()
ASSERT:C1129($models.length=(5+1); "Should have "+String:C10((5+1))+" model aliases")
var $myGPT:=$models.query("name = :1"; "myGPT")
ASSERT:C1129($myGPT.length=1; "Should find myGPT in models list")
ASSERT:C1129($myGPT[0].provider="test_openai"; "myGPT provider should be test_openai")
ASSERT:C1129($myGPT[0].model="gpt-4o"; "myGPT model should be gpt-4o")

// MARK:- Models list includes capabilities
var $myEmbed:=$models.query("name = :1"; "myEmbedding")
ASSERT:C1129($myEmbed.length=1; "Should find myEmbedding in models list")
ASSERT:C1129($myEmbed[0].capabilities.supportsEmbedding=True:C214; "myEmbedding should support embedding")

// MARK:- Empty models list
var $noModelsProviders:=cs:C1710.OpenAIProviders.new()
$noModelsProviders._providers:={providers: $config}
var $emptyModels : Collection:=$noModelsProviders.models()
ASSERT:C1129($emptyModels.length=0; "Should return empty collection when no models configured")

