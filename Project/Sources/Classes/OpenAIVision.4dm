property chat : cs:C1710.OpenAIChatAPI

Class constructor($chat : cs:C1710.OpenAIChatAPI)
	This:C1470.chat:=$chat
	
	// Not api related: just an helper to analyse an image
Function create($imageURL : Text) : cs:C1710.OpenAIVisionHelper
	return cs:C1710.OpenAIVisionHelper.new(This:C1470.chat; $imageURL)