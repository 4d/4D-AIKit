//%attributes = {}

// create a client
var $client:=cs:C1710.OpenAI.new()

// MARK:- models
var $modelsResult:=$client.models.list()
var $models:=$modelsResult.models

var $model : cs:C1710.OpenAIModel:=$client.models.retrieve($models.first().id).model

// MARK:- chat completion

var $messages:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant."})]
$messages.push({role: "user"; content: "Could you explain me why 42 is a special number"})
var $chatResult:=$client.chat.completions.create($messages; {model: "gpt-4o-mini"})

var $assistantText : Text:=$chatResult.choices.first().message.content
$messages.push($chatResult.choices.first().message)

$messages.push({role: "user"; content: "and could you decompose this number"})
$chatResult:=$client.chat.completions.create($messages; {model: "gpt-4o-mini"})
$assistantText:=$chatResult.choices.first().message.content

// or
// var $helper:=$client.chat.createChatHelper("You are a helpful assistant.")
// $chat:=$helper.prompt("Could you explain me why 42 is a special number")
// $assistantText:=$chat.choices.first().message.content or look at $helper.messages
// $chat:=$helper.prompt("and could you decompose this number")


// MARK:- moderation

var $moderation:=$client.moderations.create("Hello word").moderation

// MARK:- image

var $images:=$client.images.generate("A futuristic city skyline at sunset"; {size: "1024x1024"}).images  // ; responseFormat: "b64_json"
// $images.first().saveToDisk(Folder(fk desktop folder).file("mycity.png"))

// MARK:- vision

var $imageUrl : Text:=$images.first().url

var $message:=cs:C1710.OpenAIMessage.new({role: "user"})
$message.content:=[\
{type: "text"; text: "give me a description of the image"}; \
{type: "image_url"; image_url: {url: $imageUrl; detail: "low"}}\
]

$chatResult:=$client.chat.completions.create([$message]; {model: "gpt-4o-mini"})
var $visionText : Text:=$chatResult.choices.first().message.content

// or
// $chatResult:=$client.chat.createVisionHelper($imageUrl).prompt("give me a description of the image")
