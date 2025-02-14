// OpenAI client class

// MARK:- properties

// MARK: api resources
property completions : cs:C1710.OpenAICompletions
property chat : cs:C1710.OpenAIChat
// property embeddings : cs.OpenAIEmbeddings
// property files : cs.OpenAIFiles
property images : cs:C1710.OpenAIImages
//  property audio : cs.OpenAIAudio
property moderations : cs:C1710.OpenAIModerations
property models : cs:C1710.OpenAIModels
// fine tunings, beta, batches, uploads, etc...

// MARK: account options
property apiKey : Text
property organization : Text:=""
property project : Text:=""

// MARK: clients options
property version : Text:="v1"
property baseURL : Text
// property websocketBaseURL : Text
//property _strictResponseValidation : Boolean
property maxRetries : Integer:=2
// property timeout : 

// property custom_headers : Object
// property custom_query : Object


// MARK: - constructor

Function _fillDefaultParameters()
	// TODO: fill with env variable
	
Function _configureParameters($object : Object)
	var $key : Text
	For each ($key; $object)
		// TODO: check configuration key authorized: apiKey, baseURL, websocketBaseURL, organization, project
		This:C1470[$key]:=$object[$key]
	End for each 
	
	
Class constructor( ...  : Variant)
	var $parameters:=Copy parameters:C1790()
	
	If (Count parameters:C259=0)
		This:C1470._fillDefaultParameters()
		return 
	End if 
	
	Case of 
		: (Value type:C1509($parameters[0])=Is text:K8:3)
			
			// we set first as api key
			This:C1470.apiKey:=$parameters[0]
			
			Case of 
				: ((Count parameters:C259>1) && Value type:C1509($parameters[1])=Is text:K8:3)
					
					This:C1470.baseURL:=$parameters[1]
					
				: ((Count parameters:C259>1) && (Value type:C1509($parameters[1])=Is object:K8:27))
					
					This:C1470._configureParameters($parameters[1])
					
			End case 
			
		: (Value type:C1509($parameters[0])=Is object:K8:27)
			
			This:C1470._configureParameters($parameters[0])
			
		Else 
			
			// TODO: throw instead of alert?
			ASSERT:C1129(False:C215; "Wrong parameter type")
			
	End case 
	
	This:C1470._fillDefaultParameters()
	
	
	
	// MARK: - client functions
	
Function _request($httpMethod : Text; $path : Text; $body : Variant; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	// TODO: network stuff
	
Function _get($path : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._request("GET"; $path; Null:C1517; $parameters)
	
Function _post($path : Text; $body : Variant; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._request("POST"; $path; $body; $parameters)
	
Function _delete($path : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._request("DELETE"; $path; Null:C1517; $parameters)
	