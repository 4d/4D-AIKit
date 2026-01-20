//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

var $modelsResult:=$client.models.list()
If (Asserted:C1132(Bool:C1537($modelsResult.success); "Cannot get model list: "+JSON Stringify:C1217($modelsResult)))
	
	If (Asserted:C1132($modelsResult.models#Null:C1517; "Model list must not be null"))
		
		If (Asserted:C1132($modelsResult.models.length>0; "Model list must not be empty"))
			
			var $modelName : Text:=$modelsResult.models.first().id
			var $modelResult:=$client.models.retrieve($modelName)
			
			If (Asserted:C1132(Bool:C1537($modelResult.success); "Cannot get model: "+JSON Stringify:C1217($modelResult)))
				
				ASSERT:C1129($modelResult.model#Null:C1517; "Model must not be null")
				ASSERT:C1129($modelResult.model.id#Null:C1517; "Model id must not be null")
				
			End if 
			
		End if 
		
	End if 
	
End if 

