//%attributes = {}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

var $modelName:=cs:C1710._TestModels.new($client).chats

// MARK:- responses.create without stream but async
cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.responses.create("Explain why 42 is a special number."; {model: $modelName; onTerminate: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))

cs:C1710._TestSignal.me.wait(10*1000)

var $result : cs:C1710.OpenAIResponsesResult:=cs:C1710._TestSignal.me.result

If (Asserted:C1132(Bool:C1537($result.success); "Cannot complete responses async : "+JSON Stringify:C1217($result)))
	
	var $response:=$result.response
	If (Asserted:C1132($response#Null:C1517; "responses async do not return response"))
		ASSERT:C1129(Length:C16($response.outputText)>0; "responses async do not return text")
	End if 
	
End if 

// MARK:- no stream test with mock
If ((Position:C15("127.0.0.1"; $client.baseURL)>0) && ($client.apiKey="none"))  // mock not implemented
	KILL WORKER:C1390(Current method name:C684)
	return 
End if 

// MARK:- responses.create with stream
cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.responses.create("Tell me a short story about 42."; {model: $modelName; stream: True:C214; onData: Formula:C1597(cs:C1710._TestSignal.me.pushChunk($1)); onTerminate: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))

cs:C1710._TestSignal.me.wait(10*1000)

var $streamResult : cs:C1710.OpenAIResponsesStreamResult:=cs:C1710._TestSignal.me.result
var $streamResults:=cs:C1710._TestSignal.me.chunks

If (Asserted:C1132(Bool:C1537($streamResult.success); "Cannot complete responses stream : "+JSON Stringify:C1217($streamResult)))
	
	If (Asserted:C1132(($streamResults#Null:C1517) && ($streamResults.length>0); "No chunk received for responses streaming"))
		
		var $text : Text:=""
		var $chunk : Object
		For each ($chunk; $streamResults)
			If (($chunk.event="response.output_text.delta") && ($chunk.data#Null:C1517) && ($chunk.data.delta#Null:C1517))
				$text:=$text+$chunk.data.delta
			End if 
		End for each 
		
		ASSERT:C1129(Length:C16($text)>0; "responses stream do not return message text")
		
	End if 
	
End if 

KILL WORKER:C1390(Current method name:C684)
