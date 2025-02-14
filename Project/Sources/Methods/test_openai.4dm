//%attributes = {}

// create a client
var $client:=cs:C1710.OpenAI.new()

// MARK:- models
var $models:=$client.models.list()

var $modelId : Text:=$models.request.response.body.data.first().id
var $model:=$client.models.retrieve($modelId)

// MARK:- moderation

var $moderations:=$client.moderations.create("Hello word")

// MARK:- image

var $image:=$client.images.generate("A futuristic city skyline at sunset"; {size: "1024x1024"})

