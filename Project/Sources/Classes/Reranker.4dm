property rerank : cs:C1710.RerankerAPI
property _client : cs:C1710.OpenAI

Function _isObjectDelegate($object : Variant) : Boolean
	
	return (Value type:C1509($object)=Is object:K8:27) && ($object#Null:C1517) && (OB Instance of:C1731($object; cs:C1710.OpenAI))
	
Class constructor( ...  : Variant)
	var $parameters:=Copy parameters:C1790()
	
	Case of 
		: ($parameters.length=0)
			This:C1470._client:=cs:C1710.OpenAI.new()
		: (This:C1470._isObjectDelegate($parameters[0]))
			If ($parameters.length=2) && (Value type:C1509($parameters[1])=Is object:K8:27)
				This:C1470._client:=OB Copy:C1225($parameters[0])
				This:C1470._client._configureParameters($parameters[1])  //override
			Else 
				This:C1470._client:=$parameters[0]  //shallow copy
			End if 
		: ($parameters.length=2)
			This:C1470._client:=cs:C1710.OpenAI.new($parameters[0]; $parameters[1])
		: ($parameters.length=1)
			This:C1470._client:=cs:C1710.OpenAI.new($parameters[0])
	End case 
	
	This:C1470.rerank:=cs:C1710.RerankerAPI.new(This:C1470._client)