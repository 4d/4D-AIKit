//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if

var $createdAssistantId:=""

// MARK:- Test assistant creation
var $params:=cs:C1710.OpenAIAssistantsParameters.new()
$params.model:="gpt-4o-mini"
$params.name:="Math Tutor"
$params.description:="A helpful math tutor assistant"
$params.instructions:="You are a personal math tutor. Write and run code to answer math questions."
$params.tools:=[]
$params.tools.push({type: "code_interpreter"})
$params.metadata:={test: "true"; purpose: "unit_test"}

var $createResult:=$client.assistants.create($params)

If (Asserted:C1132(Bool:C1537($createResult.success); "Cannot create assistant: "+JSON Stringify:C1217($createResult)))

	If (Asserted:C1132($createResult.assistant#Null:C1517; "Assistant must not be null"))

		ASSERT:C1129(Length:C16(String:C10($createResult.assistant.id))>0; "Assistant ID must not be empty")
		ASSERT:C1129(String:C10($createResult.assistant.object)="assistant"; "Object type must be 'assistant'")
		ASSERT:C1129(String:C10($createResult.assistant.model)="gpt-4o-mini"; "Model must match")
		ASSERT:C1129(String:C10($createResult.assistant.name)="Math Tutor"; "Name must match")
		ASSERT:C1129(String:C10($createResult.assistant.description)="A helpful math tutor assistant"; "Description must match")
		ASSERT:C1129(String:C10($createResult.assistant.instructions)="You are a personal math tutor. Write and run code to answer math questions."; "Instructions must match")
		ASSERT:C1129((Value type:C1509($createResult.assistant.createdAt)=Is real:K8:4) && $createResult.assistant.createdAt>0; "Created timestamp must be set")
		ASSERT:C1129($createResult.assistant.tools#Null:C1517; "Tools must not be null")
		ASSERT:C1129($createResult.assistant.tools.length=1; "Should have one tool")
		ASSERT:C1129($createResult.assistant.metadata#Null:C1517; "Metadata must not be null")

		$createdAssistantId:=$createResult.assistant.id

	End if

End if

// MARK:- Test assistant retrieval
If (Length:C16($createdAssistantId)>0)

	var $retrieveResult:=$client.assistants.retrieve($createdAssistantId)

	If (Asserted:C1132(Bool:C1537($retrieveResult.success); "Cannot retrieve assistant: "+JSON Stringify:C1217($retrieveResult)))

		If (Asserted:C1132($retrieveResult.assistant#Null:C1517; "Retrieved assistant must not be null"))

			ASSERT:C1129($retrieveResult.assistant.id=$createdAssistantId; "Retrieved assistant ID must match")
			ASSERT:C1129($retrieveResult.assistant.object="assistant"; "Object type must be 'assistant'")
			ASSERT:C1129($retrieveResult.assistant.name="Math Tutor"; "Name must match")
			ASSERT:C1129($retrieveResult.assistant.model="gpt-4o-mini"; "Model must match")

		End if

	End if

End if

// MARK:- Test assistant modification
If (Length:C16($createdAssistantId)>0)

	var $modifyParams:=cs:C1710.OpenAIAssistantsParameters.new()
	$modifyParams.name:="Physics Tutor"
	$modifyParams.description:="A helpful physics tutor assistant"
	$modifyParams.instructions:="You are a personal physics tutor. Explain concepts clearly with examples."

	var $modifyResult:=$client.assistants.modify($createdAssistantId; $modifyParams)

	If (Asserted:C1132(Bool:C1537($modifyResult.success); "Cannot modify assistant: "+JSON Stringify:C1217($modifyResult)))

		If (Asserted:C1132($modifyResult.assistant#Null:C1517; "Modified assistant must not be null"))

			ASSERT:C1129($modifyResult.assistant.id=$createdAssistantId; "Modified assistant ID must match")
			ASSERT:C1129($modifyResult.assistant.name="Physics Tutor"; "Modified name must match")
			ASSERT:C1129($modifyResult.assistant.description="A helpful physics tutor assistant"; "Modified description must match")
			ASSERT:C1129($modifyResult.assistant.instructions="You are a personal physics tutor. Explain concepts clearly with examples."; "Modified instructions must match")

		End if

	End if

End if

// MARK:- Test assistant listing
var $listResult:=$client.assistants.list()

If (Asserted:C1132(Bool:C1537($listResult.success); "Cannot list assistants: "+JSON Stringify:C1217($listResult)))

	If (Asserted:C1132($listResult.assistants#Null:C1517; "Assistants collection must not be null"))

		If (Asserted:C1132($listResult.assistants.length>0; "Must have at least one assistant"))

			// Check if our created assistant is in the list
			var $foundAssistant:=False:C215
			var $assistant : cs:C1710.OpenAIAssistant
			For each ($assistant; $listResult.assistants)
				If ($assistant.id=$createdAssistantId)
					$foundAssistant:=True:C214
					break
				End if
			End for each

			ASSERT:C1129($foundAssistant; "Created assistant should be found in assistant list")

		End if

	End if

End if

// MARK:- Test assistant listing with parameters
var $listParams:=cs:C1710.OpenAIAssistantListParameters.new({\
limit: 5; \
order: "desc"\
})

var $filteredListResult:=$client.assistants.list($listParams)

If (Asserted:C1132(Bool:C1537($filteredListResult.success); "Cannot list assistants with parameters: "+JSON Stringify:C1217($filteredListResult)))

	If (Asserted:C1132($filteredListResult.assistants#Null:C1517; "Filtered assistants collection must not be null"))

		// Verify limit is respected (if there are more than 5 assistants)
		// Note: We don't assert this strictly as there might be fewer assistants
		If ($filteredListResult.assistants.length>1)
			ASSERT:C1129($filteredListResult.assistants.length<=5; "Should not return more than 5 assistants")
		End if

	End if

End if

// MARK:- Test assistant listing pagination
var $paginationParams:=cs:C1710.OpenAIAssistantListParameters.new({\
limit: 2; \
order: "desc"\
})

var $firstPage:=$client.assistants.list($paginationParams)

If (Asserted:C1132(Bool:C1537($firstPage.success); "Cannot list first page for pagination test: "+JSON Stringify:C1217($firstPage)))
	If (Asserted:C1132($firstPage.assistants#Null:C1517; "First page assistants must not be null"))
		If ($firstPage.assistants.length>=2)
			var $lastAssistant : cs:C1710.OpenAIAssistant:=$firstPage.assistants.last()
			var $lastAssistantId:=$lastAssistant.id

			// Test pagination helpers
			ASSERT:C1129(Length:C16($firstPage.firstId)>0; "First ID should not be empty")
			ASSERT:C1129(Length:C16($firstPage.lastId)>0; "Last ID should not be empty")
			ASSERT:C1129($firstPage.lastId=$lastAssistantId; "Last ID should match last assistant ID")

			// Set after parameter to paginate
			$paginationParams.after:=$lastAssistantId
			var $secondPage:=$client.assistants.list($paginationParams)

			If (Asserted:C1132(Bool:C1537($secondPage.success); "Cannot list second page for pagination test: "+JSON Stringify:C1217($secondPage)))
				If (Asserted:C1132($secondPage.assistants#Null:C1517; "Second page assistants must not be null"))
					// Verify second page does not include lastAssistantId from first page
					var $found:=False:C215
					For each ($assistant; $secondPage.assistants)
						If ($assistant.id=$lastAssistantId)
							$found:=True:C214
							break
						End if
					End for each
					ASSERT:C1129($found=False:C215; "Second page should not include last assistant from first page")
				End if
			End if
		End if
	End if
End if

// MARK:- Test error handling for non-existent assistant
var $invalidResult:=$client.assistants.retrieve("asst_nonexistent123")

If (Asserted:C1132(Not:C34(Bool:C1537($invalidResult.success)); "Should fail for non-existent assistant"))

	ASSERT:C1129($invalidResult.request.response.status>=400; "Should return 4xx error status")

End if

// MARK:- Test assistant deletion
If (Length:C16($createdAssistantId)>0)

	var $deleteResult:=$client.assistants.delete($createdAssistantId)

	If (Asserted:C1132(Bool:C1537($deleteResult.success); "Cannot delete assistant: "+JSON Stringify:C1217($deleteResult)))

		If (Asserted:C1132($deleteResult.deleted#Null:C1517; "Delete result must not be null"))

			ASSERT:C1129($deleteResult.deleted.id=$createdAssistantId; "Deleted assistant ID must match")
			ASSERT:C1129($deleteResult.deleted.deleted=True:C214; "Assistant should be marked as deleted")
			ASSERT:C1129($deleteResult.deleted.object="assistant.deleted"; "Object type must be 'assistant.deleted'")

		End if

	End if

	// Verify assistant is actually deleted by trying to retrieve it
	var $verifyDeleteResult:=$client.assistants.retrieve($createdAssistantId)
	ASSERT:C1129(Not:C34(Bool:C1537($verifyDeleteResult.success)); "Should not be able to retrieve deleted assistant")

	// MARK:- Test deleting already deleted assistant
	var $deleteAgainResult:=$client.assistants.delete($createdAssistantId)
	ASSERT:C1129(Not:C34(Bool:C1537($deleteAgainResult.success)); "Should not be able to delete already deleted assistant")
	ASSERT:C1129($deleteAgainResult.request.response.status>=400; "Should return error status for already deleted assistant")

End if

// MARK:- Test parameter validation
// Test that create throws with null parameters
var $lastErrors : Collection
Try($client.assistants.create(Null:C1517))
$lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error with null parameters"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("parameters"; $lastErrors[0].message)>0; "Error should mention parameters")
End if

// Test that create throws when model is missing
var $invalidParams:=cs:C1710.OpenAIAssistantsParameters.new()
$invalidParams.name:="Test"
// No model set
Try($client.assistants.create($invalidParams))
$lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error when model is missing"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("model"; $lastErrors[0].message)>0; "Error should mention model parameter")
End if

// Test that retrieve throws with empty assistant ID
Try($client.assistants.retrieve(""))
$lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error with empty assistant ID"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("assistantId"; $lastErrors[0].message)>0; "Error should mention assistantId parameter")
End if

// Test that modify throws with empty assistant ID
Try($client.assistants.modify(""; cs:C1710.OpenAIAssistantsParameters.new()))
$lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error with empty assistant ID for modification"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("assistantId"; $lastErrors[0].message)>0; "Error should mention assistantId parameter")
End if

// Test that modify throws with null parameters
Try($client.assistants.modify("asst_123"; Null:C1517))
$lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error with null parameters for modification"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("parameters"; $lastErrors[0].message)>0; "Error should mention parameters")
End if

// Test that delete throws with empty assistant ID
Try($client.assistants.delete(""))
$lastErrors:=Last errors:C1799
If (Asserted:C1132($lastErrors#Null:C1517; "Should throw error with empty assistant ID for deletion"))
	ASSERT:C1129($lastErrors.length>0; "Should have at least one error")
	ASSERT:C1129(Position:C15("assistantId"; $lastErrors[0].message)>0; "Error should mention assistantId parameter")
End if

Try(True:C214)  // Reset errors
