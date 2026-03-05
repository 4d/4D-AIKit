// Listwise LLM reranker using permutation instructions (RankGPT pattern).
// Mirrors: rerankers/rerankers/models/rankgpt_rankers.py
// Uses chat/completions endpoint — no scores, returns rank order only.

Class extends RerankerAPI

Class constructor($client : cs:C1710.OpenAI; $type : Text)
	Super:C1705($client; $type)
	
	// Build chat messages for permutation ranking.
	// Mirrors Python: get_prefix_prompt() + create_permutation_instruction() + get_post_prompt()
Function _buildMessages($query : Text; $docs : Collection) : Collection
	var $num : Integer:=$docs.length
	var $messages : Collection:=[]
	
	// System prefix (Python get_prefix_prompt)
	$messages.push({role: "system"; content: \
		"You are RankGPT, an intelligent assistant that can rank passages based on their relevancy to the query."})
	$messages.push({role: "user"; content: \
		"I will provide you with "+String:C10($num)+" passages, each indicated by number identifier []. \nRank the passages based on their relevance to query: "+$query+"."})
	$messages.push({role: "assistant"; content: "Okay, please provide the passages."})
	
	// Document pairs: each doc gets user + assistant acknowledgement
	var $i : Integer
	For ($i; 0; $num-1)
		var $text : Text
		If (Value type:C1509($docs[$i])=Is text:K8:3)
			$text:=$docs[$i]
		Else 
			$text:=$docs[$i].text || String:C10($docs[$i])
		End if 
		// Truncate to 300 words
		var $words:=Split string:C1554($text; " ")
		If ($words.length>300)
			$text:=$words.slice(0; 300).join(" ")
		End if 
		$messages.push({role: "user"; content: "["+String:C10($i+1)+"] "+$text})
		$messages.push({role: "assistant"; content: "Received passage ["+String:C10($i+1)+"]."})
	End for 
	
	// Final ranking request (Python get_post_prompt)
	$messages.push({role: "user"; content: \
		"Search Query: "+$query+". \nRank the "+String:C10($num)+" passages above based on their relevance to the search query. The passages should be listed in descending order using identifiers. The most relevant passages should be listed first. The output format should be [] > [], e.g., [1] > [2]. Only response t"+"he ranking results, do not say any word or explain."})
	
	return $messages
	
	
	// Parse LLM ranking response into a 0-indexed ordered collection.
	// Mirrors Python: clean_response() + remove_duplicate() + receive_permutation()
	// Example: "[3] > [1] > [2]" with numDocs=3 → [2, 0, 1]
Function _parseRankingResponse($response : Text; $numDocs : Integer) : Collection
	var $order : Collection:=[]
	var $digitStr : Text:=""
	var $i : Integer
	var $n : Integer
	
	// Extract digit runs from response string, convert to 0-indexed
	For ($i; 1; Length:C16($response))
		var $charCode : Integer:=Character code:C91(Substring:C12($response; $i; 1))
		If ($charCode>=48) && ($charCode<=57)  // '0' to '9'
			$digitStr:=$digitStr+Substring:C12($response; $i; 1)
		Else 
			If (Length:C16($digitStr)>0)
				$n:=Num:C11($digitStr)-1  // convert 1-indexed to 0-indexed
				If ($n>=0) && ($n<$numDocs) && (Not:C34($order.includes($n)))
					$order.push($n)
				End if 
				$digitStr:=""
			End if 
		End if 
	End for 
	// Handle trailing digit run
	If (Length:C16($digitStr)>0)
		$n:=Num:C11($digitStr)-1
		If ($n>=0) && ($n<$numDocs) && (Not:C34($order.includes($n)))
			$order.push($n)
		End if 
	End if 
	
	// Append any missing indices at the end (Python's fallback)
	For ($i; 0; $numDocs-1)
		If (Not:C34($order.includes($i)))
			$order.push($i)
		End if 
	End for 
	
	return $order
	
	
	// Rerank documents using LLM permutation instructions.
	// Returns RerankerResult with rank order and no relevance scores (listwise model).
Function create($query : cs:C1710.RerankerQuery; $parameters : cs:C1710.RerankerParameters) : cs:C1710.RerankerResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.RerankerParameters)))
		$parameters:=cs:C1710.RerankerParameters.new($parameters)
	End if 
	
	var $docs:=$query.documents
	var $messages:=This:C1470._buildMessages($query.query; $docs)
	
	var $model : Text:=$parameters.model
	If (Length:C16($model)=0)
		$model:="gpt-4o-mini"
	End if 
	
	var $chatBody:={model: $model; messages: $messages; temperature: 0}
	
	// Post to chat/completions using the inherited HTTP client
	var $chatResult:=This:C1470._client._post("/chat/completions"; $chatBody; $parameters; cs:C1710.OpenAIResult)
	
	// Build the RerankerResult with synthetic _parsed data
	var $result:=cs:C1710.RerankerResult.new()
	$result.request:=$chatResult.request
	
	If ($chatResult.success)
		var $chatBody2 : Object:=$chatResult._objectBody()
		var $content : Text
		If ($chatBody2#Null:C1517) && (Value type:C1509($chatBody2.choices)=Is collection:K8:32)\
			 && ($chatBody2.choices.length>0)
			$content:=$chatBody2.choices[0].message.content || ""
		End if 
		var $rankOrder:=This:C1470._parseRankingResponse($content; $docs.length)
		
		// Build ranked results: {index, rank} — no relevance_score (listwise)
		var $ranked : Collection:=[]
		var $j : Integer
		For ($j; 0; $rankOrder.length-1)
			$ranked.push({index: $rankOrder[$j]; rank: $j+1})
		End for 
		
		$result._parsed:={results: $ranked}
	End if 
	
	return $result
	