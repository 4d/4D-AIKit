//%attributes = {}

// MARK:- SSE framing of the streamed chat completions, see _OpenAIAsyncOptions.onData
// No network and no api key needed: raw chunks are fed to the http callback.

var $options : cs:C1710._OpenAIAsyncOptions
var $collector : Object
var $blob : Blob

// MARK:- Test 1: the "data: " prefix is cut between two reads (github.com/4d/4D-AIKit/pull/30)
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {\"a\":1}\ndat"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "First complete packet must be notified, got: "+String:C10($collector.received.length))
ASSERT:C1129($options._chunkBuffer="dat"; "Incomplete tail must be kept whatever it contains, got: '"+$options._chunkBuffer+"'")

TEXT TO BLOB:C554("a: {\"a\":2}\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=2; "Packet split on its prefix must be rebuilt, got: "+String:C10($collector.received.length))
ASSERT:C1129(Not:C34($options._onStreamError); "A split prefix must not stop the stream")
ASSERT:C1129($collector.received[1].data.a=2; "Rebuilt packet must be decoded, got: "+JSON Stringify:C1217($collector.received[1].data || Null:C1517))

// MARK:- Test 2: the json payload is cut between two reads
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {\"a\":"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=0; "Incomplete json must not be notified, got: "+String:C10($collector.received.length))

TEXT TO BLOB:C554("1}\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "Packet split on its json must be rebuilt, got: "+String:C10($collector.received.length))
ASSERT:C1129($collector.received[0].data.a=1; "Rebuilt packet must be decoded, got: "+JSON Stringify:C1217($collector.received[0].data || Null:C1517))

// MARK:- Test 3: CRLF line endings, allowed by the SSE specification
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {\"a\":1}\r\ndata: [DONE]\r\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "CRLF packet must be notified, got: "+String:C10($collector.received.length))
ASSERT:C1129($collector.received[0].data.a=1; "CRLF packet must be decoded, got: "+JSON Stringify:C1217($collector.received[0].data || Null:C1517))
ASSERT:C1129($options._chunkBuffer=""; "[DONE] must empty the buffer, got: '"+$options._chunkBuffer+"'")
ASSERT:C1129($options._streamErrors.length=0; "[DONE] must not be reported as an error")

// MARK:- Test 4: comment line, used as keep alive by some providers
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554(": OPENROUTER PROCESSING\ndata: {\"a\":1}\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "Comment line must be ignored, got: "+String:C10($collector.received.length))
ASSERT:C1129(Not:C34($options._onStreamError); "A comment line must not stop the stream")
ASSERT:C1129($options._streamErrors.length=0; "A comment line must not be reported as an error")

// MARK:- Test 5: other SSE fields
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("event: message\nid: 42\nretry: 1000\ndata: {\"a\":1}\n\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "Only the data field must be notified, got: "+String:C10($collector.received.length))
ASSERT:C1129($options._streamErrors.length=0; "Other fields must not be reported as an error")

// MARK:- Test 6: a complete but undecodable data packet is skipped and reported
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {oops\ndata: {\"a\":1}\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "Only the decodable packet must be notified, got: "+String:C10($collector.received.length))
ASSERT:C1129(Not:C34($options._onStreamError); "One bad packet must not stop the stream")
ASSERT:C1129($options._streamErrors.length>0; "A bad packet must not be silently dropped")

// MARK:- Test 7: last packet without its terminating line feed, flushed by onTerminate
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {\"a\":1}"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=0; "Unterminated packet must wait, got: "+String:C10($collector.received.length))
ASSERT:C1129($options._chunkBuffer="data: {\"a\":1}"; "Unterminated packet must be kept, got: '"+$options._chunkBuffer+"'")

$options._handleSSELine(Null:C1517; $options._chunkBuffer)  // what onTerminate does with a non empty buffer
ASSERT:C1129($collector.received.length=1; "Unterminated last packet must be notified on terminate, got: "+String:C10($collector.received.length))

// MARK:- Test 8: a json body instead of an event stream is still an error
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("{\"error\":{\"message\":\"invalid api key\"}}"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($options._onStreamError; "A json error body must stop the stream, it is handled by onTerminate")
ASSERT:C1129($collector.received.length=0; "A json error body must not be notified as a chunk, got: "+String:C10($collector.received.length))

// MARK:- Test 9: bare CR as line terminator, allowed by the specification
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {\"a\":1}\rdata: {\"a\":2}\r\r"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=2; "Bare CR must terminate a line, got: "+String:C10($collector.received.length))
ASSERT:C1129($options._streamErrors.length=0; "Bare CR must not produce an error")

// MARK:- Test 10: a CRLF pair cut between two reads must stay one single terminator
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {\"a\":1}\r"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "CR alone already terminates the line, got: "+String:C10($collector.received.length))
TEXT TO BLOB:C554("\ndata: {\"a\":2}\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=2; "The LF of a split CRLF must not duplicate anything, got: "+String:C10($collector.received.length))
ASSERT:C1129($options._streamErrors.length=0; "A split CRLF must not produce an error")

// MARK:- Test 11: read cut inside the field name itself
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("da"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
TEXT TO BLOB:C554("ta: {\"a\":1}\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "Field name cut in two must be rebuilt, got: "+String:C10($collector.received.length))

// MARK:- Test 12: no space after the colon, the space is optional
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data:{\"a\":1}\ndata:[DONE]\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "data: without space must be decoded, got: "+String:C10($collector.received.length))
ASSERT:C1129($options._streamErrors.length=0; "[DONE] without space must be recognized")

// MARK:- Test 13: only one space is removed after the colon
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {\"a\":\"x:y\"}\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "A value containing a colon must be decoded, got: "+String:C10($collector.received.length))
ASSERT:C1129($collector.received[0].data.a="x:y"; "Only the first colon separates the field, got: '"+String:C10($collector.received[0].data.a)+"'")

// MARK:- Test 14: a line that is not a field at all
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("Well this is not\ndata: {\"a\":1}\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "A garbage line must be ignored, got: "+String:C10($collector.received.length))
ASSERT:C1129(Not:C34($options._onStreamError); "A garbage line must not stop the stream")

// MARK:- Test 15: a byte order mark at the beginning of the stream
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

var $payload : Blob
TEXT TO BLOB:C554("data: {\"a\":1}\n"; $payload; UTF8 text without length:K22:17)
SET BLOB SIZE:C606($blob; 3+BLOB size:C605($payload))
$blob{0}:=0xEF
$blob{1}:=0xBB
$blob{2}:=0xBF
COPY BLOB:C558($payload; $blob; 0; 3; BLOB size:C605($payload))
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "A leading BOM must not hide the first packet, got: "+String:C10($collector.received.length))

// MARK:- Test 16: an empty read between two packets
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {\"a\":1}\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
SET BLOB SIZE:C606($blob; 0)
$options.onData(Null:C1517; {data: $blob})  // must not fail
TEXT TO BLOB:C554("data: {\"a\":2}\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=2; "An empty read must be a no-op, got: "+String:C10($collector.received.length))

// MARK:- Test 17: blank lines used as keep alive
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("\n\n\ndata: {\"a\":1}\n\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "Blank lines must be ignored, got: "+String:C10($collector.received.length))
ASSERT:C1129($options._streamErrors.length=0; "Blank lines must not produce an error")

// MARK:- Test 18: an escaped new line inside the json must not split the packet
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {\"a\":\"my long\\n\\ncontent\"}\n\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "An escaped new line must stay in the packet, got: "+String:C10($collector.received.length))
ASSERT:C1129(Position:C15(Char:C90(Line feed:K15:40)+Char:C90(Line feed:K15:40); String:C10($collector.received[0].data.a))>0; "The escaped new lines must be decoded, got: '"+String:C10($collector.received[0].data.a)+"'")

// MARK:- Test 19: U+2028 is not a line separator for SSE
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {\"a\":\""+Char:C90(0x2028)+"\"}\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "U+2028 must not break the line, got: "+String:C10($collector.received.length))
//%W-533.1
ASSERT:C1129(Character code:C91(String:C10($collector.received[0].data.a)[[1]])=0x2028; "U+2028 must be kept as is")
//%W+533.1

// MARK:- Test 20: multi byte characters inside one single read
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {\"a\":\"известни\"}\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "Multi byte packet must be decoded, got: "+String:C10($collector.received.length))
ASSERT:C1129(String:C10($collector.received[0].data.a)="известни"; "Multi byte content must be kept, got: '"+String:C10($collector.received[0].data.a)+"'")

// MARK:- Test 21: a 2 bytes character cut between two reads
// "é" is 0xC3 0xA9: decoding each read on its own silently gives "©", see _decodeChunk
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

var $bytes : Blob
TEXT TO BLOB:C554("data: {\"a\":\"éx\"}\n"; $bytes; UTF8 text without length:K22:17)
var $cut : Integer:=13  // right in the middle of the 2 bytes of "é"
SET BLOB SIZE:C606($blob; $cut)
COPY BLOB:C558($bytes; $blob; 0; 0; $cut)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=0; "Nothing to notify yet, got: "+String:C10($collector.received.length))

SET BLOB SIZE:C606($blob; BLOB size:C605($bytes)-$cut)
COPY BLOB:C558($bytes; $blob; $cut; 0; BLOB size:C605($bytes)-$cut)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "Packet must be notified once complete, got: "+String:C10($collector.received.length))
ASSERT:C1129(String:C10($collector.received[0].data.a)="éx"; "A character cut by the read must not be corrupted, got: '"+String:C10($collector.received[0].data.a)+"'")
//%W-533.1
ASSERT:C1129(Character code:C91(String:C10($collector.received[0].data.a)[[1]])=0x00E9; "Expected é (0xE9), got code: "+String:C10(Character code:C91(String:C10($collector.received[0].data.a)[[1]])))
//%W+533.1

// MARK:- Test 22: a 4 bytes character (emoji) cut between two reads
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {\"a\":\"🥌\"}\n"; $bytes; UTF8 text without length:K22:17)
$cut:=14  // "🥌" is 4 bytes starting at offset 12
SET BLOB SIZE:C606($blob; $cut)
COPY BLOB:C558($bytes; $blob; 0; 0; $cut)
$options.onData(Null:C1517; {data: $blob})
SET BLOB SIZE:C606($blob; BLOB size:C605($bytes)-$cut)
COPY BLOB:C558($bytes; $blob; $cut; 0; BLOB size:C605($bytes)-$cut)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "Packet with a cut emoji must be notified, got: "+String:C10($collector.received.length))
ASSERT:C1129(String:C10($collector.received[0].data.a)="🥌"; "A 4 bytes character cut by the read must not be corrupted, got: '"+String:C10($collector.received[0].data.a)+"'")

// MARK:- Test 23: a stream cut byte per byte must give the same result
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {\"a\":\"héllo 🥌\"}\ndata: {\"a\":\"wörld\"}\ndata: [DONE]\n"; $bytes; UTF8 text without length:K22:17)
var $byteIndex : Integer
For ($byteIndex; 0; BLOB size:C605($bytes)-1)
	SET BLOB SIZE:C606($blob; 1)
	$blob{0}:=$bytes{$byteIndex}
	$options.onData(Null:C1517; {data: $blob})
End for 
ASSERT:C1129($collector.received.length=2; "Byte per byte stream must give the same packets, got: "+String:C10($collector.received.length))
ASSERT:C1129(String:C10($collector.received[0].data.a)="héllo 🥌"; "Byte per byte content must be intact, got: '"+String:C10($collector.received[0].data.a)+"'")
ASSERT:C1129(String:C10($collector.received[1].data.a)="wörld"; "Byte per byte content must be intact, got: '"+String:C10($collector.received[1].data.a)+"'")
ASSERT:C1129($options._streamErrors.length=0; "Byte per byte stream must not produce any error")

// MARK:- Test 24: multi line data field
// Known deviation: the specification concatenates consecutive data fields into one event,
// we decode each data line on its own. No openai compatible provider splits a chunk this way.
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: {\"a\":\ndata: 1}\n\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=0; "A split data field is not concatenated, got: "+String:C10($collector.received.length))
ASSERT:C1129($options._streamErrors.length>=2; "But both halves must be reported, not silently lost, got: "+String:C10($options._streamErrors.length))  // 4D pushes several errors per malformed json
ASSERT:C1129(Not:C34($options._onStreamError); "And the stream must stay alive")

// MARK:- Test 25: data field whose value is an SSE comment (Qwen/MLX keepalive)
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554(": keepalive\ndata: : keepalive\ndata: {\"a\":1}\ndata: : keepalive\ndata: [DONE]\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "data: : keepalive must be ignored, got: "+String:C10($collector.received.length))
ASSERT:C1129($collector.received[0].data.a=1; "Chunk after keepalive must be decoded, got: "+JSON Stringify:C1217($collector.received[0].data || Null:C1517))
ASSERT:C1129(Not:C34($options._onStreamError); "Keepalive data field must not stop the stream")
ASSERT:C1129($options._streamErrors.length=0; "Keepalive data field must not be reported as an error")

// MARK:- Test 26: terminated body whose last data segment is a keepalive
var $terminated : cs:C1710.OpenAIChatCompletionsStreamResult
$terminated:=cs:C1710.OpenAIChatCompletionsStreamResult.new(Null:C1517; \
	"data: {\"choices\":[{\"delta\":{\"content\":\"Hi\"}}]}\n\ndata: : keepalive\n\ndata: [DONE]\n"; True:C214)
ASSERT:C1129($terminated.data#Null:C1517; "Terminate must skip trailing keepalive and keep the last JSON chunk")
ASSERT:C1129($terminated.choice#Null:C1517; "Terminate must expose the last choice after keepalive")
ASSERT:C1129($terminated._decodingErrors=Null:C1517; "Keepalive must not produce a JSON decode error")

// MARK:- Test 27: terminated body without the optional space, "data:{...}"
// The streaming path already accepts it, see test 12, terminate must too.
$terminated:=cs:C1710.OpenAIChatCompletionsStreamResult.new(Null:C1517; \
"data:{\"choices\":[{\"delta\":{\"content\":\"Hi\"}}]}\ndata:[DONE]\n"; True:C214)
ASSERT:C1129($terminated.data#Null:C1517; "Terminate must decode a data field without space")
ASSERT:C1129($terminated.choice#Null:C1517; "Terminate must expose the choice of a data field without space")
ASSERT:C1129($terminated._decodingErrors=Null:C1517; "data: without space must not produce a decode error")

// MARK:- Test 28: the content of the last chunk contains the literal "data: "
// Framing on the "data: " text instead of on the lines cuts the json in the middle.
$terminated:=cs:C1710.OpenAIChatCompletionsStreamResult.new(Null:C1517; \
"data: {\"choices\":[{\"delta\":{\"content\":\"data: x\"}}]}\ndata: [DONE]\n"; True:C214)
ASSERT:C1129($terminated.data#Null:C1517; "A content holding \"data: \" must not break the framing")
ASSERT:C1129($terminated.choice#Null:C1517; "A content holding \"data: \" must still expose its choice")
ASSERT:C1129($terminated._decodingErrors=Null:C1517; "A content holding \"data: \" must not produce a decode error")

// MARK:- Test 29: a data payload that is not json at all is still an error, not a keep alive
$collector:={stream: True:C214; received: []; onData: Formula:C1597(This:C1470.received.push($1))}
$options:=cs:C1710._OpenAIAsyncOptions.new({}; Null:C1517; cs:C1710.OpenAIChatCompletionsParameters.new($collector); cs:C1710.OpenAIResult.new())

TEXT TO BLOB:C554("data: oops\ndata: {\"a\":1}\n"; $blob; UTF8 text without length:K22:17)
$options.onData(Null:C1517; {data: $blob})
ASSERT:C1129($collector.received.length=1; "Only the decodable packet must be notified, got: "+String:C10($collector.received.length))
ASSERT:C1129($options._streamErrors.length>0; "A non json data payload must not be silently dropped")

// MARK:- Test 30: a json error body instead of an event stream, seen by onTerminate
$terminated:=cs:C1710.OpenAIChatCompletionsStreamResult.new(Null:C1517; \
"{\"error\":{\"message\":\"invalid api key\"}}"; True:C214)
ASSERT:C1129($terminated.errors.length=1; "A json error body must still be reported, got: "+JSON Stringify:C1217($terminated.errors))
ASSERT:C1129(String:C10($terminated.errors[0].message)="invalid api key"; "The error message must be kept, got: "+JSON Stringify:C1217($terminated.errors))

// MARK:- Test 31: several chunks without the optional space, the last one must win
// Framing on "data: " leaves the whole body as one fragment, and JSON Parse stops
// on the first object: the terminate result then holds the very first chunk.
$terminated:=cs:C1710.OpenAIChatCompletionsStreamResult.new(Null:C1517; \
"data:{\"choices\":[{\"delta\":{\"content\":\"Hi\"},\"finish_reason\":null}]}\ndata:{\"choices\":[{\"delta\":{\"content\":\" there\"},\"finish_reason\":\"stop\"}]}\ndata:[DONE]\n"; True:C214)
ASSERT:C1129($terminated.choice#Null:C1517; "Terminate must expose a choice without the optional space")
ASSERT:C1129(String:C10($terminated.choice.delta.content)=" there"; "Terminate must keep the last chunk, got: '"+String:C10($terminated.choice.delta.content)+"'")
ASSERT:C1129(String:C10($terminated.choice.finish_reason)="stop"; "Terminate must keep the finish reason, got: '"+String:C10($terminated.choice.finish_reason)+"'")
