//%attributes = {"invisible":true}

// MARK:- Test TOONEncoder - Comprehensive Test Suite

var $encoder : cs:C1710.TOONEncoder
$encoder:=cs:C1710.TOONEncoder.me

var $result : Text
var $expected : Text

// MARK:- Test Primitives

// Test null
$result:=$encoder.encode(Null:C1517)
ASSERT:C1129($result="null"; "Null should encode to 'null'")

// Test boolean true
$result:=$encoder.encode(True:C214)
ASSERT:C1129($result="true"; "Boolean true should encode")

// Test boolean false
$result:=$encoder.encode(False:C215)
ASSERT:C1129($result="false"; "Boolean false should encode")

// Test integer
$result:=$encoder.encode(42)
ASSERT:C1129($result="42"; "Integer should encode")

// Test float
$result:=$encoder.encode(3.14)
ASSERT:C1129($result="3.14"; "Float should encode")

// Test negative number
$result:=$encoder.encode(-42)
ASSERT:C1129($result="-42"; "Negative number should encode")

// MARK:- Test String Quoting

// Test simple string (no quotes needed)
$result:=$encoder.encode("hello")
ASSERT:C1129($result="hello"; "Simple string should not be quoted")

// Test string with internal space (no quotes needed)
$result:=$encoder.encode("hello world")
ASSERT:C1129($result="hello world"; "String with internal space should not be quoted")

// Test empty string (needs quotes)
$result:=$encoder.encode("")
ASSERT:C1129($result="\"\""; "Empty string should be quoted")

// Test string with leading space (needs quotes)
$result:=$encoder.encode(" hello")
ASSERT:C1129($result="\" hello\""; "String with leading space should be quoted")

// Test string with trailing space (needs quotes)
$result:=$encoder.encode("hello ")
ASSERT:C1129($result="\"hello \""; "String with trailing space should be quoted")

// Test boolean-like string (needs quotes)
$result:=$encoder.encode("true")
ASSERT:C1129($result="\"true\""; "String 'true' should be quoted")

$result:=$encoder.encode("false")
ASSERT:C1129($result="\"false\""; "String 'false' should be quoted")

$result:=$encoder.encode("null")
ASSERT:C1129($result="\"null\""; "String 'null' should be quoted")

// Test numeric string (needs quotes)
$result:=$encoder.encode("42")
ASSERT:C1129($result="\"42\""; "Numeric string '42' should be quoted")

$result:=$encoder.encode("3.14")
ASSERT:C1129($result="\"3.14\""; "Numeric string '3.14' should be quoted")

$result:=$encoder.encode("1e-6")
ASSERT:C1129($result="\"1e-6\""; "Scientific notation string should be quoted")

// Test string with leading zero (needs quotes)
$result:=$encoder.encode("05")
ASSERT:C1129($result="\"05\""; "String with leading zero should be quoted")

// Test string with colon (needs quotes)
$result:=$encoder.encode("key:value")
ASSERT:C1129($result="\"key:value\""; "String with colon should be quoted")

// Test string with comma (needs quotes)
$result:=$encoder.encode("a,b")
ASSERT:C1129($result="\"a,b\""; "String with comma should be quoted")

// Test string starting with hyphen (needs quotes)
$result:=$encoder.encode("-item")
ASSERT:C1129($result="\"-item\""; "String starting with hyphen should be quoted")

// MARK:- Test String Escaping

// Test string with quote (needs escaping)
$result:=$encoder.encode("say \"hello\"")
ASSERT:C1129($result="\"say \\\"hello\\\"\""; "String with quotes should be escaped")

// Test string with backslash (needs escaping)
$result:=$encoder.encode("path\\to\\file")
ASSERT:C1129($result="\"path\\\\to\\\\file\""; "String with backslash should be escaped")

// Test string with newline (needs escaping)
var $textWithNewline : Text
$textWithNewline:="line1"+Char:C90(Line feed:K15:40)+"line2"
$result:=$encoder.encode($textWithNewline)
ASSERT:C1129($result="\"line1\\nline2\""; "String with newline should be escaped")

// MARK:- Test Simple Objects

var $obj : Object
$obj:={name: "Alice"; age: 30}
$result:=$encoder.encode($obj)
// Should produce:
// name: Alice
// age: 30
ASSERT:C1129(Position:C15("name: Alice"; $result)>0; "Object property 'name' should be present")
ASSERT:C1129(Position:C15("age: 30"; $result)>0; "Object property 'age' should be present")

// Test object with null value
$obj:={name: "Bob"; active: Null:C1517}
$result:=$encoder.encode($obj)
ASSERT:C1129(Position:C15("active: null"; $result)>0; "Null property should encode to 'null'")

// Test empty object
$obj:={}
$result:=$encoder.encode($obj)
ASSERT:C1129($result=""; "Empty object should produce empty string")

// MARK:- Test Nested Objects

var $nested : Object
$nested:={task: "Test task"; location: "Boulder"}
$obj:={context: $nested}
$result:=$encoder.encode($obj)

// Should produce:
// context:
//   task: Test task
//   location: Boulder
ASSERT:C1129(Position:C15("context:"; $result)>0; "Nested object key should be present")
ASSERT:C1129(Position:C15("  task: Test task"; $result)>0; "Nested field should be indented")
ASSERT:C1129(Position:C15("  location: Boulder"; $result)>0; "Nested field should be indented")

// Test deeply nested objects (3 levels)
var $deep : Object
$deep:={level1: {level2: {level3: "value"}}}
$result:=$encoder.encode($deep)
ASSERT:C1129(Position:C15("level1:"; $result)>0; "Level 1 should be present")
ASSERT:C1129(Position:C15("  level2:"; $result)>0; "Level 2 should be indented")
ASSERT:C1129(Position:C15("    level3: value"; $result)>0; "Level 3 should be double indented")

// MARK:- Test Primitive Arrays

var $arr : Collection
$arr:=[1; 2; 3]
$result:=$encoder.encode($arr)
ASSERT:C1129($result="[3]: 1,2,3"; "Array of numbers should be inline")

$arr:=["a"; "b"; "c"]
$result:=$encoder.encode($arr)
ASSERT:C1129($result="[3]: a,b,c"; "Array of strings should be inline")

$arr:=[True:C214; False:C215; True:C214]
$result:=$encoder.encode($arr)
ASSERT:C1129($result="[3]: true,false,true"; "Array of booleans should be inline")

// Test mixed primitives
$arr:=[1; "text"; True:C214; Null:C1517]
$result:=$encoder.encode($arr)
ASSERT:C1129($result="[4]: 1,text,true,null"; "Array of mixed primitives should be inline")

// Test empty array
$arr:=[]
$result:=$encoder.encode($arr)
ASSERT:C1129($result="[0]:"; "Empty array should show [0]:")

// MARK:- Test Object with Primitive Array

$obj:={friends: ["ana"; "luis"; "sam"]}
$result:=$encoder.encode($obj)
$expected:="friends[3]: ana,luis,sam"
ASSERT:C1129($result=$expected; "Object with primitive array should encode correctly")

// MARK:- Test Tabular Arrays (Uniform Objects)

var $users : Collection
$users:=[]
$users.push({id: 1; name: "Alice"; active: True:C214})
$users.push({id: 2; name: "Bob"; active: False:C215})

$obj:={users: $users}
$result:=$encoder.encode($obj)

// Should produce:
// users[2]{id,name,active}:
//   1,Alice,true
//   2,Bob,false
ASSERT:C1129(Position:C15("users[2]{id,name,active}:"; $result)>0; "Tabular header should be present")
ASSERT:C1129(Position:C15("1,Alice,true"; $result)>0; "First row should be present")
ASSERT:C1129(Position:C15("2,Bob,false"; $result)>0; "Second row should be present")

// Test tabular with more fields
var $items : Collection
$items:=[]
$items.push({sku: "A1"; qty: 2; price: 9.99; inStock: True:C214})
$items.push({sku: "B2"; qty: 1; price: 14.5; inStock: False:C215})

$obj:={items: $items}
$result:=$encoder.encode($obj)
ASSERT:C1129(Position:C15("items[2]{sku,qty,price,inStock}:"; $result)>0; "Tabular header with 4 fields")
ASSERT:C1129(Position:C15("A1,2,9.99,true"; $result)>0; "First item row")
ASSERT:C1129(Position:C15("B2,1,14.5,false"; $result)>0; "Second item row")

// MARK:- Test Non-Uniform Arrays (List Format)

// Test array with different object structures
var $mixed : Collection
$mixed:=[]
$mixed.push({id: 1; name: "First"})
$mixed.push({id: 2; name: "Second"; extra: True:C214})  // Different keys!

$obj:={items: $mixed}
$result:=$encoder.encode($obj)

// Should use list format with "- " markers
ASSERT:C1129(Position:C15("items[2]:"; $result)>0; "List header should be present")
ASSERT:C1129(Position:C15("- "; $result)>0; "List marker should be present")

// MARK:- Test Mixed Arrays

// Test array with primitives and objects
$mixed:=[1; "text"; {key: "value"}]
$result:=$encoder.encode($mixed)
ASSERT:C1129(Position:C15("[3]:"; $result)>0; "Mixed array header")
ASSERT:C1129(Position:C15("- 1"; $result)>0; "Primitive in list format")
ASSERT:C1129(Position:C15("- text"; $result)>0; "String in list format")

// MARK:- Test Custom Indent

$obj:={outer: {inner: "value"}}
var $options : Object
$options:={indent: 4}
$result:=$encoder.encode($obj; $options)
ASSERT:C1129(Position:C15("    inner: value"; $result)>0; "Custom indent of 4 spaces")

// Test with indent=0
$options:={indent: 0}
$result:=$encoder.encode($obj; $options)
ASSERT:C1129(Position:C15("inner: value"; $result)>0; "Indent of 0 should work")

// MARK:- Test Date Normalization

var $date : Date
$date:=Current date:C33
$result:=$encoder.encode({created: $date})

// Should convert to ISO 8601 string
ASSERT:C1129(Position:C15("created: "; $result)>0; "Date field should be present")
// ISO format check (contains "T" and likely ends with "Z")
var $dateValue : Text
$dateValue:=Substring:C12($result; Position:C15("created: "; $result)+9)
ASSERT:C1129(Position:C15("T"; $dateValue)>0; "Date should be in ISO format with T separator")

// MARK:- Test Special Number Cases

// Test -0 (should become 0)
$result:=$encoder.encode({value: -0})
ASSERT:C1129(Position:C15("value: 0"; $result)>0; "-0 should normalize to 0")

// MARK:- Test Complex Real-World Example

var $context : Object
$context:={task: "Our favorite hikes together"; location: "Boulder"; season: "spring_2025"}

var $friends : Collection
$friends:=["ana"; "luis"; "sam"]

var $hikes : Collection
$hikes:=[]
$hikes.push({id: 1; name: "Blue Lake Trail"; distanceKm: 7.5; elevationGain: 320; companion: "ana"; wasSunny: True:C214})
$hikes.push({id: 2; name: "Ridge Overlook"; distanceKm: 9.2; elevationGain: 540; companion: "luis"; wasSunny: False:C215})
$hikes.push({id: 3; name: "Wildflower Loop"; distanceKm: 5.1; elevationGain: 180; companion: "sam"; wasSunny: True:C214})

var $data : Object
$data:={context: $context; friends: $friends; hikes: $hikes}

$result:=$encoder.encode($data)

// Verify structure
ASSERT:C1129(Position:C15("context:"; $result)>0; "Context object")
ASSERT:C1129(Position:C15("  task: Our favorite hikes together"; $result)>0; "Context task")
ASSERT:C1129(Position:C15("friends[3]: ana,luis,sam"; $result)>0; "Friends array")
ASSERT:C1129(Position:C15("hikes[3]{id,name,distanceKm,elevationGain,companion,wasSunny}:"; $result)>0; "Hikes tabular header")
ASSERT:C1129(Position:C15("1,Blue Lake Trail,7.5,320,ana,true"; $result)>0; "First hike")
ASSERT:C1129(Position:C15("2,Ridge Overlook,9.2,540,luis,false"; $result)>0; "Second hike")
ASSERT:C1129(Position:C15("3,Wildflower Loop,5.1,180,sam,true"; $result)>0; "Third hike")

// MARK:- Test Key Quoting

// Test valid unquoted keys
$obj:={simpleKey: "value"; key_with_underscore: "value"; key123: "value"; key_1_2_3: "value"}
$result:=$encoder.encode($obj)
ASSERT:C1129(Position:C15("simpleKey: value"; $result)>0; "Simple key should not be quoted")
ASSERT:C1129(Position:C15("key_with_underscore: value"; $result)>0; "Key with underscore should not be quoted")
ASSERT:C1129(Position:C15("key123: value"; $result)>0; "Key with numbers should not be quoted")

// Test keys that need quoting (using New object for special keys)
$obj:=New object:C1471("key with space"; "value1"; "key-with-dash"; "value2"; "123key"; "value3")
$result:=$encoder.encode($obj)
ASSERT:C1129(Position:C15("\"key with space\": value1"; $result)>0; "Key with space should be quoted")
ASSERT:C1129(Position:C15("\"key-with-dash\": value2"; $result)>0; "Key with dash should be quoted")
ASSERT:C1129(Position:C15("\"123key\": value3"; $result)>0; "Key starting with number should be quoted")

// MARK:- Test encodeLines API

var $lines : Collection
$lines:=$encoder.encodeLines({name: "Test"; value: 42})
ASSERT:C1129($lines.length=2; "encodeLines should return collection of 2 lines")
ASSERT:C1129($lines[0]="name: Test"; "First line should be name property")
ASSERT:C1129($lines[1]="value: 42"; "Second line should be value property")

// MARK:- All Tests Complete

