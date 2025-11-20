// The embedding values as a vector
property values : 4D:C1709.Vector

Class constructor($object : Object)
	If ($object=Null:C1517)
		return
	End if

	// Gemini returns embedding as { values: [number, number, ...] }
	If (Value type:C1509($object.values)=Is collection:K8:32)
		This:C1470.values:=4D:C1709.Vector.new($object.values)
	Else
		This:C1470.values:=Null:C1517
	End if

