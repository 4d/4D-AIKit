property name : Text  // Name displayed in the drop list for the user)
property model : Text  // The identifier of the model to retrieve. (e.g., “text-embedding-3-large”)
property apiKey : Text  // OpenAI API Key.

property baseURL : Text  // Base URL for OpenAI API requests. (optional)
property organization : Text  // OpenAI Organization ID. (optional)
property project : Text  // OpenAI Project ID. (optional)

property needAPIKey : Boolean
property valid : Boolean
property errors:=[]

property _uid:=Generate UUID:C1066
property _provider : cs:C1710.Provider

Class constructor(\
$name; \
$model : Text; \
$apiKey : Text; \
$optionals : Object)
	
	If (Value type:C1509($name)=Is object:K8:27)
		
		var $key : Text
		
		For each ($key; $name)
			
			This:C1470[$key]:=$name[$key]
			
		End for each 
		
	Else 
		
		This:C1470.name:=$name
		This:C1470.model:=$model  //|| "text-embedding-3-large"
		This:C1470.apiKey:=$apiKey
		
		If ($optionals#Null:C1517)
			
			For each ($key; $optionals)
				
				This:C1470[$key]:=$optionals[$key]
				
			End for each 
		End if 
	End if 
	
	// === === === === === === === === === === === === === === === === === === === === === === === === === === ===
Function validate() : Boolean
	
/* #17322
For each model, the name, api Key (if not local) and model are required.
*/
	
	var $t : Text
	
	For each ($t; This:C1470._provider.needToken ? ["name"; "apiKey"; "model"] : ["name"; "model"])
		
		var $errorText:=Replace string:C233(Localized string:C991("theValueIsRequired."); "{value}"; Localized string:C991($t))
		
		If (Length:C16(String:C10(This:C1470[$t]))=0)
			
			If (Not:C34(This:C1470.errors.includes($errorText)))
				
				This:C1470.errors.push($errorText)
				
			End if 
			
		Else 
			
			var $index:=This:C1470.errors.indexOf($errorText)
			
			If ($index#-1)
				
				This:C1470.errors.remove($index)
				
			End if 
		End if 
	End for each 
	
	return This:C1470.errors.length=0