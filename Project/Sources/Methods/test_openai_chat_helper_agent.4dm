//%attributes = {}
// Offline tests for the agent control plane:
//  (1) the maxIterations loop guard on OpenAIChatHelper, and
//  (2) the stopReason terminal state, which is derived by the result itself
//      (so it also works when calling the API directly, without the ChatHelper).
// No network is required.

var $helper : cs:C1710.OpenAIChatHelper:=cs:C1710.OpenAI.new().chat.create("You are a test assistant.")

// MARK:- Helper defaults
ASSERT:C1129($helper.maxIterations=10; "default maxIterations should be 10")
ASSERT:C1129($helper._iteration=0; "initial _iteration should be 0")
ASSERT:C1129($helper.stopReason=""; "initial stopReason should be empty")

// MARK:- _reachedMaxIterations
$helper.maxIterations:=0  // 0 or less means unlimited
$helper._iteration:=999
ASSERT:C1129(Not:C34($helper._reachedMaxIterations()); "maxIterations<=0 must never be reached (unlimited)")

$helper.maxIterations:=3
$helper._iteration:=2
ASSERT:C1129(Not:C34($helper._reachedMaxIterations()); "2 rounds with budget 3 should not be reached")
$helper._iteration:=3
ASSERT:C1129($helper._reachedMaxIterations(); "3 rounds with budget 3 should be reached")
$helper._iteration:=4
ASSERT:C1129($helper._reachedMaxIterations(); "over-budget should be reached")

// MARK:- result.stopReason is derived by the result (no ChatHelper needed)

// finish_reason carried verbatim
var $cases : Collection:=["stop"; "length"; "tool_calls"; "content_filter"; "stop_sequence"]
var $reason : Text
For each ($reason; $cases)
	var $r : cs:C1710.OpenAIChatCompletionsResult:=cs:C1710.OpenAIChatCompletionsResult.new()
	$r.request:={response: {status: 200; body: {choices: [{finish_reason: $reason}]}}}
	ASSERT:C1129($r.stopReason=$reason; "result.stopReason should derive finish_reason '"+$reason+"'")
End for each

// failed request -> "error"
var $rErr : cs:C1710.OpenAIChatCompletionsResult:=cs:C1710.OpenAIChatCompletionsResult.new()
$rErr.request:={response: {status: 500; body: {}}}
ASSERT:C1129($rErr.stopReason="error"; "failed result.stopReason should be 'error'")

// success but no finish_reason yet -> "" (not terminated)
var $rEmpty : cs:C1710.OpenAIChatCompletionsResult:=cs:C1710.OpenAIChatCompletionsResult.new()
$rEmpty.request:={response: {status: 200; body: {choices: [{}]}}}
ASSERT:C1129($rEmpty.stopReason=""; "result without finish_reason should be empty")

// explicit override (what the agent loop sets) wins over derivation
var $rOver : cs:C1710.OpenAIChatCompletionsResult:=cs:C1710.OpenAIChatCompletionsResult.new()
$rOver.request:={response: {status: 200; body: {choices: [{finish_reason: "tool_calls"}]}}}
$rOver.stopReason:="max_iterations"  // goes through the setter
ASSERT:C1129($rOver.stopReason="max_iterations"; "explicit override should win over finish_reason")

// same derivation on the streamed result class
var $sr : cs:C1710.OpenAIChatCompletionsStreamResult:=cs:C1710.OpenAIChatCompletionsStreamResult.new(Null:C1517; {}; True:C214)
$sr.data:={choices: [{finish_reason: "stop"}]}
ASSERT:C1129($sr.stopReason="stop"; "stream result.stopReason should derive finish_reason")

// MARK:- _setStopReason mirrors on helper and result
$helper.stopReason:=""
var $rSet : cs:C1710.OpenAIChatCompletionsResult:=cs:C1710.OpenAIChatCompletionsResult.new()
$helper._setStopReason($rSet; "max_iterations")
ASSERT:C1129($helper.stopReason="max_iterations"; "_setStopReason should set helper.stopReason")
ASSERT:C1129($rSet.stopReason="max_iterations"; "_setStopReason should set result.stopReason")
$helper._setStopReason(Null:C1517; "cancelled")  // tolerate a null result
ASSERT:C1129($helper.stopReason="cancelled"; "_setStopReason should set helper.stopReason even with null result")

// MARK:- reset() clears per-turn state
$helper._iteration:=7
$helper.stopReason:="tool_calls"
$helper.reset()
ASSERT:C1129($helper._iteration=0; "reset() should clear _iteration")
ASSERT:C1129($helper.stopReason=""; "reset() should clear stopReason")
