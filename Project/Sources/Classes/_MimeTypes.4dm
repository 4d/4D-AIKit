// Singleton class for MIME type mappings
// Usage: cs._MimeTypes.me.getMimeType("txt") or cs._MimeTypes.me.types["txt"]

property types : Object

singleton Class constructor()
	
	// Initialize MIME type mappings (extensions without dots)
	This:C1470.types:={\
		c: "text/x-c"; \
		cs: "text/x-csharp"; \
		cpp: "text/x-c++"; \
		csv: "text/csv"; \
		doc: "application/msword"; \
		docx: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"; \
		html: "text/html"; \
		java: "text/x-java"; \
		json: "application/json"; \
		jsonl: "application/json"; \
		md: "text/markdown"; \
		pdf: "application/pdf"; \
		php: "text/x-php"; \
		pptx: "application/vnd.openxmlformats-officedocument.presentationml.presentation"; \
		py: "text/x-python"; \
		rb: "text/x-ruby"; \
		tex: "text/x-tex"; \
		txt: "text/plain"; \
		css: "text/css"; \
		js: "text/javascript"; \
		sh: "application/x-sh"; \
		ts: "application/typescript"; \
		jpeg: "image/jpeg"; \
		jpg: "image/jpeg"; \
		gif: "image/gif"; \
		pkl: "application/octet-stream"; \
		png: "image/png"; \
		tar: "application/x-tar"; \
		xlsx: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"; \
		xml: "application/xml"; \
		zip: "application/zip"}
	
	
	// Get MIME type for a given extension (without dot)
Function getMimeType($extension : Text) : Text
	var $ext : Text:=Lowercase:C14($extension)
	
	// Remove leading dot if present
	If (Position:C15("."; $ext)=1)
		$ext:=Substring:C12($ext; 2)
	End if 
	
	// Return MIME type or default to octet-stream
	var $mimeType : Text:=This:C1470.types[$ext]
	If (Length:C16($mimeType)=0)
		$mimeType:="application/octet-stream"
	End if 
	return $mimeType
	
	// Add or update a MIME type mapping
Function setMimeType($extension : Text; $mimeType : Text)
	var $ext : Text:=Lowercase:C14($extension)
	
	// Remove leading dot if present
	If (Position:C15("."; $ext)=1)
		$ext:=Substring:C12($ext; 2)
	End if 
	
	This:C1470.types[$ext]:=$mimeType
	
	// Check if extension has a registered MIME type
Function hasMimeType($extension : Text) : Boolean
	var $ext : Text:=Lowercase:C14($extension)
	
	// Remove leading dot if present
	If (Position:C15("."; $ext)=1)
		$ext:=Substring:C12($ext; 2)
	End if 
	
	return This:C1470.types[$ext]#Null:C1517
	