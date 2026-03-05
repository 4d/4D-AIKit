//%attributes = {}
// Tests for LLM-based listwise reranking (RerankerRankGPTAPI)
// Includes: pure logic tests (no HTTP) and optional integration test.
//
// Integration test requires an OpenAI-compatible API key (uses TestOpenAI() config).

// MARK: - Constructor routing

// type "rankgpt" must instantiate RerankerRankGPTAPI
var $client:=cs:C1710.Reranker.new({type: "rankgpt"})
ASSERT:C1129($client.type="rankgpt"; "type must be rankgpt")
ASSERT:C1129(OB Instance of:C1731($client._rerank; cs:C1710.RerankerRankGPTAPI); \
"_rerank must be RerankerRankGPTAPI when type is rankgpt")

// Any other type → RerankerAPI
var $apiClient:=cs:C1710.Reranker.new({type: "cohere"})
ASSERT:C1129(Not:C34(OB Instance of:C1731($apiClient._rerank; cs:C1710.RerankerRankGPTAPI)); \
"Non-rankgpt type must use RerankerAPI")

// MARK: - _buildMessages() tests
var $api : cs:C1710.RerankerRankGPTAPI:=$client._rerank
var $docs2:=["First document about AI"; "Second document about weather"]
var $msgs:=$api._buildMessages("What is AI?"; $docs2)

// 2 docs → 3 prefix + 4 doc pairs (2×2) + 1 final = 8 messages
If (Asserted:C1132($msgs.length=8; "2 docs must produce 8 messages, got: "+String:C10($msgs.length)))
	ASSERT:C1129($msgs[0].role="system"; "First message must be system")
	ASSERT:C1129(Length:C16($msgs[0].content)>0; "System message must have content")
	ASSERT:C1129($msgs[1].role="user"; "Second message must be user")
	ASSERT:C1129(Position:C15("2"; $msgs[1].content)>0; "User intro must mention count (2)")
	ASSERT:C1129($msgs[2].role="assistant"; "Third message must be assistant")
	ASSERT:C1129($msgs[3].role="user"; "Doc 1 message must be user")
	ASSERT:C1129(Position:C15("[1]"; $msgs[3].content)>0; "Doc 1 must start with [1]")
	ASSERT:C1129($msgs[4].role="assistant"; "Doc 1 ack must be assistant")
	ASSERT:C1129(Position:C15("[1]"; $msgs[4].content)>0; "Doc 1 ack must reference [1]")
	ASSERT:C1129($msgs[5].role="user"; "Doc 2 message must be user")
	ASSERT:C1129(Position:C15("[2]"; $msgs[5].content)>0; "Doc 2 must start with [2]")
	ASSERT:C1129($msgs[6].role="assistant"; "Doc 2 ack must be assistant")
	ASSERT:C1129($msgs[7].role="user"; "Final prompt must be user")
	ASSERT:C1129(Position:C15("[]"; $msgs[7].content)>0; "Final prompt must contain [] format example")
End if 

// 1 doc → 3 prefix + 2 doc pair + 1 final = 6 messages
var $msgs1:=$api._buildMessages("query"; ["single doc"])
ASSERT:C1129($msgs1.length=6; "1 doc must produce 6 messages, got: "+String:C10($msgs1.length))

// Truncation: doc with >300 words should be truncated
var $longWords : Collection:=[]
var $w : Integer
For ($w; 1; 400)
	$longWords.push("word"+String:C10($w))
End for 
var $longDoc:=$longWords.join(" ")
var $msgsLong:=$api._buildMessages("q"; [$longDoc])
var $docMsg : Text:=$msgsLong[3].content
var $docWords:=Split string:C1554($docMsg; " ")
// "[1] " prefix = 1 word + up to 300 content words
ASSERT:C1129($docWords.length<=303; "Doc content must be truncated to ~300 words (got: "+String:C10($docWords.length)+")")

// MARK: - _parseRankingResponse() tests

// Basic case: "[3] > [1] > [2]" with 3 docs → [2, 0, 1] (0-indexed)
var $order:=$api._parseRankingResponse("[3] > [1] > [2]"; 3)
If (Asserted:C1132($order.length=3; "Must return all 3 indices"))
	ASSERT:C1129($order[0]=2; "First ranked doc must be index 2 (was [3])")
	ASSERT:C1129($order[1]=0; "Second ranked doc must be index 0 (was [1])")
	ASSERT:C1129($order[2]=1; "Third ranked doc must be index 1 (was [2])")
End if 

// Deduplication: "[1] > [1] > [2]" with 2 docs → [0, 1]
var $orderDup:=$api._parseRankingResponse("[1] > [1] > [2]"; 2)
If (Asserted:C1132($orderDup.length=2; "Deduplicated result must have 2 items"))
	ASSERT:C1129($orderDup[0]=0; "First must be index 0")
	ASSERT:C1129($orderDup[1]=1; "Second must be index 1")
End if 

// Missing indices fallback: "[2]" with 3 docs → 1 first, then 0 and 2 appended
var $orderPart:=$api._parseRankingResponse("[2]"; 3)
If (Asserted:C1132($orderPart.length=3; "Partial response must be completed to 3"))
	ASSERT:C1129($orderPart[0]=1; "Explicit rank [2] → index 1 first")
	ASSERT:C1129($orderPart.includes(0); "Missing index 0 must be appended")
	ASSERT:C1129($orderPart.includes(2); "Missing index 2 must be appended")
End if 

// Out-of-range indices ignored: "[5]" with 3 docs → all appended in order
var $orderOOB:=$api._parseRankingResponse("[5]"; 3)
If (Asserted:C1132($orderOOB.length=3; "Out-of-range response must fall back to all indices"))
	ASSERT:C1129($orderOOB[0]=0; "Fallback: index 0 first")
	ASSERT:C1129($orderOOB[1]=1; "Fallback: index 1 second")
	ASSERT:C1129($orderOOB[2]=2; "Fallback: index 2 third")
End if 

// Empty response: all indices in order
var $orderEmpty:=$api._parseRankingResponse(""; 2)
If (Asserted:C1132($orderEmpty.length=2; "Empty response must produce all indices"))
	ASSERT:C1129($orderEmpty[0]=0; "Empty fallback: index 0 first")
	ASSERT:C1129($orderEmpty[1]=1; "Empty fallback: index 1 second")
End if 

// MARK: - Integration test (requires live OpenAI API key)
var $openai:=TestOpenAI()
If ($openai=Null:C1517)
	return   // skip integration test
End if 

var $liveClient:=cs:C1710.Reranker.new({apiKey: $openai.apiKey; baseURL: $openai.baseURL; type: "rankgpt"})
var $liveDocs:=["Deep learning uses neural networks for learning"; \
"The weather forecast shows rain tomorrow"; \
"Backpropagation updates weights to minimize loss"]
var $liveQuery:=cs:C1710.RerankerQuery.new({query: "How do neural networks learn?"; documents: $liveDocs})
var $liveParams:=cs:C1710.RerankerParameters.new({model: cs:C1710._TestModels.new($openai).chats})
var $liveResult:=$liveClient.create($liveQuery; $liveParams)

If (Asserted:C1132(Bool:C1537($liveResult.success); "RankGPT must succeed: "+JSON Stringify:C1217($liveResult)))
	var $liveRanked:=$liveResult.results
	If (Asserted:C1132($liveRanked#Null:C1517; "RankGPT results must not be null"))
		If (Asserted:C1132($liveRanked.length=$liveDocs.length; \
			"RankGPT must return all "+String:C10($liveDocs.length)+" docs ranked"))
			ASSERT:C1129(Value type:C1509($liveRanked[0].index)=Is real:K8:4; "Result must have numeric index")
			ASSERT:C1129($liveRanked[0].rank=1; "First result must have rank 1")
			ASSERT:C1129($liveRanked[0].relevance_score=Null:C1517; "RankGPT must have no relevance_score")
			var $indices:=$liveRanked.extract("index")
			ASSERT:C1129($indices.distinct().length=$liveDocs.length; "All indices must be unique")
		End if 
	End if 
End if 
