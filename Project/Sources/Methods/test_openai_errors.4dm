//%attributes = {}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

//MARK:- Empty prompt
var $helper:=$client.chat.create("")
var $result:=$helper.prompt("")
ASSERT:C1129(Length:C16($result.choice.message.text)>0; "chat do not return a message text")

$result:=$client.chat.completions.create([])
ASSERT:C1129(Not:C34($result.success); "must not success with no messages")
ASSERT:C1129($result.errors.length>0; JSON Stringify:C1217($result))

//MARK:- Unsupported Model
var $modelName:="fake-Model"+Generate UUID:C1066
var $messages:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant."})]
$result:=$client.chat.completions.create($messages; {model: $modelName})
ASSERT:C1129(Not:C34($result.success); "must not success with fake model")
ASSERT:C1129($result.errors.length>0; "The model `fake-Model` does not exist or you do not have access to it.")

//MARK:- Empty image prompt
//# Empty value
$result:=$client.images.generate("")
ASSERT:C1129($result.errors.length>0; "You must provide a prompt "+JSON Stringify:C1217($result))


//MARK:- Wrong model
//# wrong model
$result:=$client.images.generate("a cat"; {model: $modelName})
ASSERT:C1129($result.errors.length>0; "Invalid model. The model argument should be left blank. "+JSON Stringify:C1217($result))

//MARK:- failed connection
var $tmpBaseURL:=$client.baseURL
$client.baseURL:="http://192.222.222.222"
$result:=$client.images.generate("a cat")
ASSERT:C1129($result.errors.length>0; "Failed to create a connected socket "+JSON Stringify:C1217($result))
$client.baseURL:=$tmpBaseURL

//MARK:- wrong apiKey
var $tmpApiKey:=$client.apiKey
$client.apiKey:=""
$helper:=$client.chat.create("Your are a expert math")
$result:=$helper.prompt("What is the square root of 25?")
ASSERT:C1129($result.errors.length>0; "chat do not return a message text")
ASSERT:C1129(Not:C34($result.success); "The request is failed")
$client.apiKey:=$tmpApiKey

//MARK:- asynchrone failed
$client.baseURL:="http://192.222.222.222"
cs:C1710._TestSignal.me.init()

CALL WORKER:C1389(Current method name:C684; Formula:C1597($client.models.list({formula: Formula:C1597(cs:C1710._TestSignal.me.trigger($1))})))

cs:C1710._TestSignal.me.wait(10*1000)

var $value : cs:C1710.OpenAIModelListResult:=cs:C1710._TestSignal.me.result
ASSERT:C1129(Not:C34($value.success))
ASSERT:C1129($value.errors.length>0; "Failed to create a connected socket"+JSON Stringify:C1217($value))
cs:C1710._TestSignal.me.reset()

KILL WORKER:C1390(Current method name:C684)
