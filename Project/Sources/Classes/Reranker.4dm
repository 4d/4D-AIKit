property _rerank : cs:C1710.RerankerAPI
property _client : cs:C1710.OpenAI
property _type : Text

Class constructor($config : Object)
	
	Case of 
		: (OB Instance of:C1731($config; cs:C1710.OpenAI))
			// Accept an existing OpenAI client instance
			This:C1470._client:=$config
			This:C1470._type:=This:C1470._typeFromBaseURL($config.baseURL)
			
		Else 
			// Read explicit type
			This:C1470._type:=String:C10($config.type)
			
			// Build a resolved config for the OpenAI client
			var $resolvedConfig : Object:=OB Copy:C1225($config)
			
			// Use type as provider name for OpenAIProviders credential lookup
			If (Length:C16(This:C1470._type)>0)
				$resolvedConfig.provider:=This:C1470._type
			End if 
			
			// If no baseURL from config, try well-known URL for the type
			If (Length:C16(String:C10($resolvedConfig.baseURL))=0) && (Length:C16(This:C1470._type)>0)
				var $providerData:=cs:C1710.OpenAIProviders.new().get(This:C1470._type)
				If ($providerData=Null:C1517) || (Length:C16(String:C10($providerData.baseURL))=0)
					var $wkURL:=This:C1470._wellKnownBaseURL(This:C1470._type)
					If (Length:C16($wkURL)>0)
						$resolvedConfig.baseURL:=$wkURL
					End if 
				End if 
			End if 
			
			This:C1470._client:=cs:C1710.OpenAI.new($resolvedConfig)
			
			// Auto-detect type from resolved baseURL if not explicitly set
			If (Length:C16(This:C1470._type)=0)
				This:C1470._type:=This:C1470._typeFromBaseURL(This:C1470._client.baseURL)
			End if 
			
	End case 
	
	This:C1470._rerank:=This:C1470._createHandler(This:C1470._client; This:C1470._type)
	
	// MARK: - Public API
	
Function get type() : Text
	return This:C1470._type
	
Function create($query : cs:C1710.RerankerQuery; $parameters : cs:C1710.RerankerParameters) : cs:C1710.RerankerResult
	// Model-based provider resolution: "cohere:rerank-v3" → resolve baseURL + apiKey
	If ($parameters#Null:C1517) && (Length:C16(String:C10($parameters.model))>0)
		var $resolved:=This:C1470._client._resolveModelFromBody({model: $parameters.model})
		
		If (Length:C16(String:C10($resolved.baseURL))>0)
			var $resolvedType : Text:=This:C1470._typeFromBaseURL($resolved.baseURL)
			If (Length:C16($resolvedType)=0)
				$resolvedType:=This:C1470._type
			End if 
			
			var $tempClient:=cs:C1710.OpenAI.new({apiKey: $resolved.apiKey; baseURL: $resolved.baseURL})
			var $tempHandler:=This:C1470._createHandler($tempClient; $resolvedType)
			
			var $tempParams:=cs:C1710.RerankerParameters.new({model: $resolved.model; top_n: $parameters.top_n})
			return $tempHandler.create($query; $tempParams)
		End if 
	End if 
	
	return This:C1470._rerank.create($query; $parameters)
	
	// MARK: - Private helpers
	
Function _createHandler($client : cs:C1710.OpenAI; $type : Text) : cs:C1710.RerankerAPI
	Case of 
		: ($type="rankgpt")
			return cs:C1710.RerankerRankGPTAPI.new($client; $type)
		: ($type="llm-filter")
			return cs:C1710.RerankerLLMFilterAPI.new($client; $type)
		Else 
			return cs:C1710.RerankerAPI.new($client; $type)
	End case 
	
Function _wellKnownBaseURL($type : Text) : Text
	Case of 
		: ($type="cohere")
			return "https://api.cohere.ai/v1"
		: ($type="jina")
			return "https://api.jina.ai/v1"
		: ($type="isaacus")
			return "https://api.isaacus.com/v1"
		: ($type="voyage")
			return "https://api.voyageai.com/v1"
		: ($type="mixedbread.ai")
			return "https://api.mixedbread.ai/v1"
		: ($type="pinecone")
			return "https://api.pinecone.io"
		Else 
			return ""
	End case 
	
Function _typeFromBaseURL($baseURL : Text) : Text
	var $url : Text:=Lowercase:C14(String:C10($baseURL))
	Case of 
		: (Position:C15("cohere.ai"; $url)>0)
			return "cohere"
		: (Position:C15("jina.ai"; $url)>0)
			return "jina"
		: (Position:C15("isaacus.com"; $url)>0)
			return "isaacus"
		: (Position:C15("voyageai.com"; $url)>0)
			return "voyage"
		: (Position:C15("mixedbread.ai"; $url)>0)
			return "mixedbread.ai"
		: (Position:C15("pinecone.io"; $url)>0)
			return "pinecone"
		Else 
			return ""
	End case 
	