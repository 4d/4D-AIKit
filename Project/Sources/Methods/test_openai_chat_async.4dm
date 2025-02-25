//%attributes = {}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// MARK:- chat helper

cs:C1710._TestSignal.me.init()

var $helper:=$client.chat.create("You are a helpful assistant."; {formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})

CALL WORKER:C1389(Current method name:C684; Formula:C1597($helper.prompt("Could you explain me why 42 is a special number")))

cs:C1710._TestSignal.me.wait(10*1000)

var $result : cs:C1710.OpenAIChatCompletionsResult:=cs:C1710._TestSignal.me.result

If (Asserted:C1132(Bool:C1537($result.success); "Cannot complete chat : "+JSON Stringify:C1217($result)))
	
	If ((Asserted:C1132($result.choice#Null:C1517)) && (Asserted:C1132($result.choice.message#Null:C1517)))
		
		ASSERT:C1129(Length:C16($result.choice.message.text)>0; "chat do not return a message text")
		
	End if 
	
End if 
