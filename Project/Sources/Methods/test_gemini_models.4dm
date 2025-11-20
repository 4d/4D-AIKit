//%attributes = {"invisible":true}
var $client:=TestGemini()
If ($client=Null:C1517)
	return  // skip test
End if

// MARK:- Test list models
var $modelsResult:=$client.models.list()
If (Asserted:C1132(Bool:C1537($modelsResult.success); "Cannot get model list: "+JSON Stringify:C1217($modelsResult)))

	If (Asserted:C1132($modelsResult.models#Null:C1517; "Model list must not be null"))

		If (Asserted:C1132($modelsResult.models.length>0; "Model list must not be empty"))

			var $firstModel:=$modelsResult.models.first()
			ASSERT:C1129(Length:C16($firstModel.name)>0; "Model name must not be empty")
			ASSERT:C1129(Length:C16($firstModel.displayName)>0; "Model display name must not be empty")

			// Find a gemini model
			var $geminiModel : Object
			var $model : Object
			For each ($model; $modelsResult.models)
				If (Position:C15("gemini"; Lowercase:C14($model.name))>0)
					$geminiModel:=$model
					break
				End if
			End for each

			If (Asserted:C1132($geminiModel#Null:C1517; "Must find at least one Gemini model"))

				// Extract model name from the full path (e.g., "models/gemini-2.0-flash" -> "gemini-2.0-flash")
				var $modelName : Text:=$geminiModel.name
				If (Position:C15("models/"; $modelName)=1)
					$modelName:=Substring:C12($modelName; 8)
				End if

				// Test retrieve model
				var $modelResult:=$client.models.retrieve($modelName)

				If (Asserted:C1132(Bool:C1537($modelResult.success); "Cannot get model: "+JSON Stringify:C1217($modelResult)))

					ASSERT:C1129($modelResult.model#Null:C1517; "Model must not be null")
					ASSERT:C1129(Length:C16($modelResult.model.name)>0; "Model name must not be empty")
					ASSERT:C1129($modelResult.model.inputTokenLimit>0; "Model should have input token limit")

				End if

			End if

		End if

	End if

End if

