//%attributes = {"invisible":true}
#DECLARE() : cs:C1710.OpenAI
var $client:=cs:C1710.OpenAI.new()

If ((Length:C16($client.apiKey)=0) && (Folder:C1567(fk home folder:K87:24).file(".openai").exists))
	$client.apiKey:=Folder:C1567(fk home folder:K87:24).file(".openai").getText()
End if 

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
// $client.customHeaders:=New object("anthropic-version"; "2023-06-01")
// $client.baseURL:="https://YOUR_RESOURCE_NAME.openai.azure.com"
// $client.baseURL:="https://generativelanguage.googleapis.com/v1beta/openai"
// $client.baseURL:="https://api.cohere.ai/compatibility/v1"

// mock
// $client.baseURL:="http://127.0.0.1:4010" // npm exec --package=@stainless-api/prism-cli@5.8.5 -- prism mock -d "https://storage.googleapis.com/stainless-sdk-openapi-specs/openai-4aa6ee65ba9efc789e05e6a5ef0883b2cadf06def8efd863dbf75e9e233067e1.yml"   

// TU
// $client.baseURL:="http://127.0.0.1:80/v1"
// $client.apiKey:="none"

var $providerName:=""  // name of position starting with 1
If (Shift down:C543)
	$providerName:=Request:C163("Provider name?")
End if 
var $providers:=cs:C1710.OpenAIProviders.new()
If (Num:C11($providerName)>0)
	$providerName:=$providers.list()[Num:C11($providerName)-1]
End if 

If (Length:C16($providerName)>0)
	var $providerData:=$providers.get($providerName)
	If (Asserted:C1132($providerData#Null:C1517; "No defined provider "+$providerName))
		$client:=cs:C1710.OpenAI.new($providerData)
	End if 
End if 

return $client