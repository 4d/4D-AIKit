property _boundary : Text
property _parts : Collection

property LINE_BREAK:=Char:C90(13)+Char:C90(10)  // \r\n

property boundary : Text

Class constructor
	This:C1470._parts:=[]
	This:C1470._generateBoundary()
	
Function _generateBoundary()
	// 50 character boundaryoptimized for boyer-moore parsing.
	var $boundary:="------------------------"
	var $i : Integer
	For ($i; 0; 24; 1)
		$boundary+=String:C10(Random:C100)[[1]]
	End for 
	
	This:C1470.boundary:=$boundary
	
	// MARK:- add
Function addField($name : Text; $value : Text)
	This:C1470._parts.push({name: $name; value: $value; type: "field"})
	
Function addFile($name : Text; $file : 4D:C1709.File; $mineType : Text)
	If (Length:C16($mineType)=0)
		$mineType:=This:C1470._getMimeType($file.extension)
	End if 
	This:C1470._parts.push({name: $name; file: $file; type: "file"; mimeType: $mineType})
	
Function _getMimeType($extension : Text) : Text
	$extension:=Delete string:C232($extension; 1; 1)
	
	Case of 
		: (($extension="HTML") || ($extension="HTM"))
			return "text/html"
		: (($extension="JPG") || ($extension="JPEG"))
			return "image/jpeg"
		: ($extension="PNG")
			return "image/png"
		: ($extension="GIF")
			return "image/gif"
		: ($extension="CSS")
			return "text/css"
		: ($extension="JS")
			return "application/javascript"
		: ($extension="JSON")
			return "application/json"
		: ($extension="PDF")
			return "application/pdf"
		: ($extension="TXT")
			return "text/plain"
		: ($extension="MP4")
			return "video/mp4"
		: ($extension="MP3")
			return "audio/mpeg"
		: ($extension="ZIP")
			return "application/zip"
			// Add more mappings here as needed
		Else 
			return "application/octet-stream"  // Default MIME type for unknown extensions
	End case 
	
	// MARK:- ouput
	
Function getBody() : Blob
	var $body : Blob
	// SET BLOB SIZE($body; 0)
	
	var $part : Object
	For each ($part; This:C1470._parts)
		var $partHeader : Text:=""
		Case of 
			: ($part.type="field")
				
				$partHeader:="--"+This:C1470.boundary+This:C1470.LINE_BREAK
				
				$partHeader:=$partHeader+"Content-Disposition: form-data; name=\""+$part.name+"\""+This:C1470.LINE_BREAK
				If ((Value type:C1509($part.value)=Is object:K8:27) && (Value type:C1509($part.value)=Is collection:K8:32))
					$partHeader:=$partHeader+"Content-Type:application/json"+This:C1470.LINE_BREAK
				End if 
				This:C1470._APPEND_TEXT_TO_BLOB(->$body; $partHeader)
				If ((Value type:C1509($part.value)=Is object:K8:27) && (Value type:C1509($part.value)=Is collection:K8:32))
					This:C1470._APPEND_TEXT_TO_BLOB(->$body; JSON Stringify:C1217($part.value))
				Else 
					This:C1470._APPEND_TEXT_TO_BLOB(->$body; String:C10($part.value))
				End if 
				This:C1470._APPEND_TEXT_TO_BLOB(->$body; This:C1470.LINE_BREAK)
				
			: ($part.type="file")
				
				$partHeader:="--"+This:C1470.boundary+This:C1470.LINE_BREAK
				
				$partHeader:=$partHeader+"Content-Disposition: form-data; name=\""+$part.name+"\"; filename=\""+$part.file.fullName+"\""+This:C1470.LINE_BREAK
				$partHeader:=$partHeader+"Content-Type: "+String:C10($part.mimeType)+This:C1470.LINE_BREAK
				This:C1470._APPEND_TEXT_TO_BLOB(->$body; $partHeader)
				This:C1470._APPEND_FILE_TO_BLOB(->$body; $part.file)
				//This._APPEND_TEXT_TO_BLOB(->$body; String($part.file.path))
				This:C1470._APPEND_TEXT_TO_BLOB(->$body; This:C1470.LINE_BREAK)
				This:C1470._APPEND_TEXT_TO_BLOB(->$body; This:C1470.LINE_BREAK)
				
		End case 
	End for each 
	
	var $closingBoundary:="--"+This:C1470.boundary+"--"+This:C1470.LINE_BREAK
	This:C1470._APPEND_TEXT_TO_BLOB(->$body; $closingBoundary)
	
	var $teeest:=BLOB to text:C555($body; UTF8 text with length:K22:16)
	
	return $body
	
	
Function configure($options : Object) : Object
	If ($options=Null:C1517)
		$options:={}
	End if 
	If ($options.method=Null:C1517)
		$options.method:="POST"
	End if 
	If ($options.headers=Null:C1517)
		$options.headers:={}
	End if 
	$options.headers["Content-Type"]:="multipart/form-data; boundary="+This:C1470.boundary
	
	$options.body:=This:C1470.getBody()
	
	return $options
	
	// MARK:- blob utils
	
Function _APPEND_BLOB_TO_BLOB($blob : Pointer; $blobSrc : Pointer)
	COPY BLOB:C558($blobSrc->; $blob->; 0; BLOB size:C605($blob->); BLOB size:C605($blobSrc->))
	
Function _APPEND_TEXT_TO_BLOB($blob : Pointer; $text : Text)
	var $blobTmp : Blob
	TEXT TO BLOB:C554($text; $blobTmp)
	This:C1470._APPEND_BLOB_TO_BLOB($blob; ->$blobTmp)
	
Function _APPEND_FILE_TO_BLOB($blob : Pointer; $file : 4D:C1709.File)
	var $blobTmp : Blob:=$file.getContent()
	This:C1470._APPEND_BLOB_TO_BLOB($blob; ->$blobTmp)
	