property result : cs:C1710.OpenAIResult
property signal : 4D:C1709.Signal

property chunks : Collection

shared singleton Class constructor
	
Function init()
	Use (This:C1470)
		This:C1470.signal:=New signal:C1641(Current method name:C684())
		This:C1470.chunks:=New shared collection:C1527()
	End use 
	
Function reset()
	OB REMOVE:C1226(Storage:C1525; "signal")
	
Function wait($time : Integer)
	This:C1470.signal.wait($time)
	
Function trigger($result : cs:C1710.OpenAIResult)
	$result._requestSharable()
	Use (This:C1470)
		This:C1470.result:=OB Copy:C1225($result; ck shared:K85:29; This:C1470)
	End use 
	This:C1470.signal.trigger()
	
Function pushChunk($result : cs:C1710.OpenAIResult)
	$result._requestSharable()
	Use (This:C1470)
		This:C1470.chunks.push(OB Copy:C1225($result; ck shared:K85:29; This:C1470))
	End use 