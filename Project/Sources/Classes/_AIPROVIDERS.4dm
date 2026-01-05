property providers : Collection

property WELLKNOWN_PROVIDERS:=[]
property OPENAI:="https://api.openai.com/@"

// Main list
property list:="list"
property currentItem : Object

// Details panel
property _detailFields:=[\
"name"; \
"baseURL"; \
"baseURLMenu"; \
"apiKey"; \
"organization"; \
"project"; \
"testConnection"; \
"connectionStatus"]

property previousItem : Object

property listeners : Collection:=[]

// Connection test status
property connectionStatus : Text:=""
property connectionModelsCount : Integer:=0  // Count of models from API
property isTestingConnection : Boolean:=False:C215

// ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___
Class constructor
	
	// Mark: Load predefined providers from providers.json as plain objects
	var $file:=File:C1566("/RESOURCES/providers.json")
	This:C1470.WELLKNOWN_PROVIDERS:=JSON Parse:C1218($file.getText())
	
	This:C1470.readProviders()
	
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
				
				// ______________________________________________________
			: ($e.code=On Timer:K2:25)
				
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
					
					Storage:C1525.studio["PROVIDERS"]:=0
					
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
			
			CONFIRM:C162(Localized string:C991("confirmDeleteProvider"))
			
			If (Bool:C1537(OK))
				
				This:C1470.deleteProvider($cur.name)
				
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
			
			var $wellKnown : Object
			For each ($wellKnown; This:C1470.WELLKNOWN_PROVIDERS)
				
				$menu.append($wellKnown.name; $wellKnown.baseURL).mark($curbBase=$wellKnown.baseURL)
				
			End for each 
			
			If ($menu.popup($curbBase).selected)\
				 && ($menu.choice#$curbBase)
				
				// Set the provider baseURL from selected well-known provider
				$wellKnown:=Form:C1466.WELLKNOWN_PROVIDERS.query("baseURL = :1"; $menu.choice).first()
				
				$cur.baseURL:=$menu.choice
				
				Form:C1466.saveProviders()
				This:C1470.updateUI()
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
		
		var $previous : Object:=This:C1470.previousItem
		
		If ($previous#Null:C1517)
			
			If (Not:C34($previous.validate()))
				
				ALERT:C41($previous.errors.join("\r"))
				
				var $index:=This:C1470.providers.indexOf($previous)
				LISTBOX SELECT ROW:C912(*; This:C1470.list; $index+1; lk replace selection:K53:1)
				
				return 
				
			End if 
		End if 
		
		This:C1470.previousItem:=OB Copy:C1225($cur)
		This:C1470.updateUI()
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function listMetaInfo($me : Object) : Object
	
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
/* TOUCH */This:C1470.providers:=This:C1470.providers
			
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
	
	//SET TIMER(-1)
	This:C1470.updateUI()
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function newProvider()
	
/* #17323
The model name shall be unique.
*/
	var $name:=Localized string:C991("newProvider")
	var $i : Integer
	
	// Check against singleton for uniqueness
	var $providers:=cs:C1710.OpenAIProviders.me
	var $existingKeys:=$providers.getProviderKeys()
	
	Repeat 
		
		If ($existingKeys.includes($name))
			
			$i+=1
			$name:=Localized string:C991("newProvider")+String:C10($i; " ##")
			
		Else 
			
			break
			
		End if 
	Until (False:C215)
	
	// Add to singleton with empty provider config
	$providers.addProvider($name; {\
		apiKey: ""; \
		baseURL: ""; \
		organization: ""; \
		project: ""\
		})
	
	// Refresh models from singleton
	This:C1470.readProviders()
	This:C1470.selectProvider($name)
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function deleteProvider($name : Text)
	
	var $c:=This:C1470.providers.indices("name = :1"; $name)
	
	If ($c.length<=0)
		return   // not found
	End if 
	
	// Check local listeners first (UI-level protection)
	var $couldDelete : Boolean:=True:C214
	var $listener : Object
	For each ($listener; This:C1470.listeners) Until (Not:C34($couldDelete))
		
		$couldDelete:=$listener.onBeforeDelete($name) || $couldDelete
		
	End for each 
	
	If ($couldDelete)
		
		// Delegate to OpenAIProviders singleton
		var $providers:=cs:C1710.OpenAIProviders.me
		var $result : Object:=$providers.removeProvider($name)
		
		If ($result.success)
			// Refresh providers from singleton
			This:C1470.readProviders()
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
	This:C1470.isTestingConnection:=True:C214
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
	
	This:C1470.isTestingConnection:=False:C215
	
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
		OBJECT SET RGB COLORS:C628(*; "connectionStatus"; 0x00666666; -1)  // Gray during testing
	Else 
		If (This:C1470.connectionModelsCount>0)
			OBJECT SET RGB COLORS:C628(*; "connectionStatus"; 0x00228B22; -1)  // Green for success
		Else 
			OBJECT SET RGB COLORS:C628(*; "connectionStatus"; 0x00CC0000; -1)  // Red for error
		End if 
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
	// Hide/show details based on selection
Function updateUI() : Boolean
	
	var $t : Text
	
	If (This:C1470.currentItem=Null:C1517)
		
		For each ($t; This:C1470._detailFields)
			
			OBJECT SET VISIBLE:C603(*; $t; False:C215)
			OBJECT SET VISIBLE:C603(*; $t+".label"; False:C215)
			
		End for each 
		
		return 
		
	End if 
	
	For each ($t; This:C1470._detailFields)
		
		OBJECT SET VISIBLE:C603(*; $t; True:C214)
		OBJECT SET VISIBLE:C603(*; $t+".label"; True:C214)
		
	End for each 
	
	return True:C214
	
	// MARK:- [PROVIDERS]
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function readProviders()
	This:C1470.providers:=cs:C1710.OpenAIProviders.me.toCollection()
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function saveProviders()
	cs:C1710.OpenAIProviders.me.fromCollection(This:C1470.providers)
	
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
	