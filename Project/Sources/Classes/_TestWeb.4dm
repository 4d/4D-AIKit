property parts : Collection

shared singleton Class constructor
	This:C1470.reset()
	
Function reset()
	Use (This:C1470)
		This:C1470.parts:=New shared collection:C1527()
	End use 
	
Function test()
	This:C1470.reset()
	
	var $vPartName; $vPartMimeType; $vPartFileName : Text
	var $vPartContentBlob : Blob
	var $i : Integer
	For ($i; 1; WEB Get body part count:C1211)  //for each part
		WEB GET BODY PART:C1212($i; $vPartContentBlob; $vPartName; $vPartMimeType; $vPartFileName)
		Use (This:C1470)
			var $obj:={index: $i; content: $vPartContentBlob; name: $vPartName; mimeType: $vPartMimeType; fileName: $vPartFileName}
			This:C1470.parts.push(OB Copy:C1225($obj; ck shared:K85:29; This:C1470))
		End use 
	End for 
	
	