// Result class for listing voices, whatever the server
Class extends OpenAIResult

// The voices, when they do not come from a request
property _voices : Collection

// True if success. There is no request when the server has no endpoint to list voices.
Function get success : Boolean
	If (This._voices#Null)
		return True
	End if 
	If ((This.request=Null) || (This.request.response=Null))
		return False
	End if 
	return (300>This.request.response.status) && (This.request.response.status>=200)
	
/*
* Returns the voices, with the id and the name filled whatever the format of the server
* @return {Collection} Collection of cs.OpenAIAudioVoice objects, or empty collection if none found
*/
Function get voices : Collection
	If (This._voices#Null)
		return This._voices
	End if 
	
	If ((Not(This.success)) || (This.request.response.body=Null))
		return []
	End if 
	
	var $items : Collection:=Null
	var $key : Text
	
	If (Value type(This.request.response.body)=Is collection)
		$items:=This.request.response.body  // ie. Azure Speech
	Else 
		var $body:=This._objectBody()
		If ($body#Null)
			For each ($key; ["voices"; "data"; "items"; "voices_page"; "tts"])
				If (Value type($body[$key])=Is collection)
					$items:=$body[$key]
					break
				End if 
			End for each 
		End if 
	End if 
	
	var $voices:=[]
	If ($items=Null)
		return $voices
	End if 
	
	var $item; $subItem : Variant
	var $voice : cs.OpenAIAudioVoice
	For each ($item; $items)
		If ((Value type($item)=Is object) && (Value type($item.voices)=Is collection))
			// voices grouped by model, ie. LocalAI or Together AI
			For each ($subItem; $item.voices)
				$voice:=cs.OpenAIAudioVoice.new($subItem)
				If ((Length(String($voice.model))=0) && (Value type($item.model)=Is text))
					$voice.model:=$item.model
				End if 
				This._push($voices; $voice)
			End for each 
		Else 
			This._push($voices; cs.OpenAIAudioVoice.new($item))
		End if 
	End for each 
	
	return $voices
	
Function _push($voices : Collection; $voice : cs.OpenAIAudioVoice)
	If (Length(String($voice.id))>0)
		$voices.push($voice)
	End if 
