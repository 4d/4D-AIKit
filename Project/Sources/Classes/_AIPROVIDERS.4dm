property providers : Collection

property WELLKNOWN_PROVIDERS:=[]

// Main list
property list:="list"
property currentItem : cs:C1710._OpenAIProvider

// Details panel
property _detailFields:=[\
"name"; \
"baseURL"; \
"apiKey"; \
"organization"; \
"project"; \
"testConnection"; \
"connectionStatus"]

property previousItem : Object

// Connection test status
property connectionStatus : Text:=""
property connectionStatusToolTip : Text:=""
property connectionModelsCount : Integer:=0  // Count of models from API
property isTestingConnection : Boolean:=False:C215

// Per-provider status cache and auto-test tracking
property _providerStatusCache : Object  // Dictionary keyed by provider name
property _lastTestedProviderName : Text  // Track which provider is being tested
property _autoTestTimerTicks : Integer  // Timer for debouncing auto-test
property _pendingAutoTestProviderName : Text  // Provider awaiting auto-test

// Provider editing state
property _isNewlyCreatedProvider : Boolean:=False:C215  // Track if current provider was just created

// ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___
Class constructor
	
	// Mark: Load predefined providers from providers.json as plain objects
	var $file:=File:C1566("/RESOURCES/providers.json")
	This:C1470.WELLKNOWN_PROVIDERS:=JSON Parse:C1218($file.getText()).map(Formula:C1597(cs:C1710._OpenAIProvider.new($1.value)))
	
	This:C1470.readProviders()
	
	// Initialize provider status cache
	This:C1470._providerStatusCache:={}
	
	If (Storage:C1525.studio=Null:C1517)
		
		Use (Storage:C1525)
			
			Storage:C1525.studio:=New shared object:C1526("AIPROVIDERS"; 0)
			
		End use 
	End if 
	
	// MARK:- [MANAGERS]
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function manager($e : Object)
	
	$e:=$e || FORM Event:C1606
	var $cur:=This:C1470.currentItem
	
	// MARK:- Form method
	If ($e.objectName=Null:C1517)
		
		Case of 
				
				// ________________________________________________________________________________
			: ($e.code=On Load:K2:1)
				
				Use (Storage:C1525.studio)
					
					Storage:C1525.studio["AIPROVIDERS"]:=Current form window:C827
					
				End use 
				
				SET TIMER:C645(-1)
				
				OBJECT SET FORMAT:C236(*; "Header1"; "path:/.PRODUCT_RESOURCES/Images/WatchIcons/Watch_693.png")
				OBJECT SET VISIBLE:C603(*; "noModel"; This:C1470.providers.length=0)
				
				cs:C1710.OpenAIProviders.me.addListener(This:C1470)
				
				// Initialize connection status to empty state
				This:C1470._initializeConnectionStatus()
				
				// ________________________________________________________________________________
			: ($e.code=On Unload:K2:2)
				
				cs:C1710.OpenAIProviders.me.removeListener(This:C1470)
				
				// ______________________________________________________
			: ($e.code=On Timer:K2:25)
				
				// Check if this is for auto-test debouncing
				If (This:C1470._autoTestTimerTicks>0)
					This:C1470._handleAutoTestTimer()
					return 
				End if 
				
				// Original timer logic for selection change
				SET TIMER:C645(0)
				This:C1470.listManager({code: On Selection Change:K2:29})
				
				// ______________________________________________________
			: ($e.code=On Activate:K2:9)
				
				If (Length:C16(OBJECT Get name:C1087(Object with focus:K67:3))=0)
					
					GOTO OBJECT:C206(*; This:C1470.list)
					
				End if 
				
				// ______________________________________________________
			: ($e.code=On Unload:K2:2)
				
				Use (Storage:C1525.studio)
					
					Storage:C1525.studio["AIPROVIDERS"]:=0
					
				End use 
				
				// ________________________________________________________________________________
		End case 
		
		return 
		
	End if 
	
	// MARK:- Widget methods
	Case of 
			
			// ______________________________________________________
		: ($e.objectName=This:C1470.list)
			
			This:C1470.listManager($e)
			
			// ______________________________________________________
		: ($e.objectName="add")
			
			This:C1470.newProvider()
			
			// ______________________________________________________
		: ($e.objectName="delete")
			If ($cur=Null:C1517)
				return 
			End if 
			CONFIRM:C162(Localized string:C991("confirmDeleteProvider"))
			
			If (Bool:C1537(OK))
				
				This:C1470.deleteProvider($cur.name)
				
			End if 
			
			// ______________________________________________________
		: ($e.objectName="name")
			
			This:C1470.nameManager($e)
			
			// ______
			// ______________________________________________________
		: ($e.objectName="testConnection")
			
			This:C1470.testConnection()
			
			// ______________________________________________________
		: ($e.objectName="baseURL")\
			 || ($e.objectName="apiKey")\
			 || ($e.objectName="organization")\
			 || ($e.objectName="project")
			
			This:C1470.fieldsManager($e)
			
			// ______________________________________________________
	End case 
	
Function fieldsManager($e : Object)
	
	$e:=$e || FORM Event:C1606
	var $cur:=This:C1470.currentItem
	
	If ($e.code=On Data Change:K2:15)
		
		cs:C1710.OpenAIProviders.me.modifyProvider($cur.name; $cur)
		
		// Trigger debounced auto-test when API key changes
		If ($e.objectName="apiKey")
			This:C1470._scheduleAutoTest($cur.name)
		End if 
		
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function listManager($e : Object)
	
	$e:=$e || FORM Event:C1606
	var $cur:=This:C1470.currentItem
	
	If ($e.code=On Selection Change:K2:29)  // ⚠️ This event must be enabled for both the list box AND the form.
		
		// Save current provider's status before switching
		If (This:C1470.previousItem#Null:C1517)
			This:C1470._saveCurrentProviderStatus()
		End if 
		
		If ($cur#Null:C1517)
			This:C1470.previousItem:=OB Copy:C1225($cur)
		End if 
		
		// Clear the newly-created flag when selecting from list
		// (unless it's the same provider - could be from selectProvider after newProvider)
		If (This:C1470._isNewlyCreatedProvider)
			// Keep the flag if we're selecting the same provider (e.g., from newProvider -> selectProvider)
			// Otherwise clear it (user clicked on a different provider in the list)
			If (This:C1470.previousItem#Null:C1517)
				If ($cur#Null:C1517)
					If ($cur.name#This:C1470.previousItem.name)
						This:C1470._isNewlyCreatedProvider:=False:C215
					End if 
				End if 
			End if 
		End if 
		
		This:C1470.updateUI()
		
		// Restore new provider's status after switching
		This:C1470._restoreCurrentProviderStatus()
		
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function nameManager($e : Object)
	
	$e:=$e || FORM Event:C1606
	var $cur:=This:C1470.currentItem
	
	If ($e.code=On Data Change:K2:15)
		
/* #17323
The model name shall be unique.
*/
		var $oldName : Text:=This:C1470.previousItem.name
		var $newName : Text:=$cur.name
		
		// Check uniqueness via singleton
		var $providers:=cs:C1710.OpenAIProviders.me
		If ($providers.hasProvider($newName) && ($newName#$oldName))
			
			Form:C1466._popError(\
				Replace string:C233(Localized string:C991("theModelNameMustBeUnique"); "{name}"; $newName))
			
			$cur.name:=$oldName
/* TOUCH */This:C1470.providers:=This:C1470.providers
			
			GOTO OBJECT:C206(*; "name")
			
			return 
			
		Else 
			
			// Rename provider using atomic renameProvider method
			var $result : Object:=$providers.renameProvider($oldName; $newName)
			If ($result.success)
				
				// Rename status cache entry
				If (This:C1470._providerStatusCache[$oldName]#Null:C1517)
					This:C1470._providerStatusCache[$newName]:=This:C1470._providerStatusCache[$oldName]
					OB REMOVE:C1226(This:C1470._providerStatusCache; $oldName)
				End if 
				
				$providers.save()
				This:C1470.previousItem.name:=$newName
				This:C1470.readProviders()
				
				// Clear newly-created flag after successful rename
				This:C1470._isNewlyCreatedProvider:=False:C215
			Else 
				// Rename was blocked (e.g., by vector protection)
				Form:C1466._popError($result.message)
				$cur.name:=$oldName
/* TOUCH */This:C1470.providers:=This:C1470.providers
				GOTO OBJECT:C206(*; "name")
				return 
			End if 
			
		End if 
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function selectProvider($name : Text)
	
	This:C1470.currentItem:=This:C1470.providers.query("name = :1"; $name).first()
	
	If (This:C1470.currentItem#Null:C1517)
		
		// Update UI
		var $index:=This:C1470.providers.indexOf(This:C1470.currentItem)
		LISTBOX SELECT ROW:C912(*; This:C1470.list; $index+1; lk replace selection:K53:1)
		
	End if 
	
	SET TIMER:C645(-1)
	////This.updateUI()
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function newProvider()
	
	var $menu:=cs:C1710._menu.new()
	
	var $custom:=Localized string:C991("customProvider")
	$menu.append($custom; $custom)
	$menu.line()
	
	var $wellKnown; $provider : cs:C1710._OpenAIProvider
	var $wellKnowns:=This:C1470.WELLKNOWN_PROVIDERS
	// TODO: filter on ones that are already in provider list, so do not propose them
	
	var $isLocal:=False:C215
	
	For each ($wellKnown; $wellKnowns)
		
		If (Not:C34($isLocal))
			If (Position:C15("localhost"; $wellKnown.baseURL)>0)
				$menu.line()
				$isLocal:=True:C214
			End if 
		End if 
		
		$menu.append($wellKnown.name; $wellKnown.baseURL)
		If (Folder:C1567(fk resources folder:K87:11).file(Replace string:C233($wellKnown.name; " "; "")+".png").exists)
			$menu.icon("Path:/RESOURCES/"+Replace string:C233($wellKnown.name; " "; "")+".png")
		End if 
		
	End for each 
	
	var $popup:=$menu.popup()
	If ($popup.selected)
		
		// Set the provider baseURL from selected well-known provider
		$wellKnown:=Form:C1466.WELLKNOWN_PROVIDERS.query("baseURL = :1"; $menu.choice).first()
		
		var $name:=Localized string:C991("newProvider")
		If ($wellKnown#Null:C1517)
			$name:=Lowercase:C14(Replace string:C233($wellKnown.name; " "; ""))
		End if 
		var $wantedName:=$name
		
/*
The model name shall be unique.
*/
		// Check against singleton for uniqueness
		var $providers:=cs:C1710.OpenAIProviders.me
		var $existingKeys:=$providers.getProviderKeys()
		
		var $i:=0
		Repeat 
			
			If ($existingKeys.includes($name))
				
				$i+=1
				$name:=$wantedName+String:C10($i; " ##")
				
			Else 
				
				break
				
			End if 
		Until (False:C215)
		
		// Add to singleton with empty provider config
		$providers.addProvider($name; {\
			baseURL: ($wellKnown=Null:C1517) ? "" : $wellKnown.baseURL; \
			apiKey: ""; \
			organization: ""; \
			project: ""\
			})
		$providers.save()
		
		// Refresh models from singleton
		This:C1470.readProviders()
		
		// Mark as newly created to allow renaming
		This:C1470._isNewlyCreatedProvider:=True:C214
		
		This:C1470.selectProvider($name)
		
		Form:C1466.saveProviders()
		This:C1470.updateUI()
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function deleteProvider($name : Text)
	
	var $c:=This:C1470.providers.indices("name = :1"; $name)
	
	If ($c.length<=0)
		return   // not found
	End if 
	
	// Delegate to OpenAIProviders singleton
	var $providers:=cs:C1710.OpenAIProviders.me
	var $result : Object:=$providers.removeProvider($name)
	$providers.save()
	
	If ($result.success)
		
		// Remove status from cache
		If (This:C1470._providerStatusCache[$name]#Null:C1517)
			OB REMOVE:C1226(This:C1470._providerStatusCache; $name)
		End if 
		
		// Refresh providers from singleton
		This:C1470.readProviders()
		
		If (This:C1470.providers.length>0)
			This:C1470.currentItem:=This:C1470.providers.first()
			This:C1470.selectProvider(This:C1470.currentItem.name)
		End if 
		
		This:C1470.updateUI()
		
	Else 
		// Deletion was blocked (e.g., by vector protection?)
		Form:C1466._popError($result.message)
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
	// Test connection to verify provider credentials
Function testConnection()
	
	var $cur:=This:C1470.currentItem
	If ($cur=Null:C1517)
		return 
	End if 
	
	// Remember which provider we're testing
	This:C1470._lastTestedProviderName:=$cur.name
	
	// Update UI to show testing state
	This:C1470.isTestingConnection:=True:C214
	This:C1470.connectionStatus:=Localized string:C991("testingConnection") || "Testing connection..."
	This:C1470.connectionModelsCount:=0
	This:C1470.connectionStatusToolTip:=""
	This:C1470._updateConnectionStatusUI()
	
	// Create OpenAI client with current provider settings
	var $client:=cs:C1710.OpenAI.new($cur)
	$client.timeout:=10
	
	// Try to list models to verify connection
	var $this : Object:=This:C1470
	var $resultIgnore:=$client.models.list($this)
	
Function onTerminateTestConnection($result : cs:C1710.OpenAIModelListResult)
	
	This:C1470.isTestingConnection:=False:C215
	
	// Capture which provider this test was for
	var $testedProviderName : Text:=This:C1470._lastTestedProviderName
	If (Length:C16($testedProviderName)=0)
		// Edge case: callback fired but we don't know which provider
		// Fall back to current provider (may be wrong if user switched)
		If (This:C1470.currentItem#Null:C1517)
			$testedProviderName:=This:C1470.currentItem.name
		Else 
			return   // No current item, nothing to update
		End if 
	End if 
	
	// Build status strings
	var $status : Text
	var $tooltip : Text
	var $modelCount : Integer:=0
	
	If ($result.success)
		$modelCount:=$result.models.length
		$status:="🟢 "+(Localized string:C991("connected") || "Connected")+" ("+String:C10($modelCount)+" "+(Localized string:C991("models") || "models")+")"
		$tooltip:=$result.models.map(Formula:C1597($1.value.id)).join("\n")
	Else 
		$modelCount:=0
		$status:="❌ "+(($result.errors.length>0) ? $result.errors[0].message : "Connection failed")
		$tooltip:=$result.errors.map(Formula:C1597($1.value.message)).join("\n")
	End if 
	
	// Store result in per-provider cache
	This:C1470._providerStatusCache[$testedProviderName]:={\
		connectionStatus: $status; \
		connectionStatusToolTip: $tooltip; \
		connectionModelsCount: $modelCount; \
		hasBeenTested: True:C214\
		}
	
	// Only update form-level properties if this is still the current provider
	If ((This:C1470.currentItem#Null:C1517) && (This:C1470.currentItem.name=$testedProviderName))
		This:C1470.connectionStatus:=$status
		This:C1470.connectionStatusToolTip:=$tooltip
		This:C1470.connectionModelsCount:=$modelCount
		This:C1470._updateConnectionStatusUI()
	End if 
	// Otherwise: user switched to different provider, so we don't update UI
	// The status is safely cached and will be restored when they select this provider again
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function _updateConnectionStatusUI()
	
	// Update the status text color based on result
	If (This:C1470.isTestingConnection)
		OBJECT SET HELP TIP:C1181(*; "connectionStatus"; "")
	Else 
		OBJECT SET HELP TIP:C1181(*; "connectionStatus"; This:C1470.connectionStatusToolTip)
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
	// Initialize connection status to empty state (fresh start for session)
Function _initializeConnectionStatus()
	
	// Reset all form-level connection status properties to empty state
	This:C1470.connectionStatus:=""
	This:C1470.connectionStatusToolTip:=""
	This:C1470.connectionModelsCount:=0
	This:C1470.isTestingConnection:=False:C215
	
	// Clear the provider status cache (fresh start for this session)
	This:C1470._providerStatusCache:={}
	
	// Update UI to show empty status
	This:C1470._updateConnectionStatusUI()
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
	// Save the current provider's connection status to the cache
Function _saveCurrentProviderStatus()
	
	var $prev:=This:C1470.previousItem
	If ($prev=Null:C1517)
		return 
	End if 
	
	var $providerName : Text:=$prev.name
	
	// Store current form-level status in cache
	This:C1470._providerStatusCache[$providerName]:={\
		connectionStatus: This:C1470.connectionStatus; \
		connectionStatusToolTip: This:C1470.connectionStatusToolTip; \
		connectionModelsCount: This:C1470.connectionModelsCount; \
		hasBeenTested: (Length:C16(This:C1470.connectionStatus)>0)\
		}
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
	// Restore the selected provider's connection status from cache, or show empty state
Function _restoreCurrentProviderStatus()
	
	var $cur:=This:C1470.currentItem
	If ($cur=Null:C1517)
		// No selection - reset to empty
		This:C1470.connectionStatus:=""
		This:C1470.connectionStatusToolTip:=""
		This:C1470.connectionModelsCount:=0
		This:C1470.isTestingConnection:=False:C215
		This:C1470._updateConnectionStatusUI()
		return 
	End if 
	
	var $providerName : Text:=$cur.name
	
	// Check if we're currently testing this specific provider
	var $isTestingThisProvider : Boolean:=False:C215
	If (This:C1470.isTestingConnection && (This:C1470._lastTestedProviderName=$providerName))
		$isTestingThisProvider:=True:C214
	Else 
		This:C1470.isTestingConnection:=False:C215  // Clear if not testing this provider
	End if 
	
	// Check if we have cached status for this provider
	If (This:C1470._providerStatusCache[$providerName]#Null:C1517)
		
		// Restore from cache (unless actively testing)
		If (Not:C34($isTestingThisProvider))
			var $cached : Object:=This:C1470._providerStatusCache[$providerName]
			This:C1470.connectionStatus:=$cached.connectionStatus
			This:C1470.connectionStatusToolTip:=$cached.connectionStatusToolTip
			This:C1470.connectionModelsCount:=$cached.connectionModelsCount
		End if 
		
	Else 
		
		// No cached status - show empty state (not tested yet)
		If (Not:C34($isTestingThisProvider))
			This:C1470.connectionStatus:=""
			This:C1470.connectionStatusToolTip:=""
			This:C1470.connectionModelsCount:=0
		End if 
		
	End if 
	
	// Update UI with restored or empty status
	This:C1470._updateConnectionStatusUI()
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
	// Schedule an auto-test with debouncing (cancels previous pending tests)
Function _scheduleAutoTest($providerName : Text)
	
	// Store which provider needs testing
	This:C1470._pendingAutoTestProviderName:=$providerName
	
	// Set timer for 1.5 seconds (90 ticks at 60 ticks/second)
	// If another change happens before timer fires, this will be reset
	This:C1470._autoTestTimerTicks:=90
	SET TIMER:C645(90)
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
	// Handle auto-test timer expiration
Function _handleAutoTestTimer()
	
	// Stop timer
	SET TIMER:C645(0)
	This:C1470._autoTestTimerTicks:=0
	
	var $providerToTest : Text:=This:C1470._pendingAutoTestProviderName
	This:C1470._pendingAutoTestProviderName:=""
	
	// Validate that we have a provider to test
	If (Length:C16($providerToTest)=0)
		return 
	End if 
	
	// Only test if the provider still exists and has an API key
	var $provider:=This:C1470.providers.query("name = :1"; $providerToTest).first()
	If ($provider=Null:C1517)
		return   // Provider was deleted
	End if 
	
	If (Length:C16($provider.apiKey)=0)
		return   // No API key, don't test
	End if 
	
	// If this provider is currently selected, trigger the test
	If ((This:C1470.currentItem#Null:C1517) && (This:C1470.currentItem.name=$providerToTest))
		This:C1470.testConnection()
	Else 
		// Provider is not currently selected
		// We could either:
		// Option A: Test it anyway in background (requires more complex handling)
		// Option B: Skip the test (simpler, but less proactive)
		// RECOMMENDATION: Option B - only auto-test the currently selected provider
		// User can manually test when they select it
		return 
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
	// Hide/show details based on selection
Function updateUI()
	
	var $detailVisible:=This:C1470.currentItem#Null:C1517
	If (This:C1470.providers.length=0)
		$detailVisible:=False:C215
	End if 
	OBJECT SET VISIBLE:C603(*; "noModel"; This:C1470.providers.length=0)
	
	var $t : Text
	For each ($t; This:C1470._detailFields)
		
		OBJECT SET VISIBLE:C603(*; $t; $detailVisible)
		OBJECT SET VISIBLE:C603(*; $t+".label"; $detailVisible)
		
	End for each 
	
	OBJECT SET ENABLED:C1123(*; "delete"; $detailVisible)
	
	// Enable name field only for newly created providers
	If ($detailVisible)
		OBJECT SET ENTERABLE:C238(*; "name"; This:C1470._isNewlyCreatedProvider)
	End if 
	
	
	// MARK:- [PROVIDERS]
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function readProviders()
	This:C1470.providers:=cs:C1710.OpenAIProviders.me.toCollection()
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function saveProviders()
	//cs.OpenAIProviders.me.fromCollection(This.providers)
	cs:C1710.OpenAIProviders.me.save()  // only trust singleton
	
	// MARK:- [PRIVATE]
	// *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
Function _popError($message : Text; $widget : Text; $target : Text)
	
	BEEP:C151
	ALERT:C41($message)
	
	If (Length:C16($target)>0)
		
		var $o : Object:=OBJECT Get value:C1743($widget)
		$o.target:=$target
		OBJECT SET VALUE:C1742($widget; $o)
		
	End if 
	
	// MARK:- [OpenAI Asynchrone]
	
Function get onTerminate : 4D:C1709.Function
	return This:C1470.onTerminateTestConnection
	
	// MARK:- [OpenAIProvider Listener]
	
Function onLoad
	This:C1470.readProviders()
	
Function onSave
	
Function onProviderAdded
	This:C1470.readProviders()
	
Function onProviderRemoved
	This:C1470.readProviders()
	
Function onProviderModified
	
Function onProviderRenamed
	This:C1470.readProviders()
	
	//Function onModelResolved
	
Function canRenameProvider($param : Object) : Object
	return {success: True:C214}
	
Function canRemoveProvider($param : Object) : Object
	return {success: True:C214}