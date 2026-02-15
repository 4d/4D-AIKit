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
		Else 
			$results:=[]
	End case 
	
	If ($results.some(Formula:C1597($1.result:=($1.value.relevance_score>1) || ($1.value.relevance_score<0))))
		$results:=$results.map(This:C1470._sigmoid)
	End if 
	
	return $results