//%attributes = {}

// create a client
var $client:=cs:C1710.OpenAI.new()

// MARK:- models
var $models:=$client.models.list()

var $modelId : Text:=$models.models.first().id
var $model : cs:C1710.Model:=$client.models.retrieve($modelId).model

// MARK:- moderation

var $moderations:=$client.moderations.create("Hello word")

// MARK:- image

var $image:=$client.images.generate("A futuristic city skyline at sunset"; {size: "1024x1024"})

// MARK:- vision

var $imageUrl : Text:=$image.images.first()

var $message:=cs:C1710.Message.new()
$message.role:="user"
$message.content:=[\
{type: "text"; text: "give me a description of the image"}; \
{type: "image_url"; image_url: {url: $imageUrl; detail: "low"}}\
]

var $vision:=$client.chat.completions.create([$message]; {model: "gpt-4o-mini"})
var $visionText : Text:=$vision.request.response.body.choices.first().message.content
