//%attributes = {}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

var $modelName:=cs:C1710._TestModels.new($client).chats

// MARK:- chat.completions.create without stream but async

cs:C1710._TestSignal.me.init()

var $messages:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant."})]
$messages.push({role: "user"; content: "Could you explain me why 42 is a special number"})

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.chat.completions.create($messages; {model: $modelName; onTerminate: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))

cs:C1710._TestSignal.me.wait(10*1000)

var $result : cs:C1710.OpenAIChatCompletionsResult:=cs:C1710._TestSignal.me.result

If (Asserted:C1132(Bool:C1537($result.success); "Cannot complete chat : "+JSON Stringify:C1217($result)))
	
	If ((Asserted:C1132($result.choice#Null:C1517)) && (Asserted:C1132($result.choice.message#Null:C1517)))
		
		ASSERT:C1129(Length:C16($result.choice.message.text)>0; "chat do not return a message text")
		
	End if 
	
End if 


// MARK:- no stream test with mock
If ((Position:C15("127.0.0.1"; $client.baseURL)>0) && ($client.apiKey="none"))  // mock not implemented
	return 
End if 

// MARK:- chat.completions.create with stream
cs:C1710._TestSignal.me.init()


CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.chat.completions.create($messages; {model: $modelName; stream: True:C214; onData: Formula:C1597(cs:C1710._TestSignal.me.pushChunk($1)); onTerminate: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))

cs:C1710._TestSignal.me.wait(10*1000)

var $streamResult : cs:C1710.OpenAIChatCompletionsStreamResult:=cs:C1710._TestSignal.me.result
var $streamResults:=cs:C1710._TestSignal.me.chunks

If (Asserted:C1132(Bool:C1537($streamResult.success); "Cannot complete chat completions stream : "+JSON Stringify:C1217($streamResult)))
	
	If (Asserted:C1132(($streamResults#Null:C1517) && ($streamResults.length>0); "No chunk received for completions streaming"))
		
		var $completionsMessage : Text:=$streamResults.extract("choice").extract("delta").extract("text").join("")
		
		ASSERT:C1129(Length:C16($completionsMessage)>0; "chat completions stream do not return a message text")
		
	End if 
	
End if 

