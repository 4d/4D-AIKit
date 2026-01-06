// Model Alias Resolver utility class
// Handles resolution of model strings in the format "provider:model" to their configuration

property _providersFile : 4D:C1709.File
property _providersConfig : Object
property _listeners : Collection
property errors : Collection

singleton Class constructor()
	This:C1470._listeners:=[]
	This:C1470.providersFile:=This:C1470._getDefaultProvidersFile()
	
	// MARK:- Configuration Management
	
Function set providersFile($file : 4D:C1709.File)
	This:C1470._providersFile:=$file
	This:C1470.load()
	
Function get providersFile : 4D:C1709.File
	return This:C1470._providersFile
	
Function _getDefaultProvidersFile() : 4D:C1709.File
	// Look for AIProviders.json in Settings folder
	return Folder:C1567(fk database folder:K87:14; *).file("Settings/AIProviders.json")
	
Function load() : Boolean
	This:C1470.errors:=Null:C1517
	If (This:C1470._providersFile=Null:C1517 || Not:C34(This:C1470._providersFile.exists))
		This:C1470._providersConfig:={}
		return False:C215
	End if 
	
	Try
		This:C1470._providersConfig:=JSON Parse:C1218(This:C1470._providersFile.getText())
	Catch
		This:C1470.errors:=Last errors:C1799
		This:C1470._providersConfig:={}
		return False:C215
	End try
	
	This:C1470._notify("onLoad"; {})
	return True:C214
	
Function save()
	If (This:C1470._providersFile=Null:C1517)
		return 
	End if 
	This:C1470._providersFile.setText(JSON Stringify:C1217(This:C1470._providersConfig; *))
	This:C1470._notify("onSave"; {})
	
	// MARK:- Provider Management
	
	// Add or update a provider by key
Function addProvider($key : Text; $config : Object) : cs:C1710.OpenAIProviders
	If (This:C1470._providersConfig.providers=Null:C1517)
		This:C1470._providersConfig.providers:={}
	End if 
	This:C1470._providersConfig.providers[$key]:=$config
	This:C1470._notify("onProviderAdded"; {key: $key; config: $config})
	return This:C1470
	
	// Remove a provider by key (checks listeners before proceeding)
Function removeProvider($key : Text) : Object
	If (This:C1470._providersConfig.providers=Null:C1517)
		return {success: False:C215; message: "No providers configured"}
	End if 
	If (This:C1470._providersConfig.providers[$key]=Null:C1517)
		return {success: False:C215; message: "Provider '"+$key+"' not found"}
	End if 
	// Ask listeners if we can proceed
	var $check:=This:C1470._canProceed("canRemoveProvider"; {key: $key})
	If (Not:C34($check.success))
		return $check
	End if 
	OB REMOVE:C1226(This:C1470._providersConfig.providers; $key)
	This:C1470._notify("onProviderRemoved"; {key: $key})
	return {success: True:C214; message: ""}
	
	// Get a provider by key
Function getProvider($key : Text) : Object
	If (This:C1470._providersConfig.providers=Null:C1517)
		return Null:C1517
	End if 
	return This:C1470._providersConfig.providers[$key]
	
	// Check if there is a provider with this key
Function hasProvider($key : Text) : Boolean
	If (This:C1470._providersConfig.providers=Null:C1517)
		return False:C215
	End if 
	return This:C1470._providersConfig.providers[$key]#Null:C1517
	
	// Get all provider keys
Function getProviderKeys() : Collection
	If (This:C1470._providersConfig.providers=Null:C1517)
		return []
	End if 
	return OB Keys:C1719(This:C1470._providersConfig.providers)
	
	// Modify an existing provider (merge updates)
Function modifyProvider($key : Text; $updates : Object) : Boolean
	If (This:C1470._providersConfig.providers=Null:C1517)
		return False:C215
	End if 
	If (This:C1470._providersConfig.providers[$key]=Null:C1517)
		return False:C215
	End if 
	var $fieldName : Text
	For each ($fieldName; $updates)
		This:C1470._providersConfig.providers[$key][$fieldName]:=$updates[$fieldName]
	End for each 
	This:C1470._notify("onProviderModified"; {key: $key; updates: $updates})
	return True:C214
	
	// Rename a provider (atomic operation with dedicated notification)
Function renameProvider($oldKey : Text; $newKey : Text) : Object
	If (This:C1470._providersConfig.providers=Null:C1517)
		return {success: False:C215; message: "No providers configured"}
	End if 
	If (This:C1470._providersConfig.providers[$oldKey]=Null:C1517)
		return {success: False:C215; message: "Provider '"+$oldKey+"' not found"}
	End if 
	// Don't allow rename if new key already exists
	If (This:C1470._providersConfig.providers[$newKey]#Null:C1517)
		return {success: False:C215; message: "Provider '"+$newKey+"' already exists"}
	End if 
	// Ask listeners if we can proceed
	var $check:=This:C1470._canProceed("canRenameProvider"; {oldKey: $oldKey; newKey: $newKey})
	If (Not:C34($check.success))
		return $check
	End if 
	// Copy config to new key
	var $config : Variant:=This:C1470._providersConfig.providers[$oldKey]
	This:C1470._providersConfig.providers[$newKey]:=$config
	// Remove old key
	OB REMOVE:C1226(This:C1470._providersConfig.providers; $oldKey)
	// Notify with specific rename event (for vector propagation)
	This:C1470._notify("onProviderRenamed"; {oldKey: $oldKey; newKey: $newKey; config: $config})
	return {success: True:C214; message: ""}
	
/* MARK:- Model Alias Management (COMMENTED - Feature disabled)
	
	// Add or update a model alias under a provider
Function addModelAlias($providerKey : Text; $aliasKey : Text; $config : Object) : cs:C1710.OpenAIProviders
	If (This:C1470._providersConfig.providers=Null:C1517)
		This:C1470._providersConfig.providers:={}
	End if 
	If (This:C1470._providersConfig.providers[$providerKey]=Null:C1517)
		This:C1470._providersConfig.providers[$providerKey]:={}
	End if 
	If (This:C1470._providersConfig.providers[$providerKey].models=Null:C1517)
		This:C1470._providersConfig.providers[$providerKey].models:={}
	End if 
	This:C1470._providersConfig.providers[$providerKey].models[$aliasKey]:=$config
	This:C1470._notify("onModelAliasAdded"; {providerKey: $providerKey; aliasKey: $aliasKey; config: $config})
	return This:C1470
	
	// Remove a model alias from a provider
Function removeModelAlias($providerKey : Text; $aliasKey : Text) : Boolean
	If (This:C1470._providersConfig.providers=Null:C1517)
		return False:C215
	End if 
	If (This:C1470._providersConfig.providers[$providerKey]=Null:C1517)
		return False:C215
	End if 
	If (This:C1470._providersConfig.providers[$providerKey].models=Null:C1517)
		return False:C215
	End if 
	If (This:C1470._providersConfig.providers[$providerKey].models[$aliasKey]=Null:C1517)
		return False:C215
	End if 
	OB REMOVE:C1226(This:C1470._providersConfig.providers[$providerKey].models; $aliasKey)
	This:C1470._notify("onModelAliasRemoved"; {providerKey: $providerKey; aliasKey: $aliasKey})
	return True:C214
	
	// Get a model alias from a provider
Function getModelAlias($providerKey : Text; $aliasKey : Text) : Object
	If (This:C1470._providersConfig.providers=Null:C1517)
		return Null:C1517
	End if 
	If (This:C1470._providersConfig.providers[$providerKey]=Null:C1517)
		return Null:C1517
	End if 
	If (This:C1470._providersConfig.providers[$providerKey].models=Null:C1517)
		return Null:C1517
	End if 
	return This:C1470._providersConfig.providers[$providerKey].models[$aliasKey]
	
	// Get all model alias keys for a provider
Function getModelAliasKeys($providerKey : Text) : Collection
	If (This:C1470._providersConfig.providers=Null:C1517)
		return []
	End if 
	If (This:C1470._providersConfig.providers[$providerKey]=Null:C1517)
		return []
	End if 
	If (This:C1470._providersConfig.providers[$providerKey].models=Null:C1517)
		return []
	End if 
	return OB Keys:C1719(This:C1470._providersConfig.providers[$providerKey].models)
	
	// Modify an existing model alias (merge updates)
Function modifyModelAlias($providerKey : Text; $aliasKey : Text; $updates : Object) : Boolean
	If (This:C1470._providersConfig.providers=Null:C1517)
		return False:C215
	End if 
	If (This:C1470._providersConfig.providers[$providerKey]=Null:C1517)
		return False:C215
	End if 
	If (This:C1470._providersConfig.providers[$providerKey].models=Null:C1517)
		return False:C215
	End if 
	If (This:C1470._providersConfig.providers[$providerKey].models[$aliasKey]=Null:C1517)
		return False:C215
	End if 
	var $fieldName : Text
	For each ($fieldName; $updates)
		This:C1470._providersConfig.providers[$providerKey].models[$aliasKey][$fieldName]:=$updates[$fieldName]
	End for each 
	This:C1470._notify("onModelAliasModified"; {providerKey: $providerKey; aliasKey: $aliasKey; updates: $updates})
	return True:C214
*/
	
	// MARK:- Listeners
	
	// Add a listener object (delegate)
Function addListener($listener : Object) : cs:C1710.OpenAIProviders
	If (This:C1470._listeners.indexOf($listener)<0)
		This:C1470._listeners.push($listener)
	End if 
	return This:C1470
	
	// Remove a listener object
Function removeListener($listener : Object) : Boolean
	var $index : Integer:=This:C1470._listeners.indexOf($listener)
	If ($index>=0)
		This:C1470._listeners.remove($index)
		return True:C214
	End if 
	return False:C215
	
	// Ask listeners if an operation can proceed (returns on first veto)
Function _canProceed($eventName : Text; $eventData : Object) : Object
	var $listener : Object
	For each ($listener; This:C1470._listeners)
		If ($listener[$eventName]#Null:C1517)
			var $result : Variant:=$listener[$eventName]($eventData)
			If (Value type:C1509($result)=Is object:K8:27)
				If (Not:C34(Bool:C1537($result.success)))
					// Listener vetoed the operation - stop immediately
					return {success: False:C215; message: String:C10($result.message)}
				End if 
			End if 
		End if 
	End for each 
	// All listeners approved (or none registered)
	return {success: True:C214; message: ""}
	
	// Notify all listeners of an event
Function _notify($eventName : Text; $eventData : Object)
	var $listener : Object
	For each ($listener; This:C1470._listeners)
		If ($listener[$eventName]#Null:C1517)
			$listener[$eventName]($eventData)
		End if 
	End for each 
	
	// MARK:- Model Resolution
	
	// Return all information extracted from a model name
Function resolveModel($modelString : Text) : Object
	var $config:={success: True:C214; baseURL: ""; apiKey: ""; model: $modelString; error: Null:C1517}
	
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
	This:C1470._notify("onModelResolved"; {modelString: $modelString; config: $config})
	return $config
	
Function _resolveNestedModel($modelDef : Object; $providerName : Text; $modelAlias : Text) : Object
	var $config:={success: False:C215; baseURL: ""; apiKey: ""; model: ""; error: Null:C1517}
	
	// Get baseURL from model definition or provider level
	var $provider : Object:=This:C1470._providersConfig.providers[$providerName]
	$config.baseURL:=$modelDef.baseURL || $provider.baseURL || ""
	
	
	// Get apiKey from model definition or provider level
	$config.apiKey:=$modelDef.apiKey || $provider.apiKey || ""
	
	// If still no apiKey, search for a provider with matching baseURL
	If ((Length:C16($config.apiKey)=0) && (Length:C16($config.baseURL)>0))
		$config.apiKey:=This:C1470._findApiKeyByBaseURL($config.baseURL)
	End if 
	
	// Try to get apiKey from environment variable if not found
	If ((Length:C16($config.apiKey)=0) && ($modelDef.apiKeyEnv#Null:C1517))
		$config.apiKey:=cs:C1710._Env.me[$modelDef.apiKeyEnv] || ""
	End if 
	If ((Length:C16($config.apiKey)=0) && ($provider.apiKeyEnv#Null:C1517))
		$config.apiKey:=cs:C1710._Env.me[$provider.apiKeyEnv] || ""
	End if 
	
	// Get actual model name from modelName property or use the alias
	$config.model:=$modelDef.modelName || $modelAlias
	
	// Validate that we have a baseURL (TODO: remove?)
	If (Length:C16($config.baseURL)=0)
		$config.error:="Model '"+$modelAlias+"' missing required baseURL"
		return $config
	End if 
	
	$config.success:=True:C214
	This:C1470._notify("onModelResolved"; {providerName: $providerName; modelAlias: $modelAlias; config: $config})
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
	
	// MARK:- Collection Conversion (for UI compatibility)
	
	// Convert providers object to collection format for UI consumption
Function toCollection() : Collection
	var $result:=[]
	If (This:C1470._providersConfig.providers=Null:C1517)
		return $result
	End if 
	
	var $key : Text
	For each ($key; This:C1470._providersConfig.providers)
		var $provider : Object:=This:C1470._providersConfig.providers[$key]
		$result.push(cs:C1710._OpenAIProvider.new({\
			name: $key; \
			apiKey: $provider.apiKey || ""; \
			baseURL: $provider.baseURL || ""; \
			organization: $provider.organization || ""; \
			project: $provider.project || ""\
			}))
	End for each 
	
	return $result.orderBy("name asc")
	
	// Convert collection format back to providers object and save
Function fromCollection($models : Collection)
	// Clear and rebuild
	This:C1470._providersConfig.providers:={}
	
	var $model : Object
	For each ($model; $models)
		This:C1470._providersConfig.providers[$model.name]:={\
			apiKey: $model.apiKey; \
			baseURL: $model.baseURL; \
			organization: $model.organization; \
			project: $model.project\
			}
	End for each 
	