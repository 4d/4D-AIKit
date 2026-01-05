Class extends _COMMON

property _detailFields:=[\
"name"; \
"baseURL"; \
"baseURLMenu"; \
"apiKey"; \
"model"; \
"modelMenu"; \
"organization"; \
"project"; \
"testConnection"; \
"connectionStatus"]

property previousItem : Object

property listeners : Collection:=[]

// Connection test status
property connectionStatus : Text:=""
property connectionModelsCount : Integer:=0
property isTestingConnection : Boolean:=False

Class constructor
	
	Super:C1705()
	
	// MARK:- [MANAGERS]
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function manager($e : Object)
	
	$e:=$e || FORM Event:C1606
	var $cur:=This:C1470.currentItem
	
	// MARK:- Form method
	If ($e.objectName=Null:C1517)
		
		Super:C1706.manager($e; "MODELS")
		
		Case of 
				
				// ________________________________________________________________________________
			: ($e.code=On Load:K2:1)
				
				OBJECT SET FORMAT:C236(*; "Header1"; "path:/.PRODUCT_RESOURCES/Images/WatchIcons/Watch_693.png")
				OBJECT SET VISIBLE:C603(*; "noModel"; This:C1470.models.length=0)
				
				// ______________________________________________________
			: ($e.code=On Timer:K2:25)
				
				This:C1470.listManager({code: On Selection Change:K2:29})
				
				// ______________________________________________________
			: ($e.code=On Activate:K2:9)
				
				//
				
				// ______________________________________________________
			: ($e.code=On Unload:K2:2)
				
				//
				
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
			
			This:C1470.newModel()
			
			// ______________________________________________________
		: ($e.objectName="delete")
			
			CONFIRM:C162(Localized string:C991("areYouSureYouWantToDeleteThisModel"))
			
			If (Bool:C1537(OK))
				
				This:C1470.deleteModel($cur.name)
				
				// Update UI
				LISTBOX SELECT ROW:C912(*; This:C1470.list; 0; lk remove from selection:K53:3)  // Unselect all
				SET TIMER:C645(-1)
				
			End if 
			
			// ______________________________________________________
		: ($e.objectName="name")
			
			This:C1470.nameManager($e)
			
			// ______________________________________________________
		: ($e.objectName="baseURLMenu")  // Menu of preconfigured providers
			
			GOTO OBJECT:C206(*; "baseURL")
			
			var $curbBase:=String:C10($cur.baseURL)
			var $menu:=cs:C1710._menu.new()
			
			var $provider : cs:C1710.Provider
			For each ($provider; This:C1470.PROVIDERS)
				
				$menu.append($provider.name; $provider.baseURL).mark($curbBase=$provider.baseURL)
				
			End for each 
			
			If ($menu.popup($curbBase).selected)\
				 && ($menu.choice#$curbBase)
				
				// Set the model baseURL
				$provider:=Form:C1466.PROVIDERS.query("baseURL = :1"; $menu.choice).first()
				
				$cur._provider:=$provider
				$cur.baseURL:=$menu.choice
				
				If ($provider.needToken#Null:C1517)
					
					$cur.apiKey:=$provider.endpoint.apiKey
					
				End if 
				
				Form:C1466.saveModels()
				
				If (This:C1470.updateUI())
					
					// Update mandatory or not fields labels
					OBJECT SET FONT STYLE:C166(*; "apiKey.label"; $cur._provider.needToken ? Bold:K14:2 : Plain:K14:1)
					
				End if 
			End if 
			
			// ______________________________________________________
		: ($e.objectName="testConnection")
			
			This:C1470.testConnection()
			
			// ______________________________________________________
	End case 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function listManager($e : Object)
	
	$e:=$e || FORM Event:C1606
	var $cur:=This:C1470.currentItem
	
	If ($e.code=On Selection Change:K2:29)  // ⚠️ This event must be enabled for both the list box AND the form.
		
		var $previous : cs:C1710.Model:=This:C1470.previousItem
		
		If ($previous#Null:C1517)
			
			If (Not:C34($previous.validate()))
				
				ALERT:C41($previous.errors.join("\r"))
				
				var $index:=This:C1470.models.indexOf($previous)
				LISTBOX SELECT ROW:C912(*; This:C1470.list; $index+1; lk replace selection:K53:1)
				
				return 
				
			End if 
		End if 
		
		If ($cur#Null:C1517)
			
			$cur._provider:=This:C1470.PROVIDERS.query("baseURL = :1"; String:C10($cur.baseURL) || This:C1470.OPENAI).first()
			
		End if 
		
		This:C1470.previousItem:=OB Copy:C1225($cur)
		
		If (This:C1470.updateUI())
			
			OBJECT SET FONT STYLE:C166(*; "apiKey.label"; $cur._provider.needToken ? Bold:K14:2 : Plain:K14:1)
			
		End if 
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function listMetaInfo($me : cs:C1710.Model) : Object
	
	return {}
	
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
		var $existingKeys:=$providers.getProviderKeys()
		If ($existingKeys.includes($newName) && ($newName#$oldName))
			
			Form:C1466._popError(\
				Replace string:C233(Localized string:C991("theModelNameMustBeUnique"); "{name}"; $newName))
			
			$cur.name:=$oldName
/* TOUCH */This:C1470.models:=This:C1470.models
			
			GOTO OBJECT:C206(*; "name")
			
			return 
			
		Else 
			
			// Rename provider using atomic renameProvider method
			var $result : Object:=$providers.renameProvider($oldName; $newName)
			If ($result.success)
				$providers.save()
				This:C1470.previousItem.name:=$newName
			Else 
				// Rename was blocked (e.g., by vector protection)
				Form:C1466._popError($result.message)
				$cur.name:=$oldName
/* TOUCH */This:C1470.models:=This:C1470.models
				GOTO OBJECT:C206(*; "name")
				return 
			End if 
			
		End if 
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function selectModel($name : Text)
	
	This:C1470.currentItem:=This:C1470.models.query("name = :1"; $name).first()
	
	If (This:C1470.currentItem#Null:C1517)
		
		// Update UI
		var $index:=This:C1470.models.indexOf(This:C1470.currentItem)
		LISTBOX SELECT ROW:C912(*; This:C1470.list; $index+1; lk replace selection:K53:1)
		
	End if 
	
	//SET TIMER(-1)
	If (This:C1470.updateUI())
		
		OBJECT SET FONT STYLE:C166(*; "apiKey.label"; Bool:C1537(This:C1470.currentItem._provider.needToken) ? Bold:K14:2 : Plain:K14:1)
		
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function newModel()
	
/* #17323
The model name shall be unique.
*/
	var $name:=Localized string:C991("newModel")
	var $i : Integer
	
	// Check against singleton for uniqueness
	var $providers:=cs:C1710.OpenAIProviders.me
	var $existingKeys:=$providers.getProviderKeys()
	
	Repeat 
		
		If ($existingKeys.includes($name))
			
			$i+=1
			$name:=Localized string:C991("newModel")+String:C10($i; " ##")
			
		Else 
			
			break
			
		End if 
	Until (False:C215)
	
	// Add to singleton
	var $model:=cs:C1710.Model.new($name)
	$providers.addProvider($name; {\
		apiKey: $model.apiKey; \
		baseURL: $model.baseURL; \
		organization: $model.organization; \
		project: $model.project\
		})
	
	// Refresh models from singleton
	This:C1470.readModels()
	This:C1470.selectModel($name)
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function deleteModel($name : Text)
	
	var $c:=This:C1470.models.indices("name = :1"; $name)
	
	If ($c.length<=0)
		return   // not found
	End if 
	
	// Check local listeners first (UI-level protection)
	var $couldDelete : Boolean:=True
	var $listener : Object
	For each ($listener; This:C1470.listeners) Until (Not:C34($couldDelete))
		
		$couldDelete:=$listener.onBeforeDelete($name) || $couldDelete
		
	End for each 
	
	If ($couldDelete)
		
		// Delegate to OpenAIProviders singleton
		var $providers:=cs:C1710.OpenAIProviders.me
		var $result : Object:=$providers.removeProvider($name)
		
		If ($result.success)
			// Refresh models from singleton
			This:C1470.readModels()
		Else 
			// Deletion was blocked (e.g., by vector protection)
			Form:C1466._popError($result.message)
		End if 
		
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
	// Test connection to verify provider credentials
Function testConnection()
	
	var $cur:=This:C1470.currentItem
	If ($cur=Null:C1517)
		return 
	End if 
	
	// Update UI to show testing state
	This:C1470.isTestingConnection:=True
	This:C1470.connectionStatus:=Localized string:C991("testingConnection") || "Testing connection..."
	This:C1470.connectionModelsCount:=0
	This:C1470._updateConnectionStatusUI()
	
	// Create OpenAI client with current provider settings
	var $client:=cs:C1710.OpenAI.new({\
		baseURL: $cur.baseURL; \
		apiKey: $cur.apiKey; \
		organization: $cur.organization; \
		project: $cur.project; \
		timeout: 30\
		})
	
	// Try to list models to verify connection
	var $result:=$client.models.list()
	
	This:C1470.isTestingConnection:=False
	
	If ($result.success)
		var $modelCount : Integer:=$result.models.length
		This:C1470.connectionModelsCount:=$modelCount
		This:C1470.connectionStatus:="✓ "+(Localized string:C991("connected") || "Connected")+" ("+String:C10($modelCount)+" "+(Localized string:C991("models") || "models")+")"
	Else 
		This:C1470.connectionModelsCount:=0
		var $errorMsg : Text:=$result.errors.length>0 ? $result.errors[0].message : "Connection failed"
		This:C1470.connectionStatus:="✗ "+$errorMsg
	End if 
	
	This:C1470._updateConnectionStatusUI()
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function _updateConnectionStatusUI()
	
	// Update the status text color based on result
	If (This:C1470.isTestingConnection)
		OBJECT SET RGB COLORS:C628(*; "connectionStatus"; 0x666666; -1)  // Gray during testing
	Else 
		If (This:C1470.connectionModelsCount>0)
			OBJECT SET RGB COLORS:C628(*; "connectionStatus"; 0x228B22; -1)  // Green for success
		Else 
			OBJECT SET RGB COLORS:C628(*; "connectionStatus"; 0xCC0000; -1)  // Red for error
		End if 
	End if 
	