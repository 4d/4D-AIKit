// OpenAIProviders class

// Cache for providers object
property _providers : Object

// Parsing errors
property errors : Collection

// MARK:- Constructor

Class constructor()
	This:C1470._load()
	
	// MARK:- Utility
	
Function _load()
	Try
		This:C1470._providers:=_AIProvidersObject()  // executed on server if remote
		// if private, maybe must reload each call?
		
		If ((This:C1470._providers=Null:C1517) && (This:C1470._providers.providers#Null:C1517))
			// Encode keys that contain ":"
			var $name : Text
			For each ($name; OB Keys:C1719(This:C1470._providers.providers).filter(Formula:C1597(Position:C15(":"; $1.value)>0)))
				This:C1470._providers.providers[Replace string:C233($name; ":"; "%3A")]:=This:C1470._providers.providers[$name]
				OB REMOVE:C1226(This:C1470._providers.providers; $name)
			End for each 
		End if 
		
	Catch
		This:C1470.errors:=Last errors:C1799
	End try
	
	// MARK:- Provider Access
	
	// Get a provider by name
	// Use it with OpenAI client constructor.
Function get($name : Text) : Object
	If ((This:C1470._providers=Null:C1517) || (This:C1470._providers.providers=Null:C1517))
		return Null:C1517
	End if 
	$name:=Replace string:C233($name; ":"; "%3A")
	If (Value type:C1509(This:C1470._providers.providers[$name])=Is object:K8:27)
		return OB Copy:C1225(This:C1470._providers.providers[$name])
	End if 
	return Null:C1517
	
	// Get all provider names
Function list() : Collection
	If ((This:C1470._providers=Null:C1517) || (This:C1470._providers.providers=Null:C1517))
		return []
	End if 
	return OB Keys:C1719(This:C1470._providers.providers)
	
	// MARK:- Model Resolution
	
	// Return all information extracted from a model name with format provider:modelName
Function _resolveModel($modelString : Text) : Object
	var $config:={success: False:C215; baseURL: ""; apiKey: ""; model: $modelString; error: Null:C1517}
	
	// Check if model string contains provider prefix
	If (Position:C15(":"; $modelString)=0)
		// No prefix - use as is
		return $config
	End if 
	
	var $parts:=Split string:C1554($modelString; ":")
	If ($parts.length<2)
		return $config
	End if 
	
	$config.success:=False:C215
	
	var $providerName : Text:=$parts[0]
	// Join remaining parts to handle model names with colons (e.g., "provider:model:version")
	$parts.shift()
	var $modelName : Text:=$parts.join(":")
	
	// Validate provider exists
	var $provider:=This:C1470.get($providerName)
	
	If ($provider=Null:C1517)
		$config.error:="Provider '"+$providerName+"' not found in configuration"
		return $config
	End if 
	
	// Simple provider model
	$config.baseURL:=$provider.baseURL || ""
	$config.apiKey:=$provider.apiKey || ""
	$config.organization:=$provider.organization || ""
	$config.project:=$provider.project || ""
	$config.model:=$modelName
	
	// Try to get apiKey from environment variable if not found
	If (Length:C16($config.apiKey)=0)
		var $envValue : Variant:=cs:C1710._Env.me[Uppercase:C13($providerName)+"_API_KEY"]
		If (Value type:C1509($envValue)=Is text:K8:3)
			$config.apiKey:=$envValue
		End if 
	End if 
	
	// Validate that we have a baseURL
	If (Length:C16($config.baseURL)=0)
		$config.error:="Provider '"+$providerName+"' missing required baseURL"
		return $config
	End if 
	
	$config.success:=True:C214
	return $config
	
	// MARK:- Collection Conversion
	
	// Convert merged providers to collection format for UI consumption
Function _toCollection() : Collection
	var $result:=[]
	If ((This:C1470._providers=Null:C1517) || (This:C1470._providers.providers=Null:C1517))
		return $result
	End if 
	
	var $key : Text
	For each ($key; This:C1470._providers.providers)
		var $provider : Variant:=This:C1470._providers.providers[$key]
		If (Value type:C1509($provider)=Is object:K8:27)
			$result.push({\
				name: $key; \
				apiKey: $provider.apiKey || ""; \
				baseURL: $provider.baseURL || ""; \
				organization: $provider.organization || ""; \
				project: $provider.project || ""\
				})
		End if 
	End for each 
	
	return $result.orderBy("name asc")
	