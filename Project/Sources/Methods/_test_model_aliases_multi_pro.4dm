//%attributes = {"invisible":true}
// Interactive test for model aliases with multiple providers
// This test is NOT run automatically (prefix with _test_ instead of test_)
// It requires actual API keys and services to be available

// Create a test configuration file
var $tempFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2)
var $configFile:=$tempFolder.file("multi-provider-test.json")

var $config:={\
providers: {\
openai: {\
baseURL: "https://api.openai.com/v1"; \
apiKeyEnv: "OPENAI_API_KEY"\
}; \
ollama: {\
baseURL: "http://localhost:11434/v1"\
}; \
anthropic: {\
baseURL: "https://api.anthropic.com/v1"; \
apiKeyEnv: "ANTHROPIC_API_KEY"\
}\
}\
}

$configFile.setText(JSON Stringify:C1217($config))

var $client:=cs:C1710.OpenAI.new()
$client.setProvidersFile($configFile)

var $messages:=[]
$messages.push({role: "system"; content: "You are a helpful assistant. Keep your response to one sentence."})
$messages.push({role: "user"; content: "What is the capital of France?"})

// MARK:- Test Chat with OpenAI

var $result:=$client.chat.completions.create($messages; {model: "openai:gpt-4o-mini"})
If ($result.success)
	ALERT:C41("OpenAI Chat: "+$result.choice.message.text)
Else 
	ALERT:C41("OpenAI Chat failed: "+JSON Stringify:C1217($result.errors))
End if 

// MARK:- Test Chat with Ollama (if available)
$result:=$client.chat.completions.create($messages; {model: "ollama:llama3.2"})
If ($result.success)
	ALERT:C41("Ollama Chat: "+$result.choice.message.text)
Else 
	ALERT:C41("Ollama Chat failed (service may not be running): "+JSON Stringify:C1217($result.errors))
End if 

// MARK:- Test Chat with Anthropic (if API key available)
$result:=$client.chat.completions.create($messages; {model: "anthropic:claude-3-5-haiku-20241022"})
If ($result.success)
	ALERT:C41("Anthropic Chat: "+$result.choice.message.text)
Else 
	ALERT:C41("Anthropic Chat failed: "+JSON Stringify:C1217($result.errors))
End if 

// MARK:- Test Embeddings with OpenAI
var $resultEmbedding:=$client.embeddings.create("Hello world"; "openai:text-embedding-3-small")
If ($resultEmbedding.success)
	ALERT:C41("OpenAI Embeddings: Generated vector with "+String:C10($resultEmbedding.embedding.embedding.vector.length)+" dimensions")
Else 
	ALERT:C41("OpenAI Embeddings failed: "+JSON Stringify:C1217($resultEmbedding.errors))
End if 

// MARK:- Test Embeddings with Ollama (if available)
$resultEmbedding:=$client.embeddings.create("Hello world"; "ollama:nomic-embed-text")
If ($resultEmbedding.success)
	ALERT:C41("Ollama Embeddings: Generated vector with "+String:C10($resultEmbedding.embedding.embedding.vector.length)+" dimensions")
Else 
	ALERT:C41("Ollama Embeddings failed (service may not be running): "+JSON Stringify:C1217($resultEmbedding.errors))
End if 

// MARK:- Test Image Generation with OpenAI
var $resultImage:=$client.images.generate("A small cute robot"; {model: "openai:dall-e-3"; size: "1024x1024"})
If ($resultImage.success)
	If ($resultImage.image#Null:C1517)
		ALERT:C41("OpenAI Image: Generated successfully (URL or base64 data available)")
	End if 
Else 
	ALERT:C41("OpenAI Image failed: "+JSON Stringify:C1217($resultImage.errors))
End if 

// Clean up
$configFile.delete()

ALERT:C41("Multi-provider test completed! Check the alerts for results.")
