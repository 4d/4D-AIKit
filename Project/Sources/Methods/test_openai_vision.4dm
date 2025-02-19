//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

var $imageUrl : Text:="https://upload.wikimedia.org/wikipedia/commons/f/f0/Logo-4D-new.jpg"

var $result:=$client.chat.vision.create($imageUrl).prompt("give me a description of the image"; {})  // model: ex: OpenAI=gpt-4o-mini, Ollama=llama3.2-vision

If (Asserted:C1132(Bool:C1537($result.success); "Cannot get vision info : "+JSON Stringify:C1217($result)))
	
	ASSERT:C1129($result.choices#Null:C1517)
	
	If (Asserted:C1132($result.choice#Null:C1517))
		
		If (Asserted:C1132($result.choice.message#Null:C1517))
			
			ASSERT:C1129(Length:C16($result.choice.message.text)>0)
			
		End if 
		
	End if 
	
End if 
