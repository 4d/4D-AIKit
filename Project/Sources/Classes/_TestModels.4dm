
property embeddings : Text:="text-embedding-ada-002"
property chats : Text:="gpt-4o-mini"
property images : Text:="dall-e-2"
property moderation : Text:="omni-moderation-latest"

Class constructor($client : cs:C1710.OpenAI)
	
	Case of 
		: ((Position:C15("ollama"; $client.baseURL)>0) || (Position:C15(":11434"; $client.baseURL)>0))
			
			This:C1470.embeddings:="nomic-embed-text"
			This:C1470.chats:="llama3"
			
		: (Position:C15("mistral"; $client.baseURL)>0)
			
			This:C1470.embeddings:="mistral-embed"
			This:C1470.chats:="ministral-3b-2410"
			
		: (Position:C15("api.anthropic.com"; $client.baseURL)>0)
			
			This:C1470.embeddings:=""
			This:C1470.chats:="claude-haiku-4-5"
			
		: (Position:C15("googleapis"; $client.baseURL)>0)
			
			This:C1470.embeddings:="gemini-embedding-001"
			This:C1470.chats:="gemini-3-flash-preview"
			
	End case 
	
	// XXX: could check $client.models.list()