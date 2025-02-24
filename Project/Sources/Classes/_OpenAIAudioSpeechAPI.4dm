Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
    Super:C1705($client)
    
 // Function to process speech
Function _create($audioData : Variant; $parameters : cs:C1710.OpenAIAudioParameters) : cs:C1710.OpenAIAudioResult
    return This:C1470._client._postFiles("/audio/speech"; Null:C1517; {file: $audioData}; $parameters; cs:C1710.OpenAIAudioResult)