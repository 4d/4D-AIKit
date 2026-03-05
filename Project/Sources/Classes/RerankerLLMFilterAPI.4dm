// LLM-based binary relevance filter.
// Mirrors: rerankers/rerankers/models/llm_relevance_filter.py
// Uses chat/completions endpoint — returns binary RELEVANT/NOT_RELEVANT scores (1.0 / 0.0).

Class extends RerankerAPI

Class constructor($client : cs:C1710.OpenAI; $type : Text)
	Super:C1705($client; $type)
	
	// Format documents as XML blocks: <document id=0>text</document>
Function _formatDocInputs($docs : Collection) : Text
	var $parts : Collection:=[]
	var $i : Integer
	For ($i; 0; $docs.length-1)
		var $text : Text
		If (Value type:C1509($docs[$i])=Is text:K8:3)
			$text:=String:C10($docs[$i])
		Else 
			$text:=String:C10($docs[$i].text)
		End if 
		$parts.push("<document id="+String:C10($i)+">\n"+$text+"\n</document>")
	End for 
	return $parts.join("\n")
	
	// Build the full user prompt with XML-tagged query and documents.
	// Faithful to Python DEFAULT_PROMPT_TEMPLATE.
Function _buildPrompt($query : Text; $docsXML : Text) : Text
	var $p : Text
	$p:="<instructions>\n"
	$p+="Think carefully about whether the following documents would be useful to answer the query.\n"
	$p+="For each document, explain your reasoning and then provide a binary decision (RELEVANT or NOT_RELEVANT). "
	$p+="If a document is partially relevant, you will assign the RELEVANT label.\n\n"
	$p+="The documents will be given to you in the following format:\n\n"
	$p+="<input>\n<query>\nText of the query.\n</query>\n\n<documents>\n"
	$p+="<document id=0>\nText of the first document.\n</document>\n"
	$p+="<document id=1>\nText of the second document.\n</document>\n"
	$p+="</documents>\n</input>\n"
	$p+="And you will respond in the following format:\n\n"
	$p+="<document id=X>\n<explanation>\nYour reasoning regarding the document's relevance.\n</explanation>\n"
	$p+="<answer>\nRELEVANT or NOT_RELEVANT\n</answer>\n"
	$p+="</document>\n"
	$p+="</instructions>\n\n"
	$p+="Here is the query and documents:\n\n"
	$p+="<input>\n<query>\n"+$query+"\n</query>\n\n<documents>\n"
	$p+=$docsXML+"\n</documents>\n</input>\n\n"
	$p+="Analyse the above documents and provide your responses using the provided format. "
	$p+="You must assign either the RELEVANT or NOT_RELEVANT label, no other option is permitted."
	return $p
	
	// Parse the LLM response to extract per-document RELEVANT/NOT_RELEVANT decisions.
	// Returns collection of {index: Integer; relevance_score: 1 or 0}.
	// Documents not found in the response default to 0 (NOT_RELEVANT).
Function _parseRelevanceResponse($response : Text; $numDocs : Integer) : Collection
	// Initialize all scores to 0 (NOT_RELEVANT)
	var $scores : Collection:=[]
	var $i : Integer
	For ($i; 0; $numDocs-1)
		$scores.push({index: $i; relevance_score: 0})
	End for 
	
	var $searchFrom : Integer:=1
	var $docTag : Text:="<document id="
	var $answerOpen : Text:="<answer>"
	var $answerClose : Text:="</answer>"
	
	var $docPos : Integer:=Position:C15($docTag; $response; $searchFrom)
	var $numStart : Integer
	var $digitStr : Text
	var $j : Integer
	var $charCode : Integer
	var $isDigit : Boolean
	var $docId : Integer
	var $answerPos : Integer
	var $valueStart : Integer
	var $closePos : Integer
	var $label : Text
	
	While ($docPos>0)
		// Extract numeric ID after "id="
		$numStart:=$docPos+Length:C16($docTag)
		$digitStr:=""
		$j:=$numStart
		$isDigit:=True:C214
		While ($j<=Length:C16($response)) && ($isDigit)
			$charCode:=Character code:C91(Substring:C12($response; $j; 1))
			If ($charCode>=48) && ($charCode<=57)
				$digitStr:=$digitStr+Substring:C12($response; $j; 1)
				$j:=$j+1
			Else 
				$isDigit:=False:C215
			End if 
		End while 
		
		$docId:=Num:C11($digitStr)
		
		// Find <answer> tag after this doc opening tag
		$answerPos:=Position:C15($answerOpen; $response; $docPos)
		If ($answerPos>0)
			$valueStart:=$answerPos+Length:C16($answerOpen)
			$closePos:=Position:C15($answerClose; $response; $valueStart)
			If ($closePos>0)
				$label:=Uppercase:C13(Replace string:C233(Replace string:C233(\
					Substring:C12($response; $valueStart; $closePos-$valueStart); " "; ""); "\n"; ""))
				If ($docId>=0) && ($docId<$numDocs)
					If ($label="RELEVANT")
						$scores[$docId].relevance_score:=1
					Else 
						$scores[$docId].relevance_score:=0
					End if 
				End if 
				$searchFrom:=$closePos+Length:C16($answerClose)
			Else 
				$searchFrom:=$docPos+1
			End if 
		Else 
			$searchFrom:=$docPos+1
		End if 
		
		$docPos:=Position:C15($docTag; $response; $searchFrom)
	End while 
	
	return $scores
	
	// POST /chat/completions with all documents batched, parse response, return RerankerResult.
Function create($query : cs:C1710.RerankerQuery; $parameters : cs:C1710.RerankerParameters) : cs:C1710.RerankerResult
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.RerankerParameters)))
		$parameters:=cs:C1710.RerankerParameters.new($parameters)
	End if 
	
	var $docs:=$query.documents
	var $docsXML:=This:C1470._formatDocInputs($docs)
	var $userPrompt:=This:C1470._buildPrompt($query.query; $docsXML)
	
	var $model : Text:=$parameters.model
	If (Length:C16($model)=0)
		$model:="gpt-4o-mini"
	End if 
	
	var $chatBody:={model: $model; \
		messages: [\
		{role: "system"; content: "You are a friendly AI assistant, working on document relevance filtering. "+\
		"Your task is to determine if a document is relevant to answering a given query. "+\
		"You must assign a binary RELEVANT or NOT_RELEVANT label to each document "+\
		"by carefully analysing them and the query."}; \
		{role: "user"; content: $userPrompt}]; \
		temperature: 0}
	
	var $chatResult:=This:C1470._client._post("/chat/completions"; $chatBody; $parameters; cs:C1710.OpenAIResult)
	
	var $result:=cs:C1710.RerankerResult.new()
	$result.request:=$chatResult.request
	
	If (Bool:C1537($chatResult.success))
		var $chatBody2 : Object:=$chatResult._objectBody()
		var $content : Text:=""
		If ($chatBody2#Null:C1517) && (Value type:C1509($chatBody2.choices)=Is collection:K8:32)\
			 && ($chatBody2.choices.length>0)
			$content:=String:C10($chatBody2.choices[0].message.content)
		End if 
		
		var $scores:=This:C1470._parseRelevanceResponse($content; $docs.length)
		
		// Sort: RELEVANT (1) first, then by original index for ties
		$scores:=$scores.orderByMethod(Formula:C1597(\
			($1.value.relevance_score#$1.value2.relevance_score)\
			 ? ($1.value.relevance_score>$1.value2.relevance_score)\
			 : ($1.value.index<$1.value2.index)))
		
		// Assign ranks
		var $k : Integer
		For ($k; 0; $scores.length-1)
			$scores[$k].rank:=$k+1
		End for 
		
		$result._parsed:={results: $scores}
	End if 
	
	return $result
	