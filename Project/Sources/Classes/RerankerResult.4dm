Class extends OpenAIResult

Class constructor
	
	Super:C1705()
	
Function _sigmoid($x : Real) : Real
	
	return 1/(1+Exp:C21(-$x))
	
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
	
	var $result : Object
	var $relevance_score : Real
	var $shouldNormalize : Boolean
	
	For each ($result; $results)
		$relevance_score:=$result.relevance_score
		Case of 
			: ($relevance_score>1)
				$shouldNormalize:=True:C214
				break
			: ($relevance_score<0)
				$shouldNormalize:=True:C214
				break
		End case 
	End for each 
	
	If ($shouldNormalize)
		For each ($result; $results)
			$result.relevance_score:=This:C1470._sigmoid($result.relevance_score)
		End for each 
	End if 
	
	return $results