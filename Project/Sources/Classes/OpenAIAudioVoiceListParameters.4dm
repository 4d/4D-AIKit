// Parameters for listing voices

// The path of the endpoint which lists the voices, ie. "/voices". By default it depends on the server.
property path : Text

// Only return the voices of this model, when known
property model : Text

// Query parameters to send to the server, ie. {limit: 50}
property query : Object

// Add the custom voices of the client to the built-in ones, when the server has no endpoint to list voices. Default: True
property custom : Boolean:=True

Class extends OpenAIParameters

Class constructor($object : Object)
	Super($object)
	
Function body() : Object
	var $body:={}
	
	var $key : Text
	If (This.query#Null)
		For each ($key; This.query)
			$body[$key]:=This.query[$key]
		End for each 
	End if 
	
	return $body
