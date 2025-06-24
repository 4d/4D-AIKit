// The index of the embedding in the list of embeddings.
property index : Integer

// The embedding vector, which is a collection of numbers. The length of vector depends on the model as listed in the embedding guide.
property embedding : 4D:C1709.Vector

// Text value "embedding"
property object : Text

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		If ($key="embedding")
			If (Value type:C1509($object[$key])=Is text:K8:3)
				This:C1470.embedding:=4D:C1709.Vector.new(This:C1470._base64Decode($object[$key]))
			Else 
				This:C1470.embedding:=4D:C1709.Vector.new($object[$key])
			End if 
		Else 
			This:C1470[$key]:=$object[$key]
		End if 
	End for each 
	
Function _base64Decode($base64String : Text) : Collection
	// Initialize result collection
	var $floatArray:=[]
	
	If (Length:C16($base64String)>0)
		
		// Decode the base64 string to blob
		var $decodedBlob; $floatBlob : Blob
		BASE64 DECODE:C896($base64String; $decodedBlob)
		
		var $bytesLength:=BLOB size:C605($decodedBlob)
		
		// Process every 4 bytes as a 32-bit float
		var $offset : Integer
		For ($offset; 0; $bytesLength-4; 4)
			
			$floatArray.push(This:C1470._float($decodedBlob; $offset))
			
		End for 
		
	End if 
	
	return $floatArray
	
Function _float($bytes : Blob; $offset : Integer) : Real
	
	// Combine bytes to 32-bit integer (little-endian)
	var $combined : Integer
	$combined:=($bytes{3+$offset} << 24) | ($bytes{2+$offset} << 16) | ($bytes{1+$offset} << 8) | $bytes{0+$offset}
	
	// Method 3: Using bit operations directly
	var $sign; $exponent; $mantissa : Integer
	var $result : Real
	
	// Extract sign bit (bit 31)
	$sign:=($combined >> 31) & 1
	
	// Extract exponent (bits 30-23)
	$exponent:=($combined >> 23) & 0x00FF
	
	// Extract mantissa (bits 22-0)  
	$mantissa:=$combined & 0x007FFFFF
	
	// Calculate IEEE 754 float
	If ($exponent=0)
		// Denormalized number
		$result:=($mantissa/8388608)*(2^-126)  // 2^23 = 8388608
	Else 
		If ($exponent=255)
			// Infinity or NaN
			If ($mantissa=0)
				$result:=($sign=0) ? 999999999 : -999999999  // Represent as very large number
			Else 
				$result:=0  // NaN represented as 0
			End if 
		Else 
			// Normalized number
			var $actualExp : Integer
			$actualExp:=$exponent-127
			$result:=(1+($mantissa/8388608))*(2^$actualExp)
		End if 
	End if 
	
	// Apply sign
	If ($sign=1)
		$result:=-$result
	End if 
	
	return $result