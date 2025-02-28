//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// MARK:- chat
var $modelName:="gpt-4o-mini"

var $messages:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant."})]
$messages.push({role: "user"; content: "Could you explain me why 42 is a special number"})
var $result:=$client.chat.completions.create($messages; {model: $modelName})

If (Asserted:C1132(Bool:C1537($result.success); "Cannot complete chat : "+JSON Stringify:C1217($result)))
	
	If (Asserted:C1132($result.choice#Null:C1517; "chat do not return a choice"))
		
		If (Asserted:C1132($result.choice.message#Null:C1517; "chat do not return a message"))
			
			ASSERT:C1129(Length:C16($result.choice.message.text)>0; "chat do not return a message text")
			
			$messages.push($result.choice.message)
			$messages.push({role: "user"; content: "and could you decompose this number"})
			
			$result:=$client.chat.completions.create($messages; {model: $modelName})
			
			If ((Asserted:C1132($result.choice#Null:C1517)) && (Asserted:C1132($result.choice.message#Null:C1517)))
				
				ASSERT:C1129(Length:C16($result.choice.message.text)>0; "chat do not return a message text")
				
			End if 
			
		End if 
		
	End if 
	
End if 


// MARK:- chat helper

var $helper:=$client.chat.create("You are a helpful assistant.")
$result:=$helper.prompt("Could you explain me why 42 is a special number")
If (Asserted:C1132(Bool:C1537($result.success); "Cannot complete chat : "+JSON Stringify:C1217($result)))
	
	If ((Asserted:C1132($result.choice#Null:C1517)) && (Asserted:C1132($result.choice.message#Null:C1517)))
		
		ASSERT:C1129(Length:C16($result.choice.message.text)>0; "chat do not return a message text")
		
	End if 
	
End if 

$result:=$helper.prompt("and could you decompose this number")
If (Asserted:C1132(Bool:C1537($result.success); "Cannot complete chat : "+JSON Stringify:C1217($result)))
	
	If ((Asserted:C1132($result.choice#Null:C1517)) && (Asserted:C1132($result.choice.message#Null:C1517)))
		
		ASSERT:C1129(Length:C16($result.choice.message.text)>0; "chat do not return a message text")
		
	End if 
	
End if 


// MARK:- number Of Messages
$helper.numberOfMessages:=2
$result:=$helper.prompt("are you sure")
ASSERT:C1129(($helper.messages.length<=2) && ($helper.messages.length>1); "The number of the messages is not respected")
$result:=$helper.prompt("Thank you")
ASSERT:C1129(($helper.messages.length<=2) && ($helper.messages.length>1); "The number of the messages is not respected")