//%attributes = {}

// MARK:- Unit Tests for OpenAIMessage Class

var $testShared : Boolean:=Shift down:C543

// MARK:- Test Constructor
var $msg1 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: "Hello"})
ASSERT:C1129($msg1.role="user"; "Constructor should set role property")
ASSERT:C1129($msg1.content="Hello"; "Constructor should set content property")

var $msg2 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "assistant"; content: "Hi"; user: "john"})
ASSERT:C1129($msg2.user="john"; "Constructor should set optional user property")

var $msg3 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new(Null:C1517)
ASSERT:C1129($msg3#Null:C1517; "Constructor with null should return instance")

// Test that 'text' computed property is not set during construction
var $msg4 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: "actual"; text: "ignored"})
ASSERT:C1129($msg4.content="actual"; "Constructor should skip 'text' property")
ASSERT:C1129($msg4.text="actual"; "Constructor should skip 'text' property")

// MARK:- Test text getter
var $textMsg1 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: "Simple text"})
ASSERT:C1129($textMsg1.text="Simple text"; "text getter should return string content")

var $textMsg2 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: [{type: "text"; text: "Text in collection"}]})
ASSERT:C1129($textMsg2.text="Text in collection"; "text getter should extract text from collection")

var $textMsg3 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: [{type: "image_url"; url: "..."}]})
ASSERT:C1129($textMsg3.text=""; "text getter should return empty string if no text element")

var $textMsg4 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"})
ASSERT:C1129($textMsg4.text=""; "text getter should return empty string if content is null")

// MARK:- Test text setter
var $setMsg1 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"})
$setMsg1.text:="New text"
ASSERT:C1129($setMsg1.content="New text"; "text setter should set string content when content is null")

var $setMsg2 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: "Old text"})
$setMsg2.text:="Updated text"
ASSERT:C1129($setMsg2.content="Updated text"; "text setter should update string content")

var $setMsg3 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: [{type: "text"; text: "Original"}]})
$setMsg3.text:="Modified"
ASSERT:C1129($setMsg3.content[0].text="Modified"; "text setter should update text element in collection")

var $setMsg4 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: [{type: "image_url"; url: "..."}]})
$setMsg4.text:="Added text"
ASSERT:C1129($setMsg4.content[0].type="text"; "text setter should add text element at beginning if not present")
ASSERT:C1129($setMsg4.content[0].text="Added text"; "text setter should set correct text value")

// MARK:- Test addImageURL
var $imgMsg1 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: "Describe this image"})
$imgMsg1.addImageURL("https://example.com/image.jpg"; "high")
ASSERT:C1129(Value type:C1509($imgMsg1.content)=Is collection:K8:32; "addImageURL should convert content to collection")
ASSERT:C1129($imgMsg1.content.length=2; "addImageURL should add image to collection")
ASSERT:C1129($imgMsg1.content[1].type="image_url"; "Image entry should have correct type")
ASSERT:C1129($imgMsg1.content[1].image_url.url="https://example.com/image.jpg"; "Image URL should be set correctly")
ASSERT:C1129($imgMsg1.content[1].image_url.detail="high"; "Image detail should be set when valid")

var $imgMsg2 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: [{type: "text"; text: "Test"}]})
$imgMsg2.addImageURL("https://example.com/img2.png"; "")
ASSERT:C1129($imgMsg2.content.length=2; "addImageURL should add to existing collection")
ASSERT:C1129(Undefined:C82($imgMsg2.content[1].image_url.detail); "Image detail should not be set when empty")

var $imgMsg3 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: "Test"})
$imgMsg3.addImageURL("https://example.com/img3.jpg"; "invalid")
ASSERT:C1129(Undefined:C82($imgMsg3.content[1].image_url.detail); "Image detail should not be set when invalid")

var $imgMsg4 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: "Test"})
$imgMsg4.addImageURL("https://example.com/img4.jpg"; "low")
ASSERT:C1129($imgMsg4.content[1].image_url.detail="low"; "Image detail 'low' should be accepted")

var $imgMsg5 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: "Test"})
$imgMsg5.addImageURL("https://example.com/img5.jpg"; "auto")
ASSERT:C1129($imgMsg5.content[1].image_url.detail="auto"; "Image detail 'auto' should be accepted")

// MARK:- Test addFile
var $fileMsg1 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: "Check this file"})
var $validFile : cs:C1710.OpenAIFile:=cs:C1710.OpenAIFile.new({id: "file-123"; purpose: "user_data"})
$fileMsg1.addFileId($validFile.id)
ASSERT:C1129(Value type:C1509($fileMsg1.content)=Is collection:K8:32; "addFile should convert content to collection")
ASSERT:C1129($fileMsg1.content.length=2; "addFile should add file to collection")
ASSERT:C1129($fileMsg1.content[1].type="file"; "File entry should have correct type")
ASSERT:C1129($fileMsg1.content[1].file.file_id="file-123"; "File ID should be set correctly")

var $fileMsg2 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: [{type: "text"; text: "Test"}]})
$fileMsg2.addFileId($validFile.id)
ASSERT:C1129($fileMsg2.content.length=2; "addFile should add to existing collection")

// MARK:- Test _toObject
var $toObjMsg1 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "user"; content: "Test"})
var $obj1 : Object:=$toObjMsg1._toObject()
ASSERT:C1129($obj1.role="user"; "_toObject should include role property")
ASSERT:C1129($obj1.content="Test"; "_toObject should include content property")
ASSERT:C1129(Undefined:C82($obj1.text); "_toObject should exclude computed text property")

var $toObjMsg2 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "assistant"; content: "Hello"; tool_calls: [{id: "call_1"}]})
var $obj2 : Object:=$toObjMsg2._toObject()
ASSERT:C1129($obj2.tool_calls.length=1; "_toObject should include collections")
ASSERT:C1129($obj2.tool_calls[0].id="call_1"; "_toObject should preserve collection content")

// Test shared object conversion
var $sharedMsg : cs:C1710.OpenAIMessage:=OB Copy:C1225(cs:C1710.OpenAIMessage.new({role: "assistant"; content: "Test"; metadata: {key: "value"}}); ck shared:K85:29)
var $nonSharedObj : Object:=$sharedMsg._toObject()
ASSERT:C1129(Not:C34(OB Is shared:C1759($nonSharedObj)); "_toObject should return non-shared object from shared message")
ASSERT:C1129($nonSharedObj.role="assistant"; "_toObject should preserve properties from shared object")
ASSERT:C1129($nonSharedObj.metadata.key="value"; "_toObject should preserve nested properties from shared object")

// MARK:- Test tool_calls property
var $toolMsg1 : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "assistant"; tool_calls: [{id: "call_1"; type: "function"; function: {name: "test_func"; arguments: "{}"}}]})
ASSERT:C1129($toolMsg1.tool_calls.length=1; "Constructor should set tool_calls collection")
ASSERT:C1129($toolMsg1.tool_calls[0].id="call_1"; "Tool calls should be preserved with correct properties")

// MARK:- Test tool_call_id property
var $toolIdMsg : cs:C1710.OpenAIMessage:=cs:C1710.OpenAIMessage.new({role: "tool"; tool_call_id: "call_123"; content: "Result"})
ASSERT:C1129($toolIdMsg.tool_call_id="call_123"; "Constructor should set tool_call_id property")
