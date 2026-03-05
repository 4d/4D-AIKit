Class extends OpenAIAPIResource

property _type : Text

Class constructor($client : cs:C1710.OpenAI; $type : Text)
	Super:C1705($client)
	This:C1470._type:=$type
	
	// Returns provider-specific configuration mirroring Python api_rankers.py lookup dicts.
Function _providerConfig() : Object
	var $p : Text:=Lowercase:C14(This:C1470._type)
	var $c : Object:={}
	
	// --- URL path ---
	Case of 
		: ($p="mixedbread.ai")
			$c.path:="/reranking"
		: ($p="isaacus")
			$c.path:="/rerankings"
		: (($p="cohere") && (Position:C15("compatibility"; This:C1470._client.baseURL)>1))
			$c.path:="/../../v1/rerank"
		Else 
			$c.path:="/rerank"
	End case 
	
	// --- Document body key (Python DOCUMENT_KEY_MAPPING) ---
	Case of 
		: ($p="mixedbread.ai")
			$c.docKey:="input"
		: ($p="text-embeddings-inference") || ($p="isaacus")
			$c.docKey:="texts"
		Else 
			$c.docKey:="documents"
	End case 
	
	// --- Wrap docs as [{text: ...}] objects instead of plain strings (Pinecone only) ---
	$c.wrapDocs:=($p="pinecone")
	
	// --- Count key: top_n vs top_k ---
	If ($p="voyage") || ($p="mixedbread.ai")
		$c.topKey:="top_k"
	Else 
		$c.topKey:="top_n"
	End if 
	
	// --- Return-documents key and whether to send it (Python RETURN_DOCUMENTS_KEY_MAPPING) ---
	Case of 
		: ($p="mixedbread.ai")
			$c.returnDocsKey:="return_input"
			$c.sendReturnDocs:=True:C214
		: ($p="text-embeddings-inference")
			$c.returnDocsKey:="return_text"
			$c.sendReturnDocs:=True:C214
		: ($p="voyage") || ($p="pinecone") || ($p="isaacus")
			$c.sendReturnDocs:=False:C215
		Else 
			$c.returnDocsKey:="return_documents"
			$c.sendReturnDocs:=True:C214
	End case 
	
	// --- Results wrapper key in response (Python RESULTS_KEY_MAPPING) ---
	Case of 
		: ($p="voyage") || ($p="mixedbread.ai") || ($p="pinecone")
			$c.resultsKey:="data"
		: ($p="text-embeddings-inference")
			$c.resultsKey:=""  // flat array
		Else 
			$c.resultsKey:="results"
	End case 
	
	// --- Score field name inside each result (Python SCORE_KEY_MAPPING) ---
	If ($p="mixedbread.ai") || ($p="pinecone") || ($p="text-embeddings-inference") || ($p="isaacus")
		$c.scoreKey:="score"
	Else 
		$c.scoreKey:="relevance_score"
	End if 
	
	// --- Pinecone uses Api-Key header instead of Authorization: Bearer ---
	$c.pineconeAuth:=($p="pinecone")
	
	return $c
	
	
Function create($query : cs:C1710.RerankerQuery; $parameters : cs:C1710.RerankerParameters) : cs:C1710.RerankerResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.RerankerParameters)))
		$parameters:=cs:C1710.RerankerParameters.new($parameters)
	End if 
	
	var $cfg:=This:C1470._providerConfig()
	
	// Start with base body (model from parameters)
	var $body:=$parameters.body()
	
	// Rename top_n → top_k when provider expects it
	If ($cfg.topKey#"top_n")
		$body[$cfg.topKey]:=$body.top_n
		OB REMOVE:C1226($body; "top_n")
	End if 
	
	// Attach query
	$body.query:=$query.query
	
	// Attach documents under the correct key, with correct format
	var $docs:=$query.documents
	If ($cfg.wrapDocs)
		// Pinecone expects [{text: "..."}] objects
		$body[$cfg.docKey]:=$docs.map(Formula:C1597(\
			{text: (Value type:C1509($1.value)=Is text:K8:3) ? String:C10($1.value) : String:C10($1.value.text)}))
	Else 
		$body[$cfg.docKey]:=$docs.map(Formula:C1597(\
			(Value type:C1509($1.value)=Is text:K8:3) ? $1.value : $1.value.text))
	End if 
	
	// Optionally ask provider to return documents in response
	If ($cfg.sendReturnDocs)
		$body[$cfg.returnDocsKey]:=True:C214
	End if 
	
	// Pinecone: inject Api-Key header and API version (temporarily override customHeaders)
	var $savedCustomHeaders : Object:=Null:C1517
	If ($cfg.pineconeAuth)
		$savedCustomHeaders:=OB Copy:C1225(This:C1470._client.customHeaders || {})
		If (This:C1470._client.customHeaders=Null:C1517)
			This:C1470._client.customHeaders:={}
		End if 
		This:C1470._client.customHeaders["Api-Key"]:=This:C1470._client.apiKey
		This:C1470._client.customHeaders["X-Pinecone-API-Version"]:="2024-10"
	End if 
	
	var $result:=This:C1470._client._post($cfg.path; $body; $parameters; cs:C1710.RerankerResult)
	
	// Restore customHeaders after Pinecone call
	If ($cfg.pineconeAuth)
		This:C1470._client.customHeaders:=$savedCustomHeaders
	End if 
	
	return $result
	