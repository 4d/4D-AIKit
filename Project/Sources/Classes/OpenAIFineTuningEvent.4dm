// The event identifier
property id : Text

// The object type, which is always "fine_tuning.job.event"
property object : Text

// The Unix timestamp (in seconds) for when the event was created
property created_at : Integer

// The severity level of the event (info, warn, error)
property level : Text

// The event message
property message : Text

// Additional data associated with the event
property data : Object

// The type of event
property type : Text

Class constructor($object : Object)
	If ($object=Null:C1517)
		return
	End if
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each
