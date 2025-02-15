//%attributes = {}

// create a client
var $client:=cs:C1710.OpenAI.new()
// $client.baseURL:="http://127.0.0.1:11434/v1"  // ex: ollama

// MARK:- models
var $modelsResult:=$client.models.list()
var $models:=$modelsResult.models

var $model : cs:C1710.OpenAIModel:=$client.models.retrieve($models.first().id).model

// MARK:- chat completion

var $modelName:="gpt-4o-mini"
//$modelName:=$model.id

var $messages:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant."})]
$messages.push({role: "user"; content: "Could you explain me why 42 is a special number"})
var $chatResult:=$client.chat.completions.create($messages; {model: $modelName})

var $assistantText : Text:=$chatResult.choices.first().message.content
$messages.push($chatResult.choices.first().message)

$messages.push({role: "user"; content: "and could you decompose this number"})
$chatResult:=$client.chat.completions.create($messages; {model: $modelName})
$assistantText:=$chatResult.choices.first().message.content

// or
var $helper:=$client.chat.createChatHelper("You are a helpful assistant.")
$chatResult:=$helper.prompt("Could you explain me why 42 is a special number")
$chatResult:=$helper.prompt("and could you decompose this number")

// MARK:- moderation

var $moderation:=$client.moderations.create("Hello word").moderation

// MARK:- image

var $images:=$client.images.generate("A futuristic city skyline at sunset"; {size: "1024x1024"}).images  // ; responseFormat: "b64_json", n: 4
// $images.first().saveToDisk(Folder(fk desktop folder).file("mycity.png"))

// MARK:- vision

var $visionModelName:=$modelName  // ex: OpenAI=gpt-4o-mini, Ollama=llama3.2-vision
var $imageUrl : Text:=$images.first().url

var $message:=cs:C1710.OpenAIMessage.new({role: "user"})
$message.content:=[\
{type: "text"; text: "give me a description of the image"}; \
{type: "image_url"; image_url: {url: $imageUrl; detail: "low"}}\
]

$chatResult:=$client.chat.completions.create([$message]; {model: $visionModelName})
var $visionText : Text:=$chatResult.choices.first().message.content

// or
$chatResult:=$client.chat.createVisionHelper($imageUrl).prompt("give me a description of the image")
