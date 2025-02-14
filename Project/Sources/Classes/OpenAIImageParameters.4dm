
// The model to use for image generation.
property model : Text:="dall-e-3"

// The number of images to generate. Must be between 1 and 10. For `dall-e-3`, only `n=1` is supported.
property n : Integer:=1

// The size of the generated images. Must be one of `256x256`, `512x512`, or 1024x1024` for `dall-e-2`.
// Must be one of `1024x1024`, `1792x1024`, or `1024x1792` for `dall-e-3` models.
property size : Text:="1024x1024"

// The style of the generated images. Must be one of `vivid` or `natural`
property style : Text:=""

// property quality: Text = "standard" || "hd" // for generation

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)
	
Function body() : Object
	var $body:=Super:C1706.body()
	
	If (Length:C16(This:C1470.model)>0)
		$body.model:=This:C1470.model
	End if 
	If (This:C1470.n>0)
		$body.n:=This:C1470.n
	End if 
	If (Length:C16(This:C1470.size)>0)
		$body.size:=This:C1470.size
	End if 
	If (Length:C16(This:C1470.style)>0)
		$body.style:=This:C1470.style
	End if 
	
	return $body