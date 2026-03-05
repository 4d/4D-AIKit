//%attributes = {}
// Tests for API-based reranking (RerankerAPI)
// Includes: pure logic tests (no HTTP) and optional integration tests.
//
// For integration tests, configure a "cohere" provider in your environment
// with baseURL "https://api.cohere.ai/v1" and your Cohere API key.

// MARK: - Pure logic tests (no HTTP required)

// Test _providerConfig() for each type
var $dummy:=cs:C1710.Reranker.new({type: ""})
If (Asserted:C1132(OB Instance of:C1731($dummy._rerank; cs:C1710.RerankerAPI); "Default must use RerankerAPI"))
	
	// Default / Cohere / Jina: /rerank, documents, top_n, return_documents, results key, relevance_score
	var $cfg:=$dummy._rerank._providerConfig()
	ASSERT:C1129($cfg.path="/rerank"; "default path must be /rerank")
	ASSERT:C1129($cfg.docKey="documents"; "default docKey must be documents")
	ASSERT:C1129(Not:C34(Bool:C1537($cfg.wrapDocs)); "default must not wrap docs")
	ASSERT:C1129($cfg.topKey="top_n"; "default topKey must be top_n")
	ASSERT:C1129(Bool:C1537($cfg.sendReturnDocs); "default must send return_documents")
	ASSERT:C1129($cfg.returnDocsKey="return_documents"; "default returnDocsKey")
	ASSERT:C1129($cfg.resultsKey="results"; "default resultsKey must be results")
	ASSERT:C1129($cfg.scoreKey="relevance_score"; "default scoreKey must be relevance_score")
	ASSERT:C1129(Not:C34(Bool:C1537($cfg.pineconeAuth)); "default must not use pinecone auth")
	
	// Voyage: top_k, no return_documents, data key
	var $cfgV:=cs:C1710.Reranker.new({type: "voyage"})._rerank._providerConfig()
	ASSERT:C1129($cfgV.path="/rerank"; "voyage path")
	ASSERT:C1129($cfgV.topKey="top_k"; "voyage topKey must be top_k")
	ASSERT:C1129(Not:C34(Bool:C1537($cfgV.sendReturnDocs)); "voyage must not send return_documents")
	ASSERT:C1129($cfgV.resultsKey="data"; "voyage resultsKey must be data")
	ASSERT:C1129($cfgV.scoreKey="relevance_score"; "voyage scoreKey")
	
	// Mixedbread: /reranking, input, top_k, return_input, data, score
	var $cfgM:=cs:C1710.Reranker.new({type: "mixedbread.ai"})._rerank._providerConfig()
	ASSERT:C1129($cfgM.path="/reranking"; "mixedbread path must be /reranking")
	ASSERT:C1129($cfgM.docKey="input"; "mixedbread docKey must be input")
	ASSERT:C1129($cfgM.topKey="top_k"; "mixedbread topKey must be top_k")
	ASSERT:C1129($cfgM.returnDocsKey="return_input"; "mixedbread returnDocsKey")
	ASSERT:C1129($cfgM.resultsKey="data"; "mixedbread resultsKey must be data")
	ASSERT:C1129($cfgM.scoreKey="score"; "mixedbread scoreKey must be score")
	
	// Pinecone: [{text}] docs, data key, score, pineconeAuth
	var $cfgP:=cs:C1710.Reranker.new({type: "pinecone"})._rerank._providerConfig()
	ASSERT:C1129($cfgP.docKey="documents"; "pinecone docKey")
	ASSERT:C1129(Bool:C1537($cfgP.wrapDocs); "pinecone must wrap docs as {text} objects")
	ASSERT:C1129(Not:C34(Bool:C1537($cfgP.sendReturnDocs)); "pinecone must not send return_documents")
	ASSERT:C1129($cfgP.resultsKey="data"; "pinecone resultsKey must be data")
	ASSERT:C1129($cfgP.scoreKey="score"; "pinecone scoreKey must be score")
	ASSERT:C1129(Bool:C1537($cfgP.pineconeAuth); "pinecone must use pinecone auth")
	
	// TEI: texts, return_text, flat array (empty resultsKey), score
	var $cfgT:=cs:C1710.Reranker.new({type: "text-embeddings-inference"})._rerank._providerConfig()
	ASSERT:C1129($cfgT.docKey="texts"; "TEI docKey must be texts")
	ASSERT:C1129($cfgT.returnDocsKey="return_text"; "TEI returnDocsKey")
	ASSERT:C1129($cfgT.resultsKey=""; "TEI resultsKey must be empty (flat array)")
	ASSERT:C1129($cfgT.scoreKey="score"; "TEI scoreKey must be score")
	
	// Isaacus: /rerankings, texts, results, score
	var $cfgIs:=cs:C1710.Reranker.new({type: "isaacus"})._rerank._providerConfig()
	ASSERT:C1129($cfgIs.path="/rerankings"; "isaacus path must be /rerankings")
	ASSERT:C1129($cfgIs.docKey="texts"; "isaacus docKey must be texts")
	ASSERT:C1129($cfgIs.resultsKey="results"; "isaacus resultsKey must be results")
	ASSERT:C1129($cfgIs.scoreKey="score"; "isaacus scoreKey must be score")
	
End if 

// MARK: - Type auto-detection tests

// Auto-detect type from well-known baseURL
var $autoCohere:=cs:C1710.Reranker.new({baseURL: "https://api.cohere.ai/v1"; apiKey: "test"})
ASSERT:C1129($autoCohere.type="cohere"; "Must auto-detect cohere type from baseURL")

var $autoPinecone:=cs:C1710.Reranker.new({baseURL: "https://api.pinecone.io"; apiKey: "test"})
ASSERT:C1129($autoPinecone.type="pinecone"; "Must auto-detect pinecone type from baseURL")

var $autoVoyage:=cs:C1710.Reranker.new({baseURL: "https://api.voyageai.com/v1"; apiKey: "test"})
ASSERT:C1129($autoVoyage.type="voyage"; "Must auto-detect voyage type from baseURL")

// Unknown baseURL → empty type
var $unknown:=cs:C1710.Reranker.new({baseURL: "http://localhost:8080"; apiKey: "test"})
ASSERT:C1129(Length:C16($unknown.type)=0; "Unknown baseURL must result in empty type")

// Explicit type accepted
var $explicit:=cs:C1710.Reranker.new({type: "jina"; apiKey: "test"})
ASSERT:C1129($explicit.type="jina"; "Must accept explicit type")

// MARK: - Score normalization tests (no HTTP)

// Test score normalization in RerankerResult (no HTTP)
var $resultObj:=cs:C1710.RerankerResult.new()
$resultObj._parsed:={results: [{index: 0; relevance_score: 5.2}; {index: 1; relevance_score: -1.3}]}
var $normalized:=$resultObj.results
If (Asserted:C1132($normalized.length=2; "Must have 2 normalized results"))
	ASSERT:C1129($normalized[0].relevance_score<=1; "Sigmoid must bring score <= 1 (was 5.2)")
	ASSERT:C1129($normalized[0].relevance_score>=0; "Sigmoid must bring score >= 0")
	ASSERT:C1129($normalized[1].relevance_score<=1; "Sigmoid must bring score <= 1 (was -1.3)")
	ASSERT:C1129($normalized[1].relevance_score>=0; "Sigmoid must bring score >= 0")
End if 

// Test score key mapping: 'score' → 'relevance_score' (Pinecone/Mixedbread format)
var $resultObj2:=cs:C1710.RerankerResult.new()
$resultObj2._parsed:={results: [{index: 0; score: 0.95}; {index: 1; score: 0.3}]}
var $mapped:=$resultObj2.results
If (Asserted:C1132($mapped.length=2; "Must have 2 mapped results"))
	ASSERT:C1129($mapped[0].relevance_score=0.95; "score key must be mapped to relevance_score")
	ASSERT:C1129($mapped[1].relevance_score=0.3; "score key must be mapped to relevance_score")
	ASSERT:C1129($mapped[0].relevance_score=0.95; "In-range scores must not be sigmoid-normalized")
End if 

// Test with null scores (RankGPT-style, no sigmoid)
var $resultObj3:=cs:C1710.RerankerResult.new()
$resultObj3._parsed:={results: [{index: 1; rank: 1}; {index: 0; rank: 2}]}
var $rankOnly:=$resultObj3.results
If (Asserted:C1132($rankOnly.length=2; "Must have 2 rank-only results"))
	ASSERT:C1129($rankOnly[0].rank=1; "Rank must be preserved")
	ASSERT:C1129($rankOnly[0].index=1; "Index must be preserved")
	ASSERT:C1129($rankOnly[0].relevance_score=Null:C1517; "No relevance_score for rank-only results")
End if 

// MARK: - Integration tests (loop over all configured reranker providers)
// Each provider in this collection must have: type, model.
// The test skips providers whose apiKey is not configured in AIProviders.json.

var $rerankerProviders:=[\
{type: "cohere"; model: "rerank-v3.5"}; \
{type: "jina"; model: "jina-reranker-v2-base-multilingual"}; \
{type: "voyage"; model: "rerank-2"}; \
{type: "mixedbread.ai"; model: "mixedbread-ai/mxbai-rerank-large-v1"}; \
{type: "pinecone"; model: "pinecone-rerank-v0"}; \
{type: "isaacus"; model: "kanon-universal-classifier"}\
]

var $providers:=cs:C1710.OpenAIProviders.new()
var $docs:=["Neural networks learn by adjusting weights"; "The sky is blue today"; \
"Backpropagation computes gradients for learning"]
var $prov : Object
For each ($prov; $rerankerProviders)
	var $provData:=$providers.get($prov.type)
	
	If ($provData=Null:C1517) || (Length:C16(String:C10($provData.apiKey))=0)
		continue  // provider not configured, skip
	End if 
	
	var $reranker:=cs:C1710.Reranker.new({apiKey: $provData.apiKey; baseURL: $provData.baseURL; type: $prov.type})
	var $query2:=cs:C1710.RerankerQuery.new({query: "How do neural networks learn?"; documents: $docs})
	var $params2:=cs:C1710.RerankerParameters.new({model: $prov.model; top_n: 2})
	var $result2:=$reranker.create($query2; $params2)
	
	If (Asserted:C1132(Bool:C1537($result2.success); $prov.type+" rerank must succeed: "+JSON Stringify:C1217($result2)))
		var $results2:=$result2.results
		If (Asserted:C1132($results2#Null:C1517; $prov.type+" results must not be null"))
			If (Asserted:C1132($results2.length>0; $prov.type+" must have at least one result"))
				ASSERT:C1129(Value type:C1509($results2[0].index)=Is real:K8:4; $prov.type+" result must have numeric index")
				ASSERT:C1129($results2[0].relevance_score#Null:C1517; $prov.type+" result must have relevance_score")
				ASSERT:C1129($results2[0].relevance_score>=0; $prov.type+" relevance score must be >= 0")
				ASSERT:C1129($results2[0].relevance_score<=1; $prov.type+" relevance score must be <= 1")
				ASSERT:C1129($results2.length<=2; $prov.type+" top_n=2 must be respected")
			End if 
		End if 
	End if 
End for each 
