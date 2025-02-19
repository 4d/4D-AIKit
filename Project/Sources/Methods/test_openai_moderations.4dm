//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

var $result:=$client.moderations.create("test input"; "omni-moderation-latest")
If (Asserted:C1132(Bool:C1537($result.success); "Cannot get moderations result: "+JSON Stringify:C1217($result)))
	
	If (Asserted:C1132($result.moderation#Null:C1517; "moderation must not be null"))
		
		ASSERT:C1129($result.moderation.model="omni-moderation-latest"; "wrong model")
		
		If (Asserted:C1132($result.moderation.results#Null:C1517; "must have moderation result"))
			
			ASSERT:C1129($result.moderation.item#Null:C1517; "must have moderation item")
			
		End if 
		
	End if 
	
End if 

// MARK:- empty model 
$result:=$client.moderations.create("test input")
If (Asserted:C1132(Bool:C1537($result.success); "Cannot get moderations result: "+JSON Stringify:C1217($result)))
	
	If (Asserted:C1132($result.moderation#Null:C1517; "moderation must not be null"))
		
		ASSERT:C1129($result.moderation.model#Null:C1517; "no default model returned")
		
		If (Asserted:C1132($result.moderation.results#Null:C1517; "must have moderation result"))
			
			ASSERT:C1129($result.moderation.item#Null:C1517; "must have moderation item")
			
		End if 
		
	End if 
	
End if 

