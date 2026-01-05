// Test helper class for OpenAIProviders listener tests
// Provides proper listener implementations that can't be done with inline Formula

property blockedProviders : Collection:=[]
property blockedRenames : Collection:=[]
property removedProviders : Collection:=[]
property renamedProviders : Collection:=[]
property addedProviders : Collection:=[]
property modifiedProviders : Collection:=[]

property vectors : Collection:=[]

Class constructor()
	
	// MARK:- Configuration
	
	// Add a provider key that should be blocked from deletion
Function blockProvider($key : Text) : cs._TestProviderListener
	If (Not(This.blockedProviders.includes($key)))
		This.blockedProviders.push($key)
	End if 
	return This
	
	// Add a provider key that should be blocked from renaming
Function blockRename($key : Text) : cs._TestProviderListener
	If (Not(This.blockedRenames.includes($key)))
		This.blockedRenames.push($key)
	End if 
	return This
	
	// Register a simulated vector that references a provider
Function registerVector($vector : Object) : cs._TestProviderListener
	This.vectors.push($vector)
	return This
	
	// Reset all tracking collections
Function reset()
	This.removedProviders:=[]
	This.renamedProviders:=[]
	This.addedProviders:=[]
	This.modifiedProviders:=[]
	
	// MARK:- Veto Events (called before operation)
	
	// Called before a provider is removed - can veto
Function canRemoveProvider($event : Object) : Object
	var $key : Text:=$event.key
	
	// Check if provider is in blocked list
	If (This.blockedProviders.includes($key))
		return {success: False; message: "Provider '"+$key+"' is protected and cannot be deleted"}
	End if 
	
	// Check if any vector uses this provider
	var $vector : Object
	For each ($vector; This.vectors)
		If ($vector.providerName=$key)
			return {success: False; message: "Provider '"+$key+"' is used by vector '"+$vector.name+"'"}
		End if 
	End for each 
	
	// Allow deletion
	return {success: True; message: ""}
	
	// Called before a provider is renamed - can veto
Function canRenameProvider($event : Object) : Object
	var $oldKey : Text:=$event.oldKey
	
	// Check if provider is in blocked list
	If (This.blockedRenames.includes($oldKey))
		return {success: False; message: "Provider '"+$oldKey+"' cannot be renamed"}
	End if 
	
	// Allow rename
	return {success: True; message: ""}
	
	// MARK:- Notification Events (called after operation)
	
	// Called after a provider is removed
Function onProviderRemoved($event : Object)
	This.removedProviders.push($event.key)
	
	// Called after a provider is added
Function onProviderAdded($event : Object)
	This.addedProviders.push($event.key)
	
	// Called after a provider is modified
Function onProviderModified($event : Object)
	This.modifiedProviders.push($event.key)
	
	// Called after a provider is renamed - update vector references
Function onProviderRenamed($event : Object)
	This.renamedProviders.push({oldKey: $event.oldKey; newKey: $event.newKey})
	
	// Update all vectors that referenced the old name
	var $vector : Object
	For each ($vector; This.vectors)
		If ($vector.providerName=$event.oldKey)
			$vector.providerName:=$event.newKey
		End if 
	End for each 
