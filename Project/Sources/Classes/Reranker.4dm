property rerank : cs:C1710.RerankerAPI

Class extends OpenAI

Class constructor( ...  : Variant)
	
	var $parameters : Collection:=Copy parameters:C1790
	
	//can't use call or apply here
	Case of 
		: ($parameters.length>1)
			Super:C1705($parameters[0]; $parameters[1])
		: ($parameters.length>0)
			Super:C1705($parameters[0])
		Else 
			Super:C1705()
	End case 
	
	var $properyToRemove : Text
	For each ($properyToRemove; ["embeddings"; "chat"; "images"; "files"; "moderations"])
		OB REMOVE:C1226(This:C1470; $properyToRemove)
	End for each 
	
	This:C1470.rerank:=cs:C1710.RerankerAPI.new(This:C1470)