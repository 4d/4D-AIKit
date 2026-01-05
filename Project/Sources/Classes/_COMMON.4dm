property settings : Object
property models : Collection

property providers:={}

property PROVIDERS:=[]
property OPENAI:="https://api.openai.com/@"

// Main list
property list:="list"
property currentItem : Object
property itemPosition : Integer
property selectedItems : Collection

// Details panel
property _detailFields : Collection

property DEBUG:=Structure file:C489=Structure file:C489(*)

// ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___ --- ___
Class constructor
	
	// Mark: Load predefined providers
	var $file:=File:C1566("/RESOURCES/providers.json")
	This:C1470.PROVIDERS:=JSON Parse:C1218($file.getText()).map(Formula:C1597(cs:C1710.Provider.new($1.value)))
	
	// Mark: Default provider
	This:C1470.providers.openAI:=cs:C1710.Provider.new()
	
	This:C1470.read()
	
	If (Storage:C1525.studio=Null:C1517)
		
		Use (Storage:C1525)
			
			Storage:C1525.studio:=New shared object:C1526("MODELS"; 0)
			
		End use 
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function read()
	
	This:C1470.readModels()
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
	// Shared actions
Function manager($e : Object; $from : Text)
	
	Case of 
			
			// ________________________________________________________________________________
		: ($e.code=On Load:K2:1)
			
			Use (Storage:C1525.studio)
				
				Storage:C1525.studio[$from]:=Current form window:C827
				
			End use 
			
			SET TIMER:C645(-1)
			
			// ______________________________________________________
		: ($e.code=On Timer:K2:25)
			
			SET TIMER:C645(0)
			
			// ______________________________________________________
		: ($e.code=On Activate:K2:9)
			
			If (Length:C16(OBJECT Get name:C1087(Object with focus:K67:3))=0)
				
				GOTO OBJECT:C206(*; This:C1470.list)
				
			End if 
			
			// ______________________________________________________
		: ($e.code=On Unload:K2:2)
			
			Use (Storage:C1525.studio)
				
				Storage:C1525.studio[$from]:=0
				
			End use 
			
			// ________________________________________________________________________________
	End case 
	
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
	
	// MARK:- [SETTINGS]
	// <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <==
Function get settingsFile() : 4D:C1709.File
	
	// Models are saved in a JSON file named "AIProviders.json" in the "Settings" folder
	return Folder:C1567(fk database folder:K87:14; *).file("Settings/AIProviders.json")
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function readSettings()
	
	Try
		
		This:C1470.settings:=JSON Parse:C1218(This:C1470.settingsFile.getText())
		
	Catch
		
		This:C1470.settings:={models: []}
		
	End try
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function writeSettings()
	
	This:C1470.settingsFile.setText(JSON Stringify:C1217(This:C1470.settings; *))
	
	// MARK:- [MODELS]
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function readModels()
	
	// Delegate to OpenAIProviders singleton (single source of truth)
	var $providers:=cs:C1710.OpenAIProviders.me.toCollection()
	var $models:=[]
	
	var $provider : Object
	For each ($provider; $providers)
		
		$models.push(cs:C1710.Model.new($provider))
		
	End for each 
	
	This:C1470.models:=$models
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function saveModels($models : Collection)
	
	// Delegate to OpenAIProviders singleton (single source of truth)
	var $toSave:=($models=Null:C1517) ? This:C1470.models : $models
	var $rawModels:=[]
	
	//%W-550.26
	var $model : cs:C1710.Model
	For each ($model; $toSave)
		
		$rawModels.push({\
			name: $model.name; \
			apiKey: $model.apiKey; \
			baseURL: $model.baseURL; \
			organization: $model.organization; \
			project: $model.project\
			})
		
	End for each 
	//%W+550.26
	
	cs:C1710.OpenAIProviders.me.fromCollection($rawModels)
	
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
	
	