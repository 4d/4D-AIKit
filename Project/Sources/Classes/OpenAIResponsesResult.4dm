Class extends OpenAIResult

Function get response : cs:C1710.OpenAIResponse
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return Null:C1517
	End if 
	
	return cs:C1710.OpenAIResponse.new($body)
	
Function get output : Collection
	var $body:=This:C1470._objectBody()
	If (($body=Null:C1517) || (Not:C34(Value type:C1509($body.output)=Is collection:K8:32)))
		return []
	End if 
	
	return $body.output.map(Formula:C1597(cs:C1710.OpenAIResponseOutputItem.new($1.value)))
	
Function get output_text : Text
	var $body:=This:C1470._objectBody()
	If ($body=Null:C1517)
		return ""
	End if 
	
	var $texts : Collection:=[]
	
	If (Value type:C1509($body.output)=Is collection:K8:32)
		var $outputItem : Object
		For each ($outputItem; $body.output)
			If ($outputItem.type="message") && (Value type:C1509($outputItem.content)=Is collection:K8:32)
				var $content : Object
				For each ($content; $outputItem.content)
					If ($content.type="output_text") && (Length:C16($content.text)>0)
						$texts.push($content.text)
					End if 
				End for each 
			End if 
		End for each 
	End if 
	
	return $texts.join("")
	