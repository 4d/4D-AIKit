property query : Text:=""
property documents : Collection:=[]

Class constructor($query : Object)
	
	If ($query=Null:C1517)
		return 
	End if 
	
	If (Value type:C1509($query.query)=Is text:K8:3)
		This:C1470.query:=$query.query
	End if 
	
	If (Value type:C1509($query.documents)=Is collection:K8:32)
		This:C1470.documents:=$query.documents
	End if 