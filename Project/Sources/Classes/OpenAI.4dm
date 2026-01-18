// OpenAI client class

// MARK:- properties

// MARK: api resources
// property completions : cs:C1710.OpenAICompletionsAPI // deprecated
property chat : cs:C1710.OpenAIChatAPI
property embeddings : cs:C1710.OpenAIEmbeddingsAPI
property files : cs:C1710.OpenAIFilesAPI
property images : cs:C1710.OpenAIImagesAPI
// property audio : cs.OpenAIAudioAPI
property moderations : cs:C1710.OpenAIModerationsAPI
property models : cs:C1710.OpenAIModelsAPI
// property fineTunings : cs.OpenAIFineTuningsAPI
// property beta : cs.OpenAIBetaAPI
// property batches : cs.OpenAIBatchesAPI
// property uploads : cs.OpenAIUploadsAPI

// MARK: account options
property apiKey : Text:=""
property organization : Text:=""
property project : Text:=""

// MARK: clients options
//property version : Text:="v1"
property baseURL : Text:=""
// property websocketBaseURL : Text

property _providers : cs:C1710.OpenAIProviders:=cs:C1710.OpenAIProviders.new()

// The maximum number of retry attempts for failed requests. Defaults to 2.
property maxRetries : Integer:=2
property timeout : Real:=10*60
property httpAgent : 4D:C1709.HTTPAgent:=Null:C1517

property customHeaders : Object
// property customQuery : Object

// List of configurable attributes
property _configurable : Collection:=["apiKey"; "baseURL"; "organization"; "project"; "maxRetries"; "timeout"; "httpAgent"; "customHeaders"]

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
	
	//  This:C1470.completions:=cs:C1710.OpenAICompletionsAPI.new(This:C1470)
	This:C1470.chat:=cs:C1710.OpenAIChatAPI.new(This:C1470)
	This:C1470.embeddings:=cs:C1710.OpenAIEmbeddingsAPI.new(This:C1470)
	This:C1470.files:=cs:C1710.OpenAIFilesAPI.new(This:C1470)
	This:C1470.images:=cs:C1710.OpenAIImagesAPI.new(This:C1470)
	// This.audio:=cs.OpenAIAudioAPI.new(This)
	This:C1470.moderations:=cs:C1710.OpenAIModerationsAPI.new(This:C1470)
	This:C1470.models:=cs:C1710.OpenAIModelsAPI.new(This:C1470)
	
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
					
					// if second string parameter, supose baseURL
					This:C1470.baseURL:=$parameters[1]
					
				: ((Count parameters:C259>1) && (Value type:C1509($parameters[1])=Is object:K8:27))
					
					// else configurable parameters as object
					This:C1470._configureParameters($parameters[1])
					
			End case 
			
		: (Value type:C1509($parameters[0])=Is object:K8:27)
			
			This:C1470._configureParameters($parameters[0])
			
		Else 
			
			ASSERT:C1129(False:C215; "Wrong parameter type ("+String:C10(Value type:C1509($parameters[0]))+") Expecting Object or Text")
			
	End case 
	
	This:C1470._fillDefaultParameters()
	
	// MARK:- Model Alias Resolution
	
Function _resolveModelFromBody($body : Variant) : Object
	// Returns resolved config object with baseURL, apiKey, model
	// If no resolution needed, returns object with empty values (use instance defaults)
	var $config:={baseURL: ""; apiKey: ""; model: ""}
	
	// Check if body is an object with a model property
	If (($body=Null:C1517) || (Value type:C1509($body)#Is object:K8:27) || (OB Instance of:C1731($body; 4D:C1709.Blob)))
		return $config
	End if 
	
	var $modelString : Text:=$body.model || ""
	If (Length:C16($modelString)=0)
		return $config
	End if 
	
	// Try to resolve the model alias
	var $resolved:=This:C1470._providers._resolveModel($modelString)
	
	If ($resolved.success)
		$config.model:=$resolved.model  // right part
		
		If (Length:C16($resolved.baseURL)>0)
			$config.baseURL:=$resolved.baseURL
		End if 
		If (Length:C16($resolved.apiKey)>0)
			$config.apiKey:=$resolved.apiKey
		End if 
		
	End if 
	
	return $config
	
	// MARK:- headers
	
Function _authHeaders() : Object
	If (Length:C16(String:C10(This:C1470.apiKey))=0)
		return {}
	End if 
	var $headers:={Authorization: "Bearer "+String:C10(This:C1470.apiKey)}
	If (String:C10(This:C1470.baseURL)="https://api.anthropic.com/v1")
		$headers["x-api-key"]:=String:C10(This:C1470.apiKey)
		$headers["anthropic-version"]:="2023-06-01"
	End if 
	return $headers
	
	If (Length:C16(String:C10($apiKey))=0)
		return {}
	End if 
	var $headers:={Authorization: "Bearer "+String:C10($apiKey)}
	
	// Detect provider from baseURL to set appropriate headers
	var $baseURL : Text:=(Length:C16($resolvedConfig.baseURL)>0) ? $resolvedConfig.baseURL : This:C1470.baseURL
	If (String:C10($baseURL)="https://api.anthropic.com/v1")
		$headers["x-api-key"]:=String:C10($apiKey)
		$headers["anthropic-version"]:="2023-06-01"
		$headers["anthropic-beta"]:="structured-outputs-2025-11-13"
		//https://platform.claude.com/docs/en/build-with-claude/structured-outputs
	End if 
	return $headers
	
Function _headers($resolvedConfig : Object) : Object
	var $headers:=This:C1470._authHeaders($resolvedConfig)
	
	If (Length:C16(This:C1470.organization)>0)
		$headers["OpenAI-Organization"]:=This:C1470.organization
	End if 
	If (Length:C16(This:C1470.project)>0)
		$headers["OpenAI-Project"]:=This:C1470.project
	End if 
	return $headers
	
	// MARK:- client functions
	
Function _request($httpMethod : Text; $path : Text; $body : Variant; $parameters : cs:C1710.OpenAIParameters; $resultType : 4D:C1709.Class) : cs:C1710.OpenAIResult
	If ($resultType=Null:C1517)
		$resultType:=cs:C1710.OpenAIResult
	End if 
	var $result : cs:C1710.OpenAIResult:=$resultType.new()
	
	var $url:=This:C1470.baseURL+$path
	var $headers:=This:C1470._headers()
	
	var $options:={method: $httpMethod; headers: $headers; dataType: "auto"}
	
	If (OB Instance of:C1731($parameters; cs:C1710.OpenAIChatCompletionsParameters))
		var $chatCompletionsParameters : cs:C1710.OpenAIChatCompletionsParameters:=$parameters
		If ($chatCompletionsParameters.stream)
			$options.decodeData:=True:C214  //Gemini returns encoded data
		End if 
	End if 
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIParameters)))
		$parameters:=cs:C1710.OpenAIParameters.new($parameters)
	End if 
	
	// Resolve model alias from body.model if applicable
	var $resolvedConfig:=This:C1470._resolveModelFromBody($body)
	
	// Update body.model if resolution was applied
	If (Length:C16($resolvedConfig.model)>0 && (Value type:C1509($body)=Is object:K8:27) && (Not:C34(OB Instance of:C1731($body; 4D:C1709.Blob))))
		$body.model:=$resolvedConfig.model
	End if 
	
	// Determine baseURL (use resolved if available, otherwise use instance baseURL)
	var $baseURL : Text:=(Length:C16($resolvedConfig.baseURL)>0) ? $resolvedConfig.baseURL : This:C1470.baseURL
	var $url:=$baseURL+$path
	var $headers:=This:C1470._headers($resolvedConfig)
	
	var $options:={method: $httpMethod; headers: $headers; dataType: "auto"}
	
	var $async:=$parameters._isAsync()
	If ($async)
		var $processType : Integer:=Process info:C1843(Current process:C322).type
		If (Asserted:C1132(($processType#Created from execution dialog:K36:14)/*notThreadSafe:&& (($processType#Other user process) || (Current form window>0))*/; "Formula callback will never be called asynchronously with user process. Please create a worker or be in form/app context"))
			$options:=cs:C1710._OpenAIAsyncOptions.new($options; This:C1470; $parameters; $result)
		Else 
			$async:=False:C215  // transform into sync
		End if 
	End if 
	
	var $headerKey : Text
	var $boundary : Text
	var $bodyText : Text
	
	Case of 
		: ($body=Null:C1517)
			$headers["Content-Type"]:="application/json"
		: ((Value type:C1509($body)=Is object:K8:27) && (Not:C34(OB Instance of:C1731($body; 4D:C1709.Blob))))
			$headers["Content-Type"]:="application/json"
			$options.body:=$body
		: ((Value type:C1509($body)=Is BLOB:K8:12) || ((Value type:C1509($body)=Is object:K8:27) && (OB Instance of:C1731($body; 4D:C1709.Blob))))
			// Handle Blob-based multipart form-data
			// Boundary should be in parameters["_boundary"]
			If ($parameters#Null:C1517) && ($parameters["_boundary"]#Null:C1517)
				$boundary:=$parameters["_boundary"]
			Else 
				$boundary:=Generate UUID:C1066
			End if 
			$headers["Content-Type"]:="multipart/form-data; boundary="+$boundary
			$options.body:=$body
		: ((Value type:C1509($body)=Is text:K8:3) && (Position:C15("{boundary}"; $body)>0))
			$boundary:=Generate UUID:C1066
			$headers["Content-Type"]:="multipart/form-data; boundary="+$boundary
			$options.body:=Replace string:C233($body; "{boundary}"; $boundary)
		Else 
			$options.body:=$body
	End case 
	If (This:C1470.customHeaders#Null:C1517)
		For each ($headerKey; This:C1470.customHeaders)
			$headers[$headerKey]:=This:C1470.customHeaders[$headerKey]
		End for each 
	End if 
	If (($parameters#Null:C1517) && ($parameters.extraHeaders#Null:C1517))
		For each ($headerKey; $parameters.extraHeaders)
			$headers[$headerKey]:=$parameters.extraHeaders[$headerKey]
		End for each 
	End if 
	
	
	If ($parameters.timeout>0)
		$options.timeout:=$parameters.timeout
	Else 
		$options.timeout:=This:C1470.timeout
	End if 
	
	If ($parameters.httpAgent#Null:C1517)
		$options.agent:=$parameters.httpAgent
	Else 
		$options.agent:=This:C1470.httpAgent
	End if 
	
	This:C1470._initRetry($options; $parameters)
	This:C1470._doHTTPRequest($url; $options; $result; Not:C34($async); $parameters)
	
	return $result
	
Function _doHTTPRequest($url : Text; $options : Object; $result : cs:C1710.OpenAIResult; $wait : Boolean; $parameters : cs:C1710.OpenAIParameters)
	$result.request:=4D:C1709.HTTPRequest.new($url; $options)
	
	If ($wait)
		$result.request.wait()
		
		If ((Not:C34($result.success)) && ($result._shouldRetry()) && ($options._remainingRetries>0))
			This:C1470._delayProcessAfterRetry($options; $result)
			$options._remainingRetries-=1
			This:C1470._doHTTPRequest($url; $options; $result; $wait; $parameters)
			return 
		End if 
		
		// sync with call back (due to fallback)
		_openAICallbacks($parameters; $result)
		
		If (Bool:C1537($parameters.throw))
			$result.throw()
		End if 
		
	End if 
	
Function _get($path : Text; $parameters : cs:C1710.OpenAIParameters; $resultType : 4D:C1709.Class) : cs:C1710.OpenAIResult
	return This:C1470._request("GET"; $path; Null:C1517; $parameters; $resultType)
	
Function _post($path : Text; $body : Variant; $parameters : cs:C1710.OpenAIParameters; $resultType : 4D:C1709.Class) : cs:C1710.OpenAIResult
	return This:C1470._request("POST"; $path; $body; $parameters; $resultType)
	
Function _delete($path : Text; $parameters : cs:C1710.OpenAIParameters; $resultType : 4D:C1709.Class) : cs:C1710.OpenAIResult
	return This:C1470._request("DELETE"; $path; Null:C1517; $parameters; $resultType)
	
Function _getApiList($path : Text; $queryParameters : Object; $parameters : cs:C1710.OpenAIParameters; $resultType : 4D:C1709.Class) : cs:C1710.OpenAIResult
	return This:C1470._request("GET"; $path+This:C1470._encodeQueryParameters($queryParameters); Null:C1517; $parameters; $resultType)
	
Function _postFiles($path : Text; $body : Object; $files : Object; $parameters : cs:C1710.OpenAIParameters; $resultType : 4D:C1709.Class) : cs:C1710.OpenAIResult
	var $boundary : Text:=Generate UUID:C1066
	var $formDataBlob:=This:C1470._formData($body; $files; $boundary)
	// Store boundary for _request to use
	If ($parameters=Null:C1517)
		$parameters:=cs:C1710.OpenAIParameters.new()
	End if 
	$parameters["_boundary"]:=$boundary
	return This:C1470._request("POST"; $path; $formDataBlob; $parameters; $resultType)
	
	// MARK:- retry utils
	
Function _initRetry($options : Object; $parameters : cs:C1710.OpenAIParameters)
	If (($parameters#Null:C1517) && ($parameters.maxRetries>0))
		$options._maxRetries:=$parameters.maxRetries
	Else 
		$options._maxRetries:=This:C1470.maxRetries
	End if 
	$options._remainingRetries:=$options._maxRetries
	
Function _calculateRetryTimeout($options : Object; $result : cs:C1710.OpenAIResult) : Integer
	
	var $retryAfter:=$result._retryAfterValue()
	If (($retryAfter>0) && ($retryAfter<=60))  // if it's a reasonable amount
		return $retryAfter
	End if 
	
	var $maxRetries : Integer:=$options._maxRetries || 0
	var $remainingRetries : Integer:=$options._remainingRetries || 0
	var $nbRetries : Integer:=$maxRetries-$remainingRetries
	$nbRetries:=($nbRetries>1000) ? 1000 : $nbRetries  // max 1000 to aovid pow failed
	
	var $sleepSeconds:=2^$nbRetries
	$sleepSeconds:=($sleepSeconds>80) ? 80 : $sleepSeconds
	
	var $jitter:=1-(0.25*((Random:C100%100)/100.0001))
	var $timeout : Integer:=$sleepSeconds*$jitter
	
	return ($timeout>=0) ? $timeout : 0
	
Function _delayProcessAfterRetry($options : Object; $result : cs:C1710.OpenAIResult) : Integer
	var $duration:=This:C1470._calculateRetryTimeout($options; $result)
	DELAY PROCESS:C323(Current process:C322; $duration)
	
	// MARK:- http utils
Function _encodeQueryParameter($value : Variant)->$encoded : Text
	// TODO: more stuff? quotes if needed, etc...
	
	var $url : Text:=String:C10($value)
	
	var $i; $j : Integer
	For ($i; 1; Length:C16($url))
		
		var $char:=Substring:C12($url; $i; 1)
		var $code:=Character code:C91($char)
		
		var $shouldEncode:=False:C215
		
		Case of 
			: ($code=32)
				
			: ($code=45)
				// -
			: ($code=46)
				// .
			: ($code>47) & ($code<58)
				// 0 1 2 3 4 5 6 7 8 9
			: ($code>64) & ($code<91)
				// A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
			: ($code=95)
				// _
			: ($code>96) & ($code<123)
				// a b c d e f g h i j k l m n o p q r s t u v w x y z
			: ($code=126)
				// ~
			Else 
				$shouldEncode:=True:C214
		End case 
		
		If ($shouldEncode)
			CONVERT FROM TEXT:C1011($char; "utf-8"; $data)
			For ($j; 0; BLOB size:C605($data)-1)
				var $hex:=String:C10($data{$j}; "&x")
				$encoded:=$encoded+"%"+Substring:C12($hex; Length:C16($hex)-1)
			End for 
		Else 
			If ($code=32)
				$encoded:=$encoded+"+"
			Else 
				$encoded:=$encoded+$char
			End if 
		End if 
		
	End for 
	
Function _encodeQueryParameters($queryParameters : Object) : Text
	If (($queryParameters=Null:C1517) || OB Is empty:C1297($queryParameters))
		return ""
	End if 
	
	return "?"+OB Entries:C1720($queryParameters).map(Formula:C1597($1.value.key+"="+$2._encodeQueryParameter($1.value.value)); This:C1470).join("&")
	
Function _mimeType($fileName : Text) : Text
	var $ext : Text:=Split string:C1554($fileName; ".").last()
	return cs:C1710._MimeTypes.me.getMimeType($ext)
	
Function _formData($body : Object; $files : Object; $boundary : Text) : 4D:C1709.Blob
	
	var $result : Blob
	var $temp : Blob
	var $textPart : Text
	
	var $key : Text
	For each ($key; $body)
		
		var $instance : Variant:=$body[$key]
		
		If (Value type:C1509($instance)=Is object:K8:27)
			// Handle nested objects with array notation
			// ex: -F expires_after[anchor]="created_at"
			// ex: -F expires_after[seconds]=2592000
			var $subkey : Text
			For each ($subkey; $instance)
				$textPart:="--"+$boundary+"\r\n"
				$textPart+="Content-Disposition: form-data; name=\""+$key+"["+$subkey+"]\"\r\n\r\n"
				$textPart+=String:C10($body[$key][$subkey])+"\r\n"
				TEXT TO BLOB:C554($textPart; $temp; UTF8 text without length:K22:17)
				COPY BLOB:C558($temp; $result; 0; BLOB size:C605($result); BLOB size:C605($temp))
			End for each 
		Else 
			// Simple scalar values
			// ex: -F purpose="fine-tune"
			$textPart:="--"+$boundary+"\r\n"
			$textPart+="Content-Disposition: form-data; name=\""+$key+"\"\r\n\r\n"
			$textPart+=String:C10($instance)+"\r\n"
			TEXT TO BLOB:C554($textPart; $temp; UTF8 text without length:K22:17)
			COPY BLOB:C558($temp; $result; 0; BLOB size:C605($result); BLOB size:C605($temp))
		End if 
		
	End for each 
	
	For each ($key; $files)
		var $fileBlob : Blob
		var $filename : Text
		var $mimeType : Text
		
		
		$instance:=$files[$key]
		
		// Check if it's a Picture variable
		Case of 
			: (Value type:C1509($instance)=Is picture:K8:10)
				
				$filename:=$key+".png"
				$mimeType:="image/png"
				$fileBlob:=cs:C1710._ImageUtils.me.toBlob($instance)
				
				// Check if it's already an image object, File object, or Blob object
			: ((Value type:C1509($instance)=Is object:K8:27) && (OB Instance of:C1731($instance; 4D:C1709.File)))
				
				$filename:=$instance.fullName  // Use fullName instead of name to include extension
				$mimeType:=This:C1470._mimeType($instance.fullName)
				$fileBlob:=$instance.getContent()
				
			: ((Value type:C1509($instance)=Is object:K8:27) && (OB Instance of:C1731($instance.file; 4D:C1709.File)))
				
				$filename:=$instance.filename || $instance.file.fullName
				$mimeType:=This:C1470._mimeType($filename)
				$fileBlob:=$instance.file.getContent()
				
			: ((Value type:C1509($instance)=Is object:K8:27) && (OB Instance of:C1731($instance; 4D:C1709.Blob)))
				
				$filename:=$key+".pdf"  // Default filename for blob
				$mimeType:="application/octet-stream"
				$fileBlob:=$files[$key]
				
			: ((Value type:C1509($instance)=Is object:K8:27) && (OB Instance of:C1731($instance.file; 4D:C1709.Blob)))
				
				$filename:=$instance.filename || ($key+".pdf")  // Default filename for blob
				$mimeType:=This:C1470._mimeType($filename)
				$fileBlob:=$instance.file
				
			Else 
				
				// It's an image object? convert to blob
				$filename:=$key+".png"
				$mimeType:="image/png"
				$fileBlob:=cs:C1710._ImageUtils.me.toBlob($files[$key])
				
		End case 
		
		
		If ($fileBlob#Null:C1517)
			// Add multipart headers as text
			$textPart:="--"+$boundary+"\r\n"
			$textPart+="Content-Disposition: form-data; name=\""+$key+"\"; filename=\""+$filename+"\"\r\n"
			$textPart+="Content-Type: "+$mimeType+"\r\n\r\n"
			TEXT TO BLOB:C554($textPart; $temp; UTF8 text without length:K22:17)
			COPY BLOB:C558($temp; $result; 0; BLOB size:C605($result); BLOB size:C605($temp))
			
			// Add binary file content
			COPY BLOB:C558($fileBlob; $result; 0; BLOB size:C605($result); BLOB size:C605($fileBlob))
			
			// Add trailing CRLF
			$textPart:="\r\n"
			TEXT TO BLOB:C554($textPart; $temp; UTF8 text without length:K22:17)
			COPY BLOB:C558($temp; $result; 0; BLOB size:C605($result); BLOB size:C605($temp))
		End if 
	End for each 
	
	// Add closing boundary
	$textPart:="--"+$boundary+"--"
	TEXT TO BLOB:C554($textPart; $temp; UTF8 text without length:K22:17)
	COPY BLOB:C558($temp; $result; 0; BLOB size:C605($result); BLOB size:C605($temp))
	
	return $result
	