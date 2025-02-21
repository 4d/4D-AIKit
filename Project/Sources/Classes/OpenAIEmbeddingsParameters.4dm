// The format to return the embeddings in. Can be either float or base64. (default: float)
property encoding_format : Text

// The number of dimensions the resulting output embeddings should have.Only supported in text-embedding-3 and later models.
property dimensions : Integer

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)
	
Function body() : Object
	var $body:=Super:C1706.body()
	
	If (Length:C16(String:C10(This:C1470.encoding_format))>0)
		$body.encoding_format:=This:C1470.encoding_format
	End if 
	If (This:C1470.dimensions>0)
		$body.dimensions:=This:C1470.dimensions
	End if 
	
	return $body