property transcriptions : cs:C1710.OpenAIAudioTranscriptionsAPI
property translations : cs:C1710.OpenAIAudioTranslationsAPI
property _speech : cs:C1710.OpenAIAudioSpeechAPI

Class extends OpenAIAPIResource
	
Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)
	This:C1470.transcriptions:=cs:C1710.OpenAIAudioTranscriptionsAPI.new($client)
	This:C1470.translations:=cs:C1710.OpenAIAudioTranslationsAPI.new($client)
	This:C1470._speech:=cs:C1710._OpenAIAudioSpeechAPI.new($client)
