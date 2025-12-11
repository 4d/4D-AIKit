// Model Alias Resolver utility class
// Handles resolution of model strings in the format "provider:model" to their configuration

property _providersFile : 4D:C1709.File
property _providersConfig : Object

Class constructor()
	This:C1470._providersFile:=This:C1470._getDefaultProvidersFile()
	This:C1470._loadConfiguration()
	
	// MARK:- Configuration Management
	
Function setProvidersFile($file : 4D:C1709.File)
	
	This:C1470._providersFile:=$file
	This:C1470._loadConfiguration()
	
Function _getDefaultProvidersFile() : 4D:C1709.File
	// Look for ai-providers.json in Resources folder
	var $resourcesFolder : 4D:C1709.Folder:=Folder:C1567(fk resources folder:K87:11; *)
	var $providersFile : 4D:C1709.File:=$resourcesFolder.file("ai-providers.json")
	
	// Return the file object anyway (will be null when accessed)
	return $providersFile
	
Function _loadConfiguration()
	If (This:C1470._providersFile=Null:C1517 || Not:C34(This:C1470._providersFile.exists))
		This:C1470._providersConfig:={}
		return 
	End if 
	
	Try
		This:C1470._providersConfig:=JSON Parse:C1218(This:C1470._providersFile.getText())
	Catch
		// ALERT("Error parsing providers configuration: "+$error.message)
		This:C1470._providersConfig:={}
	End try
	
	// MARK:- Model Resolution
	
Function resolveModel($modelString : Text) : Object
	var $config:={success: False:C215; baseURL: ""; apiKey: ""; model: $modelString; error: Null:C1517}
	
	// Check if model string contains provider prefix
	If (Position:C15(":"; $modelString)=0)
		// No prefix - use as is
		$config.success:=True:C214
		$config.model:=$modelString
		return $config
	End if 
	
	var $parts:=Split string:C1554($modelString; ":")
	var $providerName : Text:=$parts[0]
	var $modelName : Text:=$parts[1]
	
	// Validate provider exists
	If (This:C1470._providersConfig.providers=Null:C1517 || This:C1470._providersConfig.providers[$providerName]=Null:C1517)
		$config.error:="Provider '"+$providerName+"' not found in configuration"
		return $config
	End if 
	
	var $provider : Object:=This:C1470._providersConfig.providers[$providerName]
	
	// Check if this is a nested model definition
	If (($provider.models#Null:C1517) && ($provider.models[$modelName]#Null:C1517))
		return This:C1470._resolveNestedModel($provider.models[$modelName]; $providerName; $modelName)
	End if 
	
	// Simple provider model
	$config.baseURL:=$provider.baseURL || ""
	$config.apiKey:=$provider.apiKey || ""
	$config.model:=$modelName
	
	// Try to get apiKey from environment variable if not found
	If ((Length:C16($config.apiKey)=0) && ($provider.apiKeyEnv#Null:C1517))
		$config.apiKey:=cs:C1710._Env.me[$provider.apiKeyEnv] || ""
	End if 
	
	// Validate that we have a baseURL
	If (Length:C16($config.baseURL)=0)
		$config.error:="Provider '"+$providerName+"' missing required baseURL"
		return $config
	End if 
	
	$config.success:=True:C214
	return $config
	
Function _resolveNestedModel($modelDef : Object; $providerName : Text; $modelAlias : Text) : Object
	var $config:={success: False:C215; baseURL: ""; apiKey: ""; model: ""; error: Null:C1517}
	
	// Get baseURL from model definition or provider level
	var $provider : Object:=This:C1470._providersConfig.providers[$providerName]
	$config.baseURL:=$modelDef.baseURL || $provider.baseURL || ""
	
	// Get apiKey from model definition or provider level
	$config.apiKey:=$modelDef.apiKey || $provider.apiKey || ""
	
	// Try to get apiKey from environment variable if not found
	If ((Length:C16($config.apiKey)=0) && ($modelDef.apiKeyEnv#Null:C1517))
		$config.apiKey:=cs:C1710._Env.me[$modelDef.apiKeyEnv] || ""
	End if 
	If ((Length:C16($config.apiKey)=0) && ($provider.apiKeyEnv#Null:C1517))
		$config.apiKey:=cs:C1710._Env.me[$provider.apiKeyEnv] || ""
	End if 
	
	// Get actual model name from modelName property or use the alias
	$config.model:=$modelDef.modelName || $modelAlias
	
	// If still no apiKey, search for a provider with matching baseURL
	If ((Length:C16($config.apiKey)=0) && (Length:C16($config.baseURL)>0))
		$config.apiKey:=This:C1470._findApiKeyByBaseURL($config.baseURL)
	End if 
	
	// Validate that we have a baseURL
	If (Length:C16($config.baseURL)=0)
		$config.error:="Model '"+$modelAlias+"' missing required baseURL"
		return $config
	End if 
	
	$config.success:=True:C214
	return $config
	
Function _findApiKeyByBaseURL($baseURL : Text) : Text
	If (This:C1470._providersConfig.providers=Null:C1517)
		return ""
	End if 
	
	var $providerName : Text
	For each ($providerName; This:C1470._providersConfig.providers)
		var $provider : Object:=This:C1470._providersConfig.providers[$providerName]
		If (($provider.baseURL=$baseURL) && (Length:C16($provider.apiKey)>0))
			return $provider.apiKey
		End if 
	End for each 
	
	return ""
	
	// MARK:- Utility
	
Function hasConfiguration() : Boolean
	return ((This:C1470._providersFile#Null:C1517) && (This:C1470._providersFile.exists) && (This:C1470._providersConfig.providers#Null:C1517))
	