//%attributes = {"invisible":true}
#DECLARE() : cs:C1710.OpenAI
var $client:=cs:C1710.OpenAI.new()

// TODO: how to configure it to test

// local
// $client.baseURL:="http://127.0.0.1:11434/v1"  // ollama 
// $client.baseURL:="http://127.0.0.1:8080" // mudler/LocalAI

// remote
// $client.baseURL:="https://api.mistral.ai/v1"
// $client.baseURL:="https://api.deepseek.com" 
// $client.baseURL:="https://api.groq.com/openai/v1" 
// $client.baseURL:="https://api.perplexity.ai" 
// $client.baseURL:="https://api.anthropic.com/v1"
// $client.baseURL:="https://YOUR_RESOURCE_NAME.openai.azure.com"

// mock
// $client.baseURL:="http://127.0.0.1:4010" // npm exec --package=@stainless-api/prism-cli@5.8.5 -- prism mock -d "https://storage.googleapis.com/stainless-sdk-openapi-specs/openai-4aa6ee65ba9efc789e05e6a5ef0883b2cadf06def8efd863dbf75e9e233067e1.yml"   

If ((Folder:C1567(fk desktop folder:K87:19).file("apiKey").exists) && ($client.apiKey#Null:C1517))
	$client.apiKey:=Folder:C1567(fk desktop folder:K87:19).file("apiKey").getText()
End if 

return $client