Class extends OpenAIResult

Class constructor
	
	Super:C1705()
	
Function _sigmoid($element : Object)
	
	$element.result:={index: $element.value.index; relevance_score: 1/(1+Exp:C21(-$element.value.relevance_score))}
	
Function get results : Collection
	var $body:=This:C1470._objectBody()
	var $results : Collection
	
	Case of 
		: (Value type:C1509($body.results)=Is collection:K8:32)
			$results:=$body.results
		: (Value type:C1509($body.data)=Is collection:K8:32)
			$results:=$body.data
			// TEI returns a flat JSON array — _objectBody() returns Null for collection bodies
		: ($body=Null:C1517) && (This:C1470.request#Null:C1517)\
			 && (This:C1470.request.response#Null:C1517)\
			 && (Value type:C1509(This:C1470.request.response.body)=Is collection:K8:32)
			$results:=This:C1470.request.response.body
		Else 
			$results:=[]
	End case 
	
	// Normalize: map 'score' → 'relevance_score' for providers that use a different key
	// Also preserves 'rank' and 'index'; leaves relevance_score as Null when absent (RankGPT)
	$results:=$results.map(Formula:C1597({index: $1.value.index; \
		relevance_score: ($1.value.relevance_score#Null:C1517) ? $1.value.relevance_score : $1.value.score; \
		rank: $1.value.rank}))
	
	// Apply sigmoid when any non-null score is outside [0, 1]
	// Null scores (RankGPT listwise) are skipped gracefully
	If ($results.some(Formula:C1597($1.value.relevance_score#Null:C1517\
		 && (($1.value.relevance_score>1) || ($1.value.relevance_score<0)))))
		$results:=$results.map(This:C1470._sigmoid)
	End if 
	
	return $results
	