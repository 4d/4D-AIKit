# TOONEncoder

The `TOONEncoder` singleton class converts 4D objects and collections to TOON (Token-Oriented Object Notation) format. TOON is a compact, LLM-friendly data serialization format that achieves approximately 40% fewer tokens than JSON while maintaining readability and data fidelity.

## Overview

TOON combines YAML-like indentation for objects with CSV-style tabular layouts for arrays, making it ideal for:
- Sending structured data to Large Language Models (LLMs)
- Reducing token usage in AI API calls
- Maintaining human-readable data representation
- Achieving 100% lossless round-trip conversion with JSON

## Key Features

- **Token Efficient**: ~40% fewer tokens than equivalent JSON
- **Tabular Arrays**: Uniform object arrays use compact CSV-style format
- **Minimal Quoting**: Strings only quoted when necessary
- **Type Preservation**: Supports all JSON data types
- **Direct Conversion**: No intermediate JSON text conversion required

## Format Examples

### Simple Object
```4d
var $data:={name: "Alice"; age: 30; active: True}
var $toon:=cs.TOONEncoder.me.encode($data)
// Result:
// name: Alice
// age: 30
// active: true
```

### Nested Objects
```4d
var $data:={user: {name: "Bob"; email: "bob@example.com"}}
var $toon:=cs.TOONEncoder.me.encode($data)
// Result:
// user:
//   name: Bob
//   email: bob@example.com
```

### Primitive Arrays
```4d
var $data:={tags: ["admin"; "user"; "developer"]}
var $toon:=cs.TOONEncoder.me.encode($data)
// Result:
// tags[3]: admin,user,developer
```

### Tabular Arrays (Uniform Objects)
```4d
var $users:=[]
$users.push({id: 1; name: "Alice"; role: "admin"})
$users.push({id: 2; name: "Bob"; role: "user"})
var $data:={users: $users}
var $toon:=cs.TOONEncoder.me.encode($data)
// Result:
// users[2]{id,name,role}:
//   1,Alice,admin
//   2,Bob,user
```

## Functions

### encode

Converts a 4D value to TOON format string.

| Argument | Type | Description |
|----------|------|-------------|
| $input | Variant | Any 4D value (Object, Collection, Text, Number, Boolean, Date, Null) |
| $options | Object | Encoding options (optional) |

**Returns**: Text containing the TOON formatted output.

**Options**:
- `indent` (Integer): Spaces per indentation level (default: 2)

```4d
var $encoder:=cs.TOONEncoder.me

// Simple usage
var $toon:=$encoder.encode({name: "Test"; value: 42})

// With custom indent
var $toon:=$encoder.encode($data; {indent: 4})
```

### encodeLines

Converts a 4D value to a Collection of TOON lines (without newlines).

| Argument | Type | Description |
|----------|------|-------------|
| $input | Variant | Any 4D value to encode |
| $options | Object | Encoding options (optional) |

**Returns**: Collection of Text, where each element is a line of TOON output.

Useful for streaming or processing large datasets line-by-line.

```4d
var $encoder:=cs.TOONEncoder.me
var $lines:=$encoder.encodeLines({name: "Test"; value: 42})
// Returns: ["name: Test", "value: 42"]
```

## Type Handling

### Supported Types

| 4D Type | TOON Output | Notes |
|---------|-------------|-------|
| Object | `key: value` pairs with indentation | Nested objects use additional indentation |
| Collection | Arrays with format detection | Automatically chooses optimal format |
| Text | Unquoted or quoted string | Minimal quoting applied |
| Real/Longint | Number | Special cases: -0→0, Infinity→null, NaN→null |
| Boolean | `true` or `false` | Lowercase literals |
| Date | ISO 8601 string | Format: `"2025-01-15T10:30:00Z"` |
| Null | `null` | Lowercase literal |
| Time | `null` | Not supported (converted to null) |
| Picture | `null` | Not supported (converted to null) |

### String Quoting Rules

Strings are only quoted when necessary:

**No quotes needed**:
- Simple strings: `hello`, `test123`
- Strings with internal spaces: `hello world`
- Unicode characters: `你好世界`

**Quotes required**:
- Empty string: `""`
- Leading/trailing whitespace: `" hello "`, `"world "`
- Boolean/null literals: `"true"`, `"false"`, `"null"`
- Number-like strings: `"42"`, `"3.14"`, `"1e-6"`, `"05"`
- Strings with structural characters: `"key:value"`, `"[array]"`, `"{object}"`
- Strings with commas: `"a,b,c"`
- Strings starting with hyphen: `"-item"`
- Strings with control characters: `"line1\nline2"`

### Array Format Detection

The encoder automatically selects the optimal format for arrays:

**Inline Format** (primitive values):
```
numbers[3]: 1,2,3
```

**Tabular Format** (uniform objects with primitive values):
```
items[2]{id,name,price}:
  1,Widget,9.99
  2,Gadget,14.50
```

**List Format** (mixed or non-uniform):
```
mixed[3]:
  - 42
  - hello
  - {key: value}
```

## Usage Examples

### Basic Data Encoding

```4d
var $encoder:=cs.TOONEncoder.me

// Encode simple data
var $data:={product: "Widget"; price: 9.99; inStock: True}
var $toon:=$encoder.encode($data)
```

### Complex Nested Structure

```4d
var $encoder:=cs.TOONEncoder.me

var $context:={task: "Analyze sales"; location: "Boulder"; season: "Q1-2025"}
var $friends:=["ana"; "luis"; "sam"]

var $sales:=[]
$sales.push({id: 1; product: "Widget"; revenue: 1250.50; date: Current date})
$sales.push({id: 2; product: "Gadget"; revenue: 890.25; date: Current date})

var $data:={context: $context; team: $friends; sales: $sales}
var $toon:=$encoder.encode($data)
```

### Use with LLM APIs

```4d
var $encoder:=cs.TOONEncoder.me

// Encode data for LLM input (saves ~40% tokens vs JSON)
var $analysisData:=...  // Your data object
var $toon:=$encoder.encode($analysisData)

// Use in OpenAI chat completion
var $client:=cs.OpenAI.new($apiKey)
var $messages:=[]
$messages.push({role: "user"; content: "Analyze this data:\n```toon\n"+$toon+"\n```"})

var $result:=$client.chat.completions.create($messages)
```

### Custom Indentation

```4d
var $encoder:=cs.TOONEncoder.me

// Use 4 spaces per indentation level
var $options:={indent: 4}
var $toon:=$encoder.encode($data; $options)
```

### Streaming Large Datasets

```4d
var $encoder:=cs.TOONEncoder.me

// Get lines as collection for processing
var $lines:=$encoder.encodeLines($largeDataset)

// Process line by line
var $line : Text
For each ($line; $lines)
    // Send each line, write to file, etc.
End for each
```

## Best Practices

### When to Use TOON

✅ **Good use cases**:
- Sending structured data to LLMs (GPT, Claude, etc.)
- Reducing token costs in AI API calls
- Data serialization for neural networks
- Human-readable data exchange

❌ **Not recommended**:
- Binary data transmission
- When JSON compatibility is strictly required
- Real-time streaming protocols (use JSON streaming)

### Optimizing for Token Efficiency

1. **Use uniform objects for arrays** - They automatically use tabular format:
   ```4d
   // All objects have same structure = tabular format
   var $items:=[{id: 1; name: "A"}; {id: 2; name: "B"}]
   ```

2. **Keep object keys short but descriptive**:
   ```4d
   // Better
   {qty: 10; amt: 99.50}
   // Than
   {quantity: 10; totalAmount: 99.50}
   ```

3. **Use primitive arrays when possible**:
   ```4d
   // More efficient
   {ids: [1; 2; 3]}
   // Than
   {items: [{id: 1}; {id: 2}; {id: 3}]}
   ```

## Technical Details

### Singleton Pattern

`TOONEncoder` uses a shared singleton pattern. Always access via `.me`:

```4d
var $encoder:=cs.TOONEncoder.me  // ✅ Correct
var $toon:=$encoder.encode($data)
```

### Performance Characteristics

- **Memory**: Builds output as collection of lines before joining
- **Recursion**: Supports unlimited nesting depth
- **Speed**: Optimized for typical data structures (objects with 10-100 properties)

### Normalization Process

The encoder normalizes 4D types before encoding:
1. Dates converted to ISO 8601 strings
2. Special numbers handled: `-0` → `0`, `Infinity` → `null`, `NaN` → `null`
3. Objects and collections recursively normalized
4. Unsupported types (Picture, Time) converted to `null`

## Related Resources

- [TOON Format Specification](https://github.com/toon-format/spec)
- [OpenAI Class](OpenAI.md) - For using TOON with OpenAI APIs
- [OpenAIChatAPI](OpenAIChatAPI.md) - Chat completions with TOON data

## Examples Repository

For more examples and use cases, see:
- Test suite: `test_toon_encoder` method
