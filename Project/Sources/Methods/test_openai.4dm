//%attributes = {}

// create a client
var $client:=cs:C1710.OpenAI.new()

// MARK:- models
var $models:=$client.models.list()

var $modelId : Text:="gpt-4o"  // $models.models.first().id   // TODO: change according to how it stored models in response
var $model:=$client.models.retrieve($modelId)

// MARK:- moderation

var $moderations:=$client.moderations.create("Hello word")

// MARK:- image

var $image:=$client.images.generate("A futuristic city skyline at sunset"; {size: "1024x1024"})

