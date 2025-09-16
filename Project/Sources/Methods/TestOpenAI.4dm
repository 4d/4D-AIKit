//%attributes = {"invisible":true}
#DECLARE() : cs:C1710.OpenAI
var $client:=cs:C1710.OpenAI.new()

// TODO: how to configure it to test

// local
// $client.baseURL:="http://127.0.0.1:11434/v1"  // ollama 
// $client.baseURL:="http://ollama:11434/v1"  // ollama in my /etc/hosts
// $client.baseURL:="http://127.0.0.1:8080" // mudler/LocalAI

// remote
// $client.baseURL:="https://api.mistral.ai/v1"
// $client.baseURL:="https://api.deepseek.com" 
// $client.baseURL:="https://api.groq.com/openai/v1" 
// $client.baseURL:="https://api.perplexity.ai" 
// $client.baseURL:="https://api.anthropic.com/v1"
// $client.baseURL:="https://YOUR_RESOURCE_NAME.openai.azure.com"
// $client.baseURL:="https://generativelanguage.googleapis.com/v1beta/openai"

// mock
// $client.baseURL:="http://127.0.0.1:4010" // npm exec --package=@stainless-api/prism-cli@5.8.5 -- prism mock -d "https://storage.googleapis.com/stainless-sdk-openapi-specs/openai-4aa6ee65ba9efc789e05e6a5ef0883b2cadf06def8efd863dbf75e9e233067e1.yml"   

If ((Length:C16($client.apiKey)=0) && (Folder:C1567(fk home folder:K87:24).file(".openai").exists))
	$client.apiKey:=Folder:C1567(fk home folder:K87:24).file(".openai").getText()
End if 

return $client