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
property apiKey : Text:=""
property organization : Text:=""
property project : Text:=""

// MARK: clients options
property version : Text:="v1"
property baseURL : Text:=""
// property websocketBaseURL : Text

property maxRetries : Integer:=2
// property timeout : Integer or TimeOut object

// property customHeaders : Object
// property customQuery : Object

// List of configurable attributes
property _configurable : Collection:=["apiKey"; "baseURL"; "websocketBaseURL"; "organization"; "project"; "version"; "maxRetries"]


// MARK: - constructor

Function _fillDefaultParameters()
	// TODO: fill with env variable
	
	If (Length:C16(This:C1470.apiKey)=0)
		
		This:C1470.apiKey:=cs:C1710._Env.me["OPENAI_API_KEY"] || ""
		
	End if 
	
	If (Length:C16(This:C1470.organization)=0)
		
		This:C1470.organization:=cs:C1710._Env.me["OPENAI_ORG_ID"] || ""
		
	End if 
	
	If (Length:C16(This:C1470.project)=0)
		
		This:C1470.project:=cs:C1710._Env.me["OPENAI_PROJECT_ID"] || ""
		
	End if 
	
	If (Length:C16(This:C1470.baseURL)=0)
		
		This:C1470.baseURL:=cs:C1710._Env.me["OPENAI_BASE_URL"] || "https://api.openai.com/v1"
		
	End if 
	
Function _configureParameters($object : Object)
	var $key : Text
	For each ($key; $object)
		If (This:C1470._configurable.includes($key))
			This:C1470[$key]:=$object[$key]
		End if 
	End for each 
	
Class constructor( ...  : Variant)
	var $parameters:=Copy parameters:C1790()
	
	This:C1470.completions:=cs:C1710.OpenAICompletions.new(This:C1470)
	This:C1470.chat:=cs:C1710.OpenAIChat.new(This:C1470)
	// This.embeddings:=cs.OpenAIEmbeddings.new(This)
	// This.files:=cs.OpenAIFiles.new(This)
	This:C1470.images:=cs:C1710.OpenAIImages.new(This:C1470)
	// This.audio:=cs.OpenAIAudio.new(This)
	This:C1470.moderations:=cs:C1710.OpenAIModerations.new(This:C1470)
	This:C1470.models:=cs:C1710.OpenAIModels.new(This:C1470)
	
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
			
			throw:C1805(1; "Wrong parameter type. Expecting Object or Text")
			
	End case 
	
	This:C1470._fillDefaultParameters()
	
	// MARK:- headers
	
Function authHeaders() : Object
	return {Authorization: "Bearer "+String:C10(This:C1470.apiKey)}
	
	// default headers // OpenAI-Organization, OpenAI-Project
	
	
	// MARK:- client functions
	
Function _request($httpMethod : Text; $path : Text; $body : Variant; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	var $result:=cs:C1710.OpenAIResult.new()
	
	// TODO: network stuff
	
	return $result
	
Function _get($path : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._request("GET"; $path; Null:C1517; $parameters)
	
Function _post($path : Text; $body : Variant; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._request("POST"; $path; $body; $parameters)
	
Function _delete($path : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	return This:C1470._request("DELETE"; $path; Null:C1517; $parameters)
	
Function _getApiList($path : Text; $query : Object; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIResult
	// TODO: same as get but maybe with post processing and manage query
	return This:C1470._request("GET"; $path; Null:C1517; $parameters)
	