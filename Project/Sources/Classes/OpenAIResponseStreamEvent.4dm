property event : Text
property data : Object

Class constructor($event : Object)
	If ($event=Null:C1517)
		return 
	End if 
	
	This:C1470.event:=$event.event
	This:C1470.data:=$event.data
