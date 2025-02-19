Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	
Function list($completionID : Text; $parameters : cs:C1710.OpenAIChatCompletionsMessagesParameters) : cs:C1710.OpenAIResult
	If (Length:C16($completionID)=0)
		throw:C1805(1; "Expected a non-empty value for `completionID`")
	End if 
	
	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIChatCompletionsMessagesParameters)))
		$parameters:=cs:C1710.OpenAIChatCompletionsMessagesParameters.new($parameters)
	End if 
	
	var $query:=$parameters.body()
	return This:C1470._client._getApiList("/chat/completions/"+$completionID+"/messages"; $query; $parameters)
	