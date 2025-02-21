// The index of the embedding in the list of embeddings.
property index : Integer

// The embedding vector, which is a collection of numbers. The length of vector depends on the model as listed in the embedding guide.
property embedding : Collection

// Text value "embedding"
property object : Text

Class constructor($object : Object)
	If ($object=Null:C1517)
		return 
	End if 
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each 
	