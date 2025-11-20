//%attributes = {"invisible":true}
#DECLARE() : cs:C1710.Gemini
var $client:=cs:C1710.Gemini.new()

If ((Length:C16($client.apiKey)=0) && (Folder:C1567(fk home folder:K87:24).file(".gemini").exists))
	$client.apiKey:=Folder:C1567(fk home folder:K87:24).file(".gemini").getText()
End if

// You can also set the API key in environment variable GEMINI_API_KEY

return $client
