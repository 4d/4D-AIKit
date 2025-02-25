property chat : cs:C1710.OpenAIChatAPI

property imageURL : Text

Class constructor($chat : cs:C1710.OpenAIChatAPI; $imageData : Variant)
	This:C1470.chat:=$chat
	
	var $blob : Blob
	var $encoded : Text
	Case of 
		: (Value type:C1509($imageData)=Is text:K8:3)
			
			This:C1470.imageURL:=$imageData
			
		: ((Value type:C1509($imageData)=Is object:K8:27) && (OB Instance of:C1731($imageData; 4D:C1709.File)))
			
			$blob:=$imageData.getContent()
			
			BASE64 ENCODE:C895($blob; $encoded)
			This:C1470.imageURL:="data:image/png;base64,"+$encoded
			
		: (Value type:C1509($imageData)=Is picture:K8:10)
			
			PICTURE TO BLOB:C692($imageData; $blob; "png")
			
			BASE64 ENCODE:C895($blob; $encoded)
			This:C1470.imageURL:="data:image/png;base64,"+$encoded
			
	End case 
	
Function prompt($prompt : Text; $parameters : cs:C1710.OpenAIChatCompletionsParameters) : cs:C1710.OpenAIChatCompletionsResult
	
	var $message:=cs:C1710.OpenAIMessage.new({role: "user"; content: [{type: "text"; text: $prompt}; \
		{type: "image_url"; image_url: {url: This:C1470.imageURL; detail: "low"}}]})
	
	If ($parameters=Null:C1517)
		$parameters:={}
	End if 
	If ($parameters.model=Null:C1517)
		$parameters.model:="gpt-4o-mini"
	End if 
	
	return This:C1470.chat.completions.create([$message]; $parameters)