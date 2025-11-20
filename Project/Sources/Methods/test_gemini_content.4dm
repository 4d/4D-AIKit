//%attributes = {"invisible":true}
var $client:=TestGemini()
If ($client=Null:C1517)
	return  // skip test
End if

// MARK:- Test basic content generation
var $modelName : Text:="gemini-2.0-flash-exp"

var $result:=$client.content.generate("What is the capital of France?"; $modelName; {})

If (Asserted:C1132(Bool:C1537($result.success); "Cannot generate content: "+JSON Stringify:C1217($result)))

	If (Asserted:C1132($result.candidates#Null:C1517; "No candidates returned"))

		If (Asserted:C1132($result.candidates.length>0; "Must have at least one candidate"))

			var $candidate:=$result.candidates[0]

			ASSERT:C1129($candidate.content#Null:C1517; "Candidate content must not be null")
			ASSERT:C1129($candidate.content.parts.length>0; "Candidate must have parts")
			ASSERT:C1129(Length:C16($candidate.text)>0; "Response text must not be empty")
			ASSERT:C1129(Position:C15("Paris"; $candidate.text)>0; "Response should mention Paris")

		End if

	End if

	// Check usage metadata
	If (Asserted:C1132($result.usage#Null:C1517; "Usage metadata must be present"))
		ASSERT:C1129($result.usage.totalTokenCount>0; "Total token count should be greater than 0")
	End if

End if

// MARK:- Test generateText convenience method
var $textResponse:=$client.content.generateText("Say 'Hello'"; $modelName; {})
ASSERT:C1129(Length:C16($textResponse)>0; "generateText should return non-empty text")
ASSERT:C1129(Position:C15("Hello"; $textResponse)>0; "Response should contain 'Hello'")

// MARK:- Test with generation config
var $params:=cs:C1710.GeminiContentParameters.new()
$params.setGenerationConfig(0.7; 100; -1; -1)

$result:=$client.content.generate("Write a haiku about mountains"; $modelName; $params)
If (Asserted:C1132(Bool:C1537($result.success); "Cannot generate with config: "+JSON Stringify:C1217($result)))
	ASSERT:C1129($result.candidates.length>0; "Must have candidates")
	ASSERT:C1129(Length:C16($result.candidates[0].text)>0; "Must have text response")
End if

// MARK:- Test with system instruction
var $paramsSystem:=cs:C1710.GeminiContentParameters.new()
$paramsSystem.systemInstruction:="You are a helpful assistant that always responds in French."

$result:=$client.content.generate("Say hello"; $modelName; $paramsSystem)
If (Asserted:C1132(Bool:C1537($result.success); "Cannot generate with system instruction: "+JSON Stringify:C1217($result)))
	ASSERT:C1129($result.candidates.length>0; "Must have candidates")
	var $text:=$result.candidates[0].text
	ASSERT:C1129(Length:C16($text)>0; "Must have text response")
	// The response should be in French (Bonjour or similar)
	ASSERT:C1129((Position:C15("Bonjour"; $text)>0) || (Position:C15("bonjour"; $text)>0); "Response should be in French")
End if

// MARK:- Test error handling
var $errorResult:=$client.content.generate("test"; "invalid-model-name"; {})
ASSERT:C1129(Not:C34(Bool:C1537($errorResult.success)); "Must fail with invalid model")
ASSERT:C1129($errorResult.errors.length>0; "Must have error")

