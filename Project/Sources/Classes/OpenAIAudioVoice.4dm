// A text-to-speech voice: a built-in one, a custom one, or one listed by a compatible server

// The voice identifier, to use as voice of speech()
property id : Text

// The name of the voice
property name : Text

// The object type, "audio.voice" for an OpenAI custom voice
property object : Text

// The Unix timestamp (in seconds) for when the voice was created
property created_at : Integer

// How the voice was created: "audio_sample" or "prompt" for OpenAI. Other servers have their own values.
property type : Text

// The prompt used to create the voice, if any
property prompt : Text

// The model of the voice, when the server groups its voices by model
property model : Text

// True if it is a custom voice of the client, see OpenAIAudioVoicesAPI.custom
property custom : Boolean

Class constructor($voice : Variant)
	Case of 
		: (Value type($voice)=Is text)
			// a server could list its voices as plain names
			This.id:=$voice
			This.name:=$voice
			return 
		: (Value type($voice)#Is object)
			return 
	End case 
	
	var $key : Text
	For each ($key; $voice)
		If ($key#"reference")  // computed
			This[$key]:=$voice[$key]
		End if 
	End for each 
	
	// servers do not agree on the name of the identifier
	If (Length(String(This.id))=0)
		For each ($key; ["voice_id"; "voiceId"; "ShortName"; "_id"; "canonical_name"; "name"; "Name"])
			If ((Value type($voice[$key])=Is text) && (Length($voice[$key])>0))
				This.id:=$voice[$key]
				break
			End if 
		End for each 
	End if 
	
	If (Length(String(This.name))=0)
		This.name:=String(This.id)
		For each ($key; ["display_name"; "displayName"; "DisplayName"; "title"])
			If ((Value type($voice[$key])=Is text) && (Length($voice[$key])>0))
				This.name:=$voice[$key]
				break
			End if 
		End for each 
	End if 
	
/*
* The value to pass as voice of speech(): an object with the id for an OpenAI custom voice, otherwise the id.
* @return {Variant} Text or Object
*/
Function get reference : Variant
	If (Position("voice_"; String(This.id); *)=1)
		return {id: This.id}
	End if 
	return String(This.id)
