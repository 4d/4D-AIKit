
// root parameters
property type : Text:="function"
property strict : Boolean

// common parameters

// Name of the tool, work as id
property name : Text
// Description of tool, help LLM to select it
property description : Text

// function parameters

// Parameters of function as JSON schema
property parameters : Object

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	
	If ($object.tool#Null:C1517)  // support format from registerTools too
		
		$object:=$object.tool
		
	End if 
	
	
	// allow to provide OpenAI format
	If ((String:C10($object.type)="function") && (Value type:C1509($object.function)=Is object:K8:27))
		
		If (OB Is defined:C1231($object; "strict"))
			This:C1470.strict:=Bool:C1537($object.strict)
		End if 
		
		$object:=$object.function
		
	End if 
	
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 
	
Function body() : Object
	
	Case of 
			
		: (This:C1470.type="function")
			
			var $body : Object
			$body:={type: "function"; \
				function: {\
				name: This:C1470.name; \
				description: This:C1470.description; \
				parameters: This:C1470.parameters\
				}; \
				strict: Bool:C1537(This:C1470.strict)}
			
			If (This:C1470.strict=Null:C1517)
				OB REMOVE:C1226($body; "strict")
			End if 
			
			return $body
			
		: (This:C1470.type="custom")  // for response endpoints
			
			//%W-550.26
			return {type: "custom"; \
				name: This:C1470.name; \
				description: This:C1470.description; \
				format: This:C1470.format}
			//%W+550.26
			
	End case 
	
	// build-in? for response endpoint
	$body:={type: This:C1470.type}
	
	// type: "web_search" 
	// type: "file_search",    vector_store_idsvector_store_ids
	// type:"mcp" , server_label, server_description, server_url, require_approval
	
	var $key : Text
	For each ($key; This:C1470)
		
		Case of 
			: (($key="name") || ($key="description"))
				
				If (Length:C16(This:C1470[$key])>0)  // exclude empty value set by 4D because of properties
					$body[$key]:=This:C1470[$key]
				End if 
			: ($key="strict")
				// ignore
			Else 
				
				$body[$key]:=This:C1470[$key]
				
		End case 
		
	End for each 
	
	
	return $body