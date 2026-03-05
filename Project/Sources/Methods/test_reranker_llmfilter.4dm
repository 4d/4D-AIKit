//%attributes = {}
// Tests for LLM-based binary relevance filter (RerankerLLMFilterAPI)
// Includes: pure logic tests (no HTTP) and optional integration test.
//
// Integration test requires an OpenAI-compatible API key (uses TestOpenAI() config).

// MARK: - Constructor routing

// type "llm-filter" must instantiate RerankerLLMFilterAPI
var $client:=cs:C1710.Reranker.new({type: "llm-filter"})
ASSERT:C1129($client.type="llm-filter"; "type must be llm-filter")
ASSERT:C1129(OB Instance of:C1731($client._rerank; cs:C1710.RerankerLLMFilterAPI); \
"_rerank must be RerankerLLMFilterAPI when type is llm-filter")

// Any other type → not RerankerLLMFilterAPI
var $apiClient:=cs:C1710.Reranker.new({type: "cohere"})
ASSERT:C1129(Not:C34(OB Instance of:C1731($apiClient._rerank; cs:C1710.RerankerLLMFilterAPI)); \
"Non-llm-filter type must not use RerankerLLMFilterAPI")

// MARK: - _formatDocInputs() tests
var $api : cs:C1710.RerankerLLMFilterAPI:=$client._rerank
var $xml:=$api._formatDocInputs(["Hello world"; "Test document"])
ASSERT:C1129(Position:C15("<document id=0>"; $xml)>0; "Must have document id=0")
ASSERT:C1129(Position:C15("<document id=1>"; $xml)>0; "Must have document id=1")
ASSERT:C1129(Position:C15("Hello world"; $xml)>0; "Must contain first doc text")
ASSERT:C1129(Position:C15("Test document"; $xml)>0; "Must contain second doc text")
ASSERT:C1129(Position:C15("</document>"; $xml)>0; "Must have closing document tag")

// MARK: - _buildPrompt() tests
var $prompt:=$api._buildPrompt("What is AI?"; $api._formatDocInputs(["First doc"; "Second doc"]))
ASSERT:C1129(Length:C16($prompt)>0; "Prompt must not be empty")
ASSERT:C1129(Position:C15("<query>"; $prompt)>0; "Prompt must contain <query> tag")
ASSERT:C1129(Position:C15("What is AI?"; $prompt)>0; "Prompt must contain the query")
ASSERT:C1129(Position:C15("First doc"; $prompt)>0; "Prompt must contain first doc text")
ASSERT:C1129(Position:C15("RELEVANT"; $prompt)>0; "Prompt must mention RELEVANT label")
ASSERT:C1129(Position:C15("NOT_RELEVANT"; $prompt)>0; "Prompt must mention NOT_RELEVANT label")
ASSERT:C1129(Position:C15("<instructions>"; $prompt)>0; "Prompt must have instructions block")

// MARK: - _parseRelevanceResponse() tests

// Basic: doc 0 RELEVANT, doc 1 NOT_RELEVANT
var $resp1 : Text:="<document id=0>\n<explanation>Very relevant.</explanation>\n<answer>RELEVANT</answer>\n</document>\n"+\
"<document id=1>\n<explanation>Not relevant.</explanation>\n<answer>NOT_RELEVANT</answer>\n</document>"
var $scores1:=$api._parseRelevanceResponse($resp1; 2)
If (Asserted:C1132($scores1.length=2; "Must return 2 scores"))
	ASSERT:C1129($scores1[0].index=0; "First item must have index 0")
	ASSERT:C1129($scores1[0].relevance_score=1; "Doc 0 must be RELEVANT (score 1)")
	ASSERT:C1129($scores1[1].index=1; "Second item must have index 1")
	ASSERT:C1129($scores1[1].relevance_score=0; "Doc 1 must be NOT_RELEVANT (score 0)")
End if 

// All RELEVANT
var $resp2 : Text:="<document id=0>\n<answer>RELEVANT</answer>\n</document>\n"+\
"<document id=1>\n<answer>RELEVANT</answer>\n</document>"
var $scores2:=$api._parseRelevanceResponse($resp2; 2)
If (Asserted:C1132($scores2.length=2; "Must return 2 scores"))
	ASSERT:C1129($scores2[0].relevance_score=1; "Doc 0 must score 1")
	ASSERT:C1129($scores2[1].relevance_score=1; "Doc 1 must score 1")
End if 

// Empty response: all default to 0
var $scores3:=$api._parseRelevanceResponse(""; 3)
If (Asserted:C1132($scores3.length=3; "Must return 3 default scores"))
	ASSERT:C1129($scores3[0].relevance_score=0; "Default must be 0")
	ASSERT:C1129($scores3[1].relevance_score=0; "Default must be 0")
	ASSERT:C1129($scores3[2].relevance_score=0; "Default must be 0")
End if 

// Out-of-order: response mentions doc 1 before doc 0
var $resp4 : Text:="<document id=1>\n<answer>RELEVANT</answer>\n</document>\n"+\
"<document id=0>\n<answer>NOT_RELEVANT</answer>\n</document>"
var $scores4:=$api._parseRelevanceResponse($resp4; 2)
If (Asserted:C1132($scores4.length=2; "Must return 2 scores"))
	ASSERT:C1129($scores4[0].relevance_score=0; "Doc 0 must be NOT_RELEVANT despite appearing 2nd in response")
	ASSERT:C1129($scores4[1].relevance_score=1; "Doc 1 must be RELEVANT despite appearing 1st in response")
End if 

// Missing doc in response: defaults to 0
var $resp5 : Text:="<document id=0>\n<answer>RELEVANT</answer>\n</document>"
var $scores5:=$api._parseRelevanceResponse($resp5; 3)
If (Asserted:C1132($scores5.length=3; "Must return 3 scores"))
	ASSERT:C1129($scores5[0].relevance_score=1; "Doc 0 must be RELEVANT")
	ASSERT:C1129($scores5[1].relevance_score=0; "Missing doc 1 must default to 0")
	ASSERT:C1129($scores5[2].relevance_score=0; "Missing doc 2 must default to 0")
End if 

// Case insensitive: "relevant" lowercase should still match
var $resp6 : Text:="<document id=0>\n<answer>relevant</answer>\n</document>"
var $scores6:=$api._parseRelevanceResponse($resp6; 1)
If (Asserted:C1132($scores6.length=1; "Must return 1 score"))
	ASSERT:C1129($scores6[0].relevance_score=1; "Lowercase 'relevant' must score 1")
End if 

// MARK: - Integration test (requires live OpenAI API key)
var $openai:=TestOpenAI()
If ($openai=Null:C1517)
	return   // skip integration test
End if 

var $liveClient:=cs:C1710.Reranker.new({apiKey: $openai.apiKey; baseURL: $openai.baseURL; type: "llm-filter"})
var $liveDocs:=["Neural networks learn by adjusting weights"; \
"The cat sat on the mat"; \
"Backpropagation computes gradients for learning"]
var $liveQuery:=cs:C1710.RerankerQuery.new({query: "How do neural networks learn?"; documents: $liveDocs})
var $liveParams:=cs:C1710.RerankerParameters.new({model: cs:C1710._TestModels.new($openai).chats})
var $liveResult:=$liveClient.create($liveQuery; $liveParams)

If (Asserted:C1132(Bool:C1537($liveResult.success); "LLM filter must succeed: "+JSON Stringify:C1217($liveResult)))
	var $liveRanked:=$liveResult.results
	If (Asserted:C1132($liveRanked#Null:C1517; "Results must not be null"))
		ASSERT:C1129($liveRanked.length=$liveDocs.length; "Must return all documents")
		ASSERT:C1129(Value type:C1509($liveRanked[0].relevance_score)=Is real:K8:4\
			 || (Value type:C1509($liveRanked[0].relevance_score)=Is text:K8:3); "Must have relevance_score")
		ASSERT:C1129(($liveRanked[0].relevance_score=0) || ($liveRanked[0].relevance_score=1); "Score must be 0 or 1")
		ASSERT:C1129($liveRanked[0].rank=1; "First result must have rank 1")
	End if 
End if 
