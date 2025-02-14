//%attributes = {}

// create a client
var $client:=cs:C1710.OpenAI.new()

// MARK:- models
var $models:=$client.models.list()

var $modelId : Text:=$models.models.first().id
var $model : cs:C1710.Model:=$client.models.retrieve($modelId).model

// MARK:- chat completion

var $messages:=[cs:C1710.Message.new({role: "system"; content: "You are a helpful assistant."})]
$messages.push({role: "user"; content: "Could you explain me why 42 is a special number"})
var $chat:=$client.chat.completions.create($messages; {model: "gpt-4o-mini"})

var $assistantText : Text:=$chat.choices.first().message.content
$messages.push($chat.choices.first().message)

$messages.push({role: "user"; content: "and could you decompose this number"})
$chat:=$client.chat.completions.create($messages; {model: "gpt-4o-mini"})
$assistantText:=$chat.choices.first().message.content


// MARK:- moderation

var $moderations:=$client.moderations.create("Hello word")

// MARK:- image

var $image:=$client.images.generate("A futuristic city skyline at sunset"; {size: "1024x1024"})

// MARK:- vision

var $imageUrl : Text:=$image.images.first()

var $message:=cs:C1710.Message.new({role: "user"})
$message.content:=[\
{type: "text"; text: "give me a description of the image"}; \
{type: "image_url"; image_url: {url: $imageUrl; detail: "low"}}\
]

var $vision:=$client.chat.completions.create([$message]; {model: "gpt-4o-mini"})
var $visionText : Text:=$vision.choices.first().message.content
