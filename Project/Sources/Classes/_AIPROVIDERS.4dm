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

// ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___
Class constructor
	
	// Mark: Load predefined providers from providers.json as plain objects
	var $file:=File:C1566("/RESOURCES/providers.json")
	This:C1470.WELLKNOWN_PROVIDERS:=JSON Parse:C1218($file.getText()).map(Formula:C1597(cs:C1710._OpenAIProvider.new($1.value)))
	
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
				
				cs:C1710.OpenAIProviders.me.addListener(This:C1470)
				
				// ________________________________________________________________________________
			: ($e.code=On Unload:K2:2)
				
				cs:C1710.OpenAIProviders.me.removeListener(This:C1470)
				
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
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function listManager($e : Object)
	
	$e:=$e || FORM Event:C1606
	var $cur:=This:C1470.currentItem
	
	If ($e.code=On Selection Change:K2:29)  // ⚠️ This event must be enabled for both the list box AND the form.
		
		If ($cur#Null:C1517)
			This:C1470.previousItem:=OB Copy:C1225($cur)
		End if 
		
		This:C1470.updateUI()
		
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
				$providers.save()
				This:C1470.previousItem.name:=$newName
				This:C1470.readProviders()
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
	$menu.append($custom; "")
	$menu.line()
	
	var $wellKnown; $provider : cs:C1710._OpenAIProvider
	var $wellKnowns:=This:C1470.WELLKNOWN_PROVIDERS
	// TODO: filter on ones that are already in provider list, so do not propose them
	
	
	For each ($wellKnown; $wellKnowns)
		
		$menu.append($wellKnown.name; $wellKnown.baseURL)
		If (Folder:C1567(fk resources folder:K87:11).file(Replace string:C233($wellKnown.name; " "; "")+".png").exists)
			$menu.icon("Path:/RESOURCES/"+Replace string:C233($wellKnown.name; " "; "")+".png")
		End if 
		
	End for each 
	
	If ($menu.popup().selected)
		
		// Set the provider baseURL from selected well-known provider
		$wellKnown:=Form:C1466.WELLKNOWN_PROVIDERS.query("baseURL = :1"; $menu.choice).first()
		
		var $name : Text:=$wellKnown.name
		If ($name=$custom)
			$name:=Localized string:C991("newProvider")
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
			baseURL: $wellKnown.baseURL; \
			apiKey: ""; \
			organization: ""; \
			project: ""\
			})
		$providers.save()
		
		// Refresh models from singleton
		This:C1470.readProviders()
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
	
	If ($result.success)
		var $modelCount : Integer:=$result.models.length
		This:C1470.connectionModelsCount:=$modelCount
		This:C1470.connectionStatus:="🟢 "+(Localized string:C991("connected") || "Connected")+" ("+String:C10($modelCount)+" "+(Localized string:C991("models") || "models")+")"
		This:C1470.connectionStatusToolTip:=$result.models.map(Formula:C1597($1.value.id)).join("\n")
	Else 
		This:C1470.connectionModelsCount:=0
		var $errorMsg : Text:="❌ "+(($result.errors.length>0) ? $result.errors[0].message : "Connection failed")
		This:C1470.connectionStatus:=$errorMsg
		This:C1470.connectionStatusToolTip:=$result.errors.map(Formula:C1597($1.value.message)).join("\n")
	End if 
	
	This:C1470._updateConnectionStatusUI()
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function _updateConnectionStatusUI()
	
	// Update the status text color based on result
	If (This:C1470.isTestingConnection)
		OBJECT SET HELP TIP:C1181(*; "connectionStatus"; "")
	Else 
		OBJECT SET HELP TIP:C1181(*; "connectionStatus"; This:C1470.connectionStatusToolTip)
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