// Parameters for listing voice consents

// A cursor for use in pagination. after is an object ID that defines your place in the list
property after : Text

// A limit on the number of objects to be returned (1-100, default 20)
property limit : Integer

Class extends OpenAIParameters

Class constructor($object : Object)
	Super($object)
	
Function body() : Object
	var $body:={}
	
	If (Length(String(This.after))>0)
		$body.after:=This.after
	End if 
	If (This.limit>0)
		$body.limit:=This.limit
	End if 
	
	return $body
