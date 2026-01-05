var $e:=FORM Event:C1606

//If ($e.code=On Bound Variable Change)

//Form._snapshot:=OB Copy(Form.model)

//End if 

If ($e.objectName=Null:C1517)  // Form method
	
/*
Case of 
	
// ______________________________________________________
: ($e.code=On Load)
	
// Keep a snapshot of the current model definition
	
SET TIMER(-1)
	
// ______________________________________________________
: ($e.code=On Timer)
	
SET TIMER(0)
	
Form._snapshot:=Form._snapshot || Form.model=Null ? Null : OB Copy(Form.model)
	
// Mandatory or not fields labels style
$provider:=Form._provider || cs.Provider.new(Form.model)
OBJECT SET FONT STYLE(*; "apiKey.label"; Form._provider.needAPIKey ? Bold : Plain)
	
// ______________________________________________________
: ($e.code=On Bound Variable Change)
	
Form._snapshot:=OB Copy(Form.model)
	
// ______________________________________________________
End case 
*/
	
	
	return 
	
End if 

var $model : Object:=Form:C1466.model

If ($e.code=On Data Change:K2:15)
	
	// attention, si c'est le nom qui est modifié cela peut mettre en péril les vecteurs qui sont associés
	
	
	If (OBJECT Get subform container value:C1785#Null:C1517)
		
/* #17322
For each model, the name, api Key and model are required.
*/
		
/* ⚠️
		
* The name cannot be changed at this stage
* apiKey is not required if local
		
*/
/*
$provider:=Form._providers.query("baseURL = :1"; String(Form.model.baseURL) || "https://api.openai.com/@").first()
		
SET TIMER(-1)  // To update mandatory or not fields labels style
		
var $t : Text
For each ($t; $provider.needAPIKey ? ["name"; "apiKey"; "model"] : ["name"; "model"])
		
If (Length(String($model[$t]))=0)
		
Form._popError(\
Replace string(Localized string("theValueIsRequired."); "{value}"; Localized string($t)))
		
GOTO OBJECT(*; $t)
		
return 
		
End if 
End for each 
		
CALL SUBFORM CONTAINER(-1)
*/
		
	End if 
	
	Case of 
			
			
			//: ($e.objectName="name")
			
			//var $c : Collection:=Form.vectors.query("model = :1"; Form._snapshot.name)
			
			//If ($c.length>0)
			
			//CONFIRM(".Would you like to update the vectors using this model?"; ".Update")
			
			//If (Bool(OK))
			
			//var $vector : cs.Vector
			//For each ($vector; $c)
			
			////$vector.model:=
			
			//End for each 
			//End if 
			//End if 
			
			//______________________________________________________
		: ($e.objectName="baseURL")
			
			// Base URL changed - no special handling needed
			SET TIMER:C645(-1)  // To update UI
			
			//______________________________________________________
		: ($e.objectName="apiKey")
			
			// API Key changed - handled by form data binding
			
			//______________________________________________________
	End case 
End if 

Case of 
		
		//// ______________________________________________________
		//: ($e.objectName="baseURLMenu")  // Menu of preconfigured providers
		
		//GOTO OBJECT(*; "baseURL")
		
		//var $curbBase:=String(Form.model.baseURL)
		//var $menu:=cs._menu.new()
		
		//For each ($provider; Form._providers)
		
		//$menu.append($provider.name; $provider.baseURL).mark($curbBase=$provider.baseURL)
		
		//End for each 
		
		//If ($menu.popup($curbBase).selected)\
			&& ($menu.choice#$curbBase)
		
		//// Set the model baseURL
		//$provider:=Form._providers.query("baseURL = :1"; $menu.choice).first()
		//Form.model.baseURL:=$menu.choice
		
		//If ($provider.needToken#Null)
		
		//Form.model.apiKey:=$provider.endpoint.apiKey
		
		//End if 
		
		//Form.saveModels()
		
		//SET TIMER(-1)  // To update mandatory or not fields labels
		
		//End if 
		
		// ______________________________________________________
	: ($e.objectName="modelMenu")  // Menu of available models
		
		// Model menu functionality removed - model list comes from test connection
		
		
		//// ______________________________________________________
		//: ($e.objectName="done")  // New model
		
		///* #17323
		//The model name shall be unique.
		//*/
		//If (Form.models.extract("name").includes($model.name))
		
		//Form._popError(\
			Replace string(Localized string("theModelNameMustBeUnique"); "{name}"; $model.name))
		
		//GOTO OBJECT(*; "name")
		
		//return 
		
		//End if 
		
/* #17322
For each model, the name, api Key (if not local) and model are required.
*/
		//If (Length(String(Form.model.baseURL))=0)
		
		//$provider:=Form._providers.query("name = :1"; "openAI").first()
		
		//Else 
		
		//$provider:=Form._providers.query("baseURL = :1"; Form.model.baseURL).first()
		
		//End if 
		
/*
var $t : Text
For each ($t; $provider.needAPIKey ? ["name"; "model"; "apiKey"] : ["name"; "model"])
		
If (Length(String($model[$t]))=0)
		
Form._popError(\
Replace string(Localized string("theValueIsRequired."); "{value}"; Localized string($t)))
		
GOTO OBJECT(*; $t)
		
return 
		
End if 
End for each 
*/
		
		ACCEPT:C269
		
		// ______________________________________________________
End case 

