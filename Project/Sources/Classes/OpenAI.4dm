// OpenAI client class

// MARK:- properties

// MARK: api resources
property completions : cs:C1710.OpenAICompletions
property chat : cs:C1710.OpenAIChat
// property embeddings : cs.OpenAIEmbeddings
// property files : cs.OpenAIFiles
property images : cs:C1710.OpenAIImages
// property audio : cs.OpenAIAudio
property moderations : cs:C1710.OpenAIModerations
property models : cs:C1710.OpenAIModels
// property fineTunings : cs.OpenAIFineTunings
// property beta : cs.OpenAIBeta
// property batches : cs.OpenAIBatches
// property uploads : cs.OpenAIUploads

// MARK: account options
property apiKey : Text:=""
property organization : Text:=""
property project : Text:=""

// MARK: clients options
//property version : Text:="v1"
property baseURL : Text:=""
// property websocketBaseURL : Text

property maxRetries : Integer:=2
property timeout : Real:=10*60

// property customHeaders : Object
// property customQuery : Object

// List of configurable attributes
property _configurable : Collection:=["apiKey"; "baseURL"; "websocketBaseURL"; "organization"; "project"; "version"; "maxRetries"]


// MARK: - constructor

Function _fillDefaultParameters()
	
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
	If (OB Instance of:C1731($object; 4D:C1709.File))
		
		$object:=Try(JSON Parse:C1218($object.getText()))
		If ($object#Null:C1517)
			This:C1470._configureParameters($object)
		End if 
		
	Else 
		var $key : Text
		For each ($key; $object)
			If (This:C1470._configurable.includes($key))
				This:C1470[$key]:=$object[$key]
			End if 
		End for each 
	End if 
	
/*
* Build an instance of OpenAI class.
* You could pass the apiKey as first Text argument
* and provide additional parameters as Object (as first or second argument)
 */
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
				: ((Count parameters:C259>1) && (Value type:C1509($parameters[1])=Is text:K8:3))
					
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
	
Function _authHeaders() : Object
	return {Authorization: "Bearer "+String:C10(This:C1470.apiKey)}
	
Function _headers() : Object
	var $headers:=This:C1470._authHeaders()
	
	If (Length:C16(This:C1470.organization)>0)
		$headers["OpenAI-Organization"]:=This:C1470.organization
	End if 
	If (Length:C16(This:C1470.project)>0)
		$headers["OpenAI-Project"]:=This:C1470.project
	End if 
	return $headers
	
	// MARK:- client functions
	
Function _request($httpMethod : Text; $path : Text; $body : Object; $parameters : cs:C1710.OpenAIParameters; $resultType : 4D:C1709.Class) : cs:C1710.OpenAIResult
	If ($resultType=Null:C1517)
		$resultType:=cs:C1710.OpenAIResult
	End if 
	var $result:=$resultType.new()
	
	var $url:=This:C1470.baseURL+$path
	var $headers:=This:C1470._headers()
	
	var $options:={method: $httpMethod; headers: $headers; dataType: "auto"}
	If ($body#Null:C1517)
		$options.body:=$body
	End if 
	// XXX: if not only object maybe do other stuff (ex: upload file etc...)
	$headers["Content-Type"]:="application/json"
	If (($parameters#Null:C1517) && ($parameters.timeout>0))
		$options.timeout:=$parameters.timeout
	Else 
		$options.timeout:=This:C1470.timeout
	End if 
	
	$result.request:=4D:C1709.HTTPRequest.new($url; $options)
	
	$result.request.wait()
	
	return $result
	
Function _get($path : Text; $parameters : cs:C1710.OpenAIParameters; $resultType : 4D:C1709.Class) : cs:C1710.OpenAIResult
	return This:C1470._request("GET"; $path; Null:C1517; $parameters; $resultType)
	
Function _post($path : Text; $body : Variant; $parameters : cs:C1710.OpenAIParameters; $resultType : 4D:C1709.Class) : cs:C1710.OpenAIResult
	return This:C1470._request("POST"; $path; $body; $parameters; $resultType)
	
Function _delete($path : Text; $parameters : cs:C1710.OpenAIParameters; $resultType : 4D:C1709.Class) : cs:C1710.OpenAIResult
	return This:C1470._request("DELETE"; $path; Null:C1517; $parameters; $resultType)
	
Function _getApiList($path : Text; $queryParameters : Object; $parameters : cs:C1710.OpenAIParameters; $resultType : 4D:C1709.Class) : cs:C1710.OpenAIResult
	return This:C1470._request("GET"; $path+This:C1470._encodeQueryParameters($queryParameters); Null:C1517; $parameters; $resultType)
	
Function _encodeQueryParameter($value : Variant) : Text
	// TODO: more encoding stuff, escaping if needed, etc...
	return String:C10($value)
	
Function _encodeQueryParameters($queryParameters : Object) : Text
	If (($queryParameters=Null:C1517) || OB Is empty:C1297($queryParameters))
		return ""
	End if 
	
	return "?"+OB Entries:C1720($queryParameters).map(Formula:C1597($1.value.key+"="+This:C1470._encodeQueryParameter($1.value.value))).join("&")
	
	
	