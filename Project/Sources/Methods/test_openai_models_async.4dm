//%attributes = {}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// MARK: -formula
cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.models.list({formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))

cs:C1710._TestSignal.me.wait(10*1000)

var $result : cs:C1710.OpenAIModelListResult:=cs:C1710._TestSignal.me.result
If (Asserted:C1132($result.success; "Cannot get model list: "+JSON Stringify:C1217($result)))
	If (Asserted:C1132($result.models#Null:C1517; "Model list must not be null"))
		ASSERT:C1129($result.models.length>0; "Model list must not be empty")
	End if 
End if 

cs:C1710._TestSignal.me.reset()

// MARK: -onResponse
cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.models.list({onResponse: Formula:C1597(cs:C1710._TestSignal.me.trigger($1)); onError: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))

cs:C1710._TestSignal.me.wait(10*1000)

$result:=cs:C1710._TestSignal.me.result
If (Asserted:C1132($result.success; "Cannot get model list: "+JSON Stringify:C1217($result)))
	If (Asserted:C1132($result.models#Null:C1517; "Model list must not be null"))
		ASSERT:C1129($result.models.length>0; "Model list must not be empty")
	End if 
End if 

cs:C1710._TestSignal.me.reset()

// MARK: -teardown
KILL WORKER:C1390(Current method name:C684)