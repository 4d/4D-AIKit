property name : Text
property baseURL : Text
property needToken : Boolean
property endpoint : cs:C1710.AIKit.OpenAI
property models : Collection
property success:=True:C214

property OPENAI:="https://api.openai.com/@"

Class constructor($config)
	
	Case of 
			
			// ______________________________________________________
		: ($config=Null:C1517)  // Default to openAI
			
			This:C1470.name:="openAI"
			This:C1470.endpoint:=cs:C1710.AIKit.OpenAI.new(This:C1470.apiKey)
			
			// ______________________________________________________
		: (Value type:C1509($config)=Is object:K8:27)  // {apiKey: "your api key"; baseURL: "https://server.ai"}
			
			This:C1470.baseURL:=$config.baseURL || $config.base_url
			This:C1470.name:=$config.name || This:C1470.normalizedName(This:C1470.baseURL)
			This:C1470.needToken:=Bool:C1537($config.needToken)
			
			If (This:C1470.needToken)
				
				This:C1470.endpoint:=cs:C1710.AIKit.OpenAI.new({baseURL: This:C1470.baseURL; apiKey: This:C1470.apiKey})
				
			Else 
				
				This:C1470.endpoint:=cs:C1710.AIKit.OpenAI.new({baseURL: This:C1470.baseURL})
				
			End if 
			
			// ______________________________________________________
		Else 
			
			// ERROR
			
			// ______________________________________________________
	End case 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function loadModels()
	
	OB REMOVE:C1226(This:C1470; "models")
	
	If (This:C1470.endpoint=Null:C1517)
		
		This:C1470.success:=False:C215
		return 
		
	End if 
	
	var $models : cs:C1710.AIKit.OpenAIModelListResult:=This:C1470.endpoint.models.list()
	This:C1470.success:=$models.success
	
	If (This:C1470.success)
		
		This:C1470.models:=$models.models
		
	Else 
		
		ALERT:C41(".Failed to retrieve the list of models")
		
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
	// Retrieves provider models, if not already done, and returns a menu filled with them
Function menuModels($default : Text) : cs:C1710._menu
	
	If (This:C1470.models=Null:C1517)
		
		SET CURSOR:C469(4)
		This:C1470.loadModels()
		
	End if 
	
	If (Not:C34(This:C1470.success))
		
		return 
		
	End if 
	
	If (This:C1470.models.length=0)
		
		ALERT:C41(".No models found")
		return 
		
	End if 
	
	var $c:=This:C1470.models.query("id IN :1"; ["@embed@"])  // Only suggest names containing “embed”
	$c:=$c.length>0 ? $c : This:C1470.models  // ⚠️ Fallback on all models
	
	var $menu:=cs:C1710._menu.new()
	var $o : Object
	For each ($o; $c)
		
		$menu.append($o.id; $o.id).mark($default=$o.id).setData($o.id; $o)
		
	End for each 
	
	return $menu
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function normalizedName($url : Text) : Text
	
	If ($url=This:C1470.OPENAI)
		
		return "openAI"
		
	End if 
	
	var $t : Text
	For each ($t; ["https://"; "http://"; "api."; ".com"])
		
		$url:=Replace string:C233($url; $t; "")
		
	End for each 
	
	For each ($t; ["."; "/"; ":"])
		
		$url:=Replace string:C233($url; $t; "_")
		
	End for each 
	
	return $url
	
	// <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <== <==
Function get apiKey() : Text
	
	This:C1470.success:=True:C214  // We are optimistic 😇
	
	If (This:C1470.endpoint#Null:C1517)
		
		return This:C1470.endpoint.apiKey
		
	End if 
	
	// First, let's try reading an environment variable.
	var $envKey:=(Uppercase:C13(Replace string:C233(This:C1470.name; " "; "_"))+"_API_KEY")
	var $apikey:=String:C10(cs:C1710._Env.me[$envKey])
	
	If (Length:C16($apikey)>0)
		
		return $apiKey
		
	End if 
	
	// Finally, search for a file in the user preferences folder.
	var $file : 4D:C1709.File:=Folder:C1567(fk user preferences folder:K87:10).file(This:C1470.name+".json")
	
	Try
		
		$apikey:=String:C10(JSON Parse:C1218($file.getText()).apiKey)
		return $apikey
		
	Catch
		
		This:C1470.success:=False:C215  // ERROR
		
	End try
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function set apiKey($apikey : Text)
	
	If (This:C1470.endpoint#Null:C1517)
		
		This:C1470.endpoint.apiKey:=$apikey
		
		// Reset model list
		This:C1470.models:=[]
		
	End if 