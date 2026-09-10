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
