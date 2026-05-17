property model : Text
property top_n : Integer:=3

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)
	
Function body() : Object
	var $body:=Super:C1706.body()
	
	If (Length:C16(This:C1470.model)>0)
		$body.model:=This:C1470.model
	End if 
	If (This:C1470.top_n>0)
		$body.top_n:=This:C1470.top_n
	End if 
	
	return $body