
property embeddings : Text:="text-embedding-ada-002"
property chats : Text:="gpt-4o-mini"
property images : Text:="dall-e-2"
property moderation : Text:="omni-moderation-latest"

Class constructor($client : cs:C1710.OpenAI)
	
	Case of 
		: (Position:C15("ollama"; $client.baseURL)>0)
			
			This:C1470.embeddings:="nomic-embed-text"
			This:C1470.chats:="llama3"
			
	End case 
	
	// XXX: could check $client.models.list()