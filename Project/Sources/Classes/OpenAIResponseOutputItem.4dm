property type : Text
property role : Text
property content : Collection
property id : Text
property refusal : Text

Class constructor($item : Object)
	If ($item=Null:C1517)
		return 
	End if 
	
	This:C1470.type:=$item.type
	This:C1470.role:=$item.role
	This:C1470.content:=$item.content
	This:C1470.id:=$item.id
	This:C1470.refusal:=$item.refusal
	
Function get text : Text
	var $texts : Collection:=[]
	
	If (Value type:C1509(This:C1470.content)=Is collection:K8:32)
		var $content : Object
		For each ($content; This:C1470.content)
			If ($content.type="output_text") && (Length:C16($content.text)>0)
				$texts.push($content.text)
			End if 
		End for each 
	End if 
	
	return $texts.join("")
	