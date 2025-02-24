//%attributes = {}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// MARK:- chat

var $audioFile:=File:C1566("/System/Library/PrivateFrameworks/PersonalAudio.framework/Versions/A/Resources/Enrollment_1.mp3")
var $result:=$client.audio.transcriptions.create($audioFile; {})

If (Asserted:C1132(Bool:C1537($result.success); "Cannot complete chat : "+JSON Stringify:C1217($result)))
	
	If (Asserted:C1132($result.text#Null:C1517; "chat do not return a choice"))
		
		
	End if 
	
End if 