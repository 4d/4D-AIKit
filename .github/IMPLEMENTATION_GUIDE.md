# Implementation Guide for 4D-AIKit

## 📋 Overview
This guide helps developers (human and AI) implement new features in the 4D-AIKit project. It provides structure, conventions, and best practices for consistent development.

---

## 🏗️ Project Structure

```
4D-AIKit/
├── Project/
│   └── Sources/
│       ├── Classes/          # 4D Classes (*.4dm)
│       ├── Forms/            # UI Forms
│       ├── Methods/          # Project methods
│       └── folders.json      # Folder organization (required)
├── Documentation/            # API documentation
├── Resources/               # Localized resources
└── Libraries/               # External libraries
```

### Feature Folders

**Each feature must have its own folder defined in `folders.json`**

The `Project/Sources/folders.json` file organizes the project structure by grouping related classes, methods, and forms into logical folders. When implementing a new feature, you must:

1. **Create a folder entry** for your feature in `folders.json`
2. **Register all related classes** under that folder
3. **Use sub-groups** if your feature has multiple components

#### Example folder structure:
```json
{
  "[Feature]": {
    "classes": [
      "OpenAI[Feature]API",
      "OpenAI[Feature]Parameters",
      "OpenAI[Feature]Result"
    ]
  }
}
```

This organization:
- Creates a "[Feature]" folder containing all related classes
- Groups API, Parameters, and Result classes together for better navigation
- Keeps the structure simple with one level per feature

**Best practices:**
- Feature name should match the API category (e.g., "Chat", "Embeddings", "Files")
- Parameter and Result classes belong in the same folder as their API class
- Helper classes can be in a separate "Helper" sub-folder
- Keep the folder structure flat and intuitive

---

## 🎯 Feature Implementation Checklist

### 1. Planning Phase
- [ ] Define the feature requirements
- [ ] Identify which OpenAI API endpoint(s) to use
- [ ] Determine if new classes or methods are needed
- [ ] Check for existing similar functionality
- [ ] Plan the folder structure in `folders.json`

### 2. Implementation Phase
- [ ] Create/modify 4D class files (*.4dm)
- [ ] Add parameter classes if needed
- [ ] Add result classes if needed
- [ ] **Update `folders.json`** with new feature folder and classes
- [ ] Implement error handling
- [ ] Add logging/debugging support

### 3. Documentation Phase
- [ ] Create/update class documentation in `Documentation/Classes/`
- [ ] Add usage examples
- [ ] Document parameters and return values
- [ ] Update main README if needed

### 4. Testing Phase
- [ ] Test with valid inputs
- [ ] Test error scenarios
- [ ] Test edge cases
- [ ] Verify async operations work correctly

---

## 📐 4D Class Structure Template

### For API Endpoint Classes
```4d
// Project/Sources/Classes/OpenAI[FeatureName]API.4dm

Class extends OpenAIAPIResource

Class constructor($client : cs.AIKit.OpenAI)
	Super($client)
	This.endpoint:="/v1/[endpoint-path]"

// Main API method
Function [actionName]($params : cs.AIKit.OpenAI[Feature]Parameters) : cs.AIKit.OpenAI[Feature]Result
	var $result : cs.AIKit.OpenAI[Feature]Result
	var $options : Object
	
	// Build request
	$options:=New object
	$options.method:="POST"  // or GET, DELETE, etc.
	$options.endpoint:=This.endpoint
	$options.body:=$params.toObject()
	
	// Make request
	$result:=cs.AIKit.OpenAI[Feature]Result.new()
	$result.response:=This._request($options)
	
	// Handle response
	If ($result.response.success)
		$result.parse($result.response.data)
	Else 
		$result.error:=cs.AIKit.OpenAIError.new($result.response)
	End if 
	
	return $result

// Async version
Function [actionName]Async($params : cs.AIKit.OpenAI[Feature]Parameters; $callback : 4D.Function)
	var $options : cs._OpenAIAsyncOptions
	
	$options:=cs._OpenAIAsyncOptions.new()
	$options.params:=$params
	$options.callback:=$callback
	$options.resultClass:="OpenAI[Feature]Result"
	
	This._requestAsync($options)
```

### For Parameter Classes
```4d
// Project/Sources/Classes/OpenAI[Feature]Parameters.4dm

Class extends OpenAIParameters

Class constructor
	Super()
	
	// Required parameters
	This.requiredParam:=Null
	
	// Optional parameters with defaults
	This.optionalParam:=Null
	This.model:="gpt-4"

Function toObject() : Object
	var $obj : Object
	
	$obj:=New object
	
	// Add required parameters
	If (This.requiredParam#Null)
		$obj.required_param:=This.requiredParam
	End if 
	
	// Add optional parameters
	If (This.optionalParam#Null)
		$obj.optional_param:=This.optionalParam
	End if 
	
	If (This.model#Null)
		$obj.model:=This.model
	End if 
	
	return $obj
```

### For Result Classes
```4d
// Project/Sources/Classes/OpenAI[Feature]Result.4dm

Class extends OpenAIResult

Class constructor
	Super()
	
	// Result-specific properties
	This.data:=Null
	This.items:=Null

Function parse($response : Object)
	// Parse the API response
	If ($response#Null)
		This.data:=$response.data
		This.items:=$response.items
		
		// Set common properties from parent
		Super.parse($response)
	End if
```

---

## 🔧 Common Patterns

### 1. Adding a New OpenAI API Endpoint

**Files to create:**
1. `Project/Sources/Classes/OpenAI[Feature]API.4dm` - Main API class
2. `Project/Sources/Classes/OpenAI[Feature]Parameters.4dm` - Request parameters
3. `Project/Sources/Classes/OpenAI[Feature]Result.4dm` - Response structure
4. `Documentation/Classes/OpenAI[Feature]API.md` - Documentation

**Steps:**
1. Extend `OpenAIAPIResource` for the API class
2. Extend `OpenAIParameters` for parameters
3. Extend `OpenAIResult` for results
4. **Update `Project/Sources/folders.json`** to add the new feature folder and register all classes
5. Add the API accessor to the main `OpenAI` class
6. Document the new endpoint

### 2. Adding Helper Utilities

**For image/media processing:**
- Add to `_ImageUtils` class
- Keep utilities private (prefix with `_`)

**For API helpers:**
- Create specific helper classes (e.g., `OpenAIChatHelper`)
- Make them accessible through main API classes

### 3. Error Handling Pattern

```4d
If ($result.response.success)
	// Parse successful response
	$result.parse($result.response.data)
Else 
	// Handle error
	$result.error:=cs.AIKit.OpenAIError.new($result.response)
	// Optional: Log error
	TRACE
End if
```

---

## 📝 Naming Conventions

### Properties
- Use camelCase for 4D properties
- Use snake_case when converting to API JSON (in `toObject()`)

---

## 🔍 Code Review Checklist

- [ ] Code follows 4D naming conventions
- [ ] Error handling is implemented
- [ ] Both sync and async versions exist (if applicable)
- [ ] Parameters are validated
- [ ] Documentation is complete
- [ ] Examples are provided
- [ ] No hardcoded API keys or sensitive data
- [ ] Proper inheritance from base classes
- [ ] Null checks are in place
- [ ] API endpoint URLs are correct

---

## 📚 Documentation Template

Create a file in `Documentation/Classes/[ClassName].md`:

```markdown
# [ClassName]

## Description
Brief description of what this class does.

## Inherits

[ParentClass](ParentClass.md)

## Constructor 
\`\`\`4d
$instance:=cs.AIKit.[ClassName].new([params])
\`\`\`

// do not add it if not relevant, ie. we access from client for instance, or result object is never created by user.

## Properties
| Property | Type | Description |
|----------|------|-------------|
| property1 | Text | Description |
| property2 | Integer | Description |

## Functions

### methodName()

**methodName**(*param1* : Type ; *param2* : Type) : ReturnType

| Parameter       | Type        | Description                    |
|-----------------|-------------|--------------------------------|
| *param1*        | Type        | Description of param1          |
| *param2*        | Type        | Description of param2          |
| Function result | ReturnType  | Description of return value    |

Description of what the method does.

#### Example Usage

```4d
var $client : cs.AIKit.OpenAI
$client:=cs.AIKit.OpenAI.new($apiKey)

var $result : cs.AIKit.OpenAI[ResultClass]
$result:=$client.[feature].methodName($param1; $param2)
```

## Examples

### Basic Usage
\`\`\`4d
var $client:=cs.AIKit.OpenAI.new($apiKey)

// Basic example code here
var $result : cs.AIKit.OpenAI[ResultClass]
$result:=$client.[feature].methodName($params)
\`\`\`

### Advanced Usage
\`\`\`4d
var $client:=cs.AIKit.OpenAI.new($apiKey)

// Advanced example with more complex usage
var $params:=cs.AIKit.OpenAI[Feature]Parameters.new()
$params.property1:="value"
$params.property2:=123

var $result : cs.AIKit.OpenAI[ResultClass]
$result:=$client.[feature].methodName($params)
\`\`\`

## Error Handling
Explain how errors are handled.

## See Also
- [RelatedClass1](RelatedClass1.md)
- [RelatedClass2](RelatedClass2.md)
```

---

## 🤖 LLM-Specific Instructions

When an LLM is implementing a new feature:

1. **Read existing similar classes first** to understand patterns
2. **Ask for clarification** if requirements are unclear
3. **Follow the templates** provided in this guide
4. **Create all required files**: API class, Parameters, Result, Documentation
5. **Test the implementation** mentally for edge cases
6. **Provide usage examples** in the documentation

### Context Files to Read
Before implementing a new feature, read:
- `Project/Sources/Classes/OpenAI.4dm` - Main client class
- `Project/Sources/Classes/OpenAIAPIResource.4dm` - Base API class
- Similar existing API classes (e.g., `OpenAIChatAPI.4dm`)
- `Documentation/asynchronous-call.md` - For async patterns

---

## 🎨 Example: Implementing Text-to-Speech

### 1. Create API Class
**File:** `Project/Sources/Classes/OpenAIAudioAPI.4dm`

### 2. Create Parameters
**File:** `Project/Sources/Classes/OpenAIAudioSpeechParameters.4dm`

### 3. Create Result
**File:** `Project/Sources/Classes/OpenAIAudioSpeechResult.4dm`

### 4. Update folders.json
**File:** `Project/Sources/folders.json`
```json
{
  "[Feature]": {
    "classes": [
      "OpenAI[Feature]API",
      "OpenAI[Feature]Parameters",
      "OpenAI[Feature]Result"
    ]
  }
}
```

For example, Audio feature:
```json
{
  "Audio": {
    "classes": [
      "OpenAIAudioAPI",
      "OpenAIAudioSpeechParameters",
      "OpenAIAudioSpeechResult"
    ]
  }
}
```

### 5. Add to Main Client
Update `OpenAI.4dm` to include:
```4d
Function get [featureLowercased]() : cs.AIKit.OpenAI[Feature]API
	return cs.AIKit.OpenAI[Feature]API.new(This)
```

For example, Audio feature:
```4d
Function get audio() : cs.AIKit.OpenAIAudioAPI
	return cs.AIKit.OpenAIAudioAPI.new(This)
```

### 6. Document
**File:** `Documentation/Classes/OpenAIAudioAPI.md`

---

## 📞 Getting Help

- Check existing implementations in `Project/Sources/Classes/`
- Review OpenAI API documentation: https://platform.openai.com/docs
- Look at examples in `Documentation/`
- Use the patterns from `OpenAIChatAPI` as a reference

---

---

## 🧪 Testing New Features

### Testing Structure

The 4D-AIKit project uses a test-driven approach. All tests are located in `Project/Sources/Methods/` with the naming convention `test_*.4dm`. Tests are automatically discovered and run by the `_runTests` method.

### Test Workflow

1. **Create test method** following the naming pattern `test_openai_[feature].4dm`
2. **Add mock service** (if using the 4DAIKitTest workspace)
3. **Write test assertions** using the 4D `ASSERT` command
4. **Run tests** using `_runTests` method

### Test Method Template

```4d
//%attributes = {"invisible":true}
var $client:=TestOpenAI()
If ($client=Null)
	return  // skip test if no client
End if

// MARK:- Test [feature name]
var $modelName:=cs._TestModels.new($client).[feature]

// Setup test parameters
var $params:=cs.OpenAI[Feature]Parameters.new()
$params.property1:="test_value"
$params.model:=$modelName

// Execute API call
var $result:=$client.[feature].[method]($params)

// Assertions
If (Asserted($result.success; "Cannot complete [feature]: "+JSON Stringify($result)))
	
	If (Asserted($result.data#Null; "[Feature] did not return data"))
		
		ASSERT(Length($result.data)>0; "[Feature] returned empty data")
		
		// Additional specific assertions
		ASSERT($result.property="expected_value"; "Property should match expected value")
		
	End if
	
End if

// MARK:- Test error handling
var $invalidParams:=cs.OpenAI[Feature]Parameters.new()
$invalidParams.model:="fake-model"  // Invalid model

$result:=$client.[feature].[method]($invalidParams)

ASSERT(Not($result.success); "Should fail with invalid parameters")
ASSERT($result.error#Null; "Should return error object")
```

### Using Mock Services (4DAIKitTest Workspace)

If the 4DAIKitTest workspace has mock services available, you can test without hitting the real OpenAI API. This is useful for:
- Running tests offline
- Testing error scenarios
- Faster test execution
- Avoiding API costs during development

#### Mock Service Structure

Mock services are singleton classes that intercept HTTP requests and return predefined responses. They are located in `4DAIKitTest/Project/Sources/Classes/Mock*.4dm`.

**Example: MockOpenAI[Feature].4dm**

```4d
shared singleton Class constructor

// @post(/v1/[endpoint]$)
Function [methodName]($request : 4D.IncomingMessage) : 4D.OutgoingMessage
	var $result:=4D.OutgoingMessage.new()
	
	// ...
	
	$result.setBody($response)
	$result.setHeader("Content-Type"; "application/json")
	
	return $result
```

#### When to Create Mock Services

Create a corresponding mock service class when:
1. **Adding a new API endpoint** - Create `MockOpenAI[Feature].4dm` for the endpoint
2. **Testing requires external service** - Mock allows testing without network calls
3. **Need to test error scenarios** - Mock can simulate various error conditions
4. **Want faster test execution** - Mock services respond instantly

#### Mock Service Naming Convention

| API Class | Mock Service Class | HTTP Method |
|-----------|-------------------|-------------|
| `OpenAIChatCompletionsAPI` | `MockOpenAIChatCompletions` | `@post(/v1/chat/completions$)` |
| `OpenAIModelsAPI` | `MockOpenAIModels` | `@get(/v1/models$)` |
| `OpenAIEmbeddingsAPI` | `MockOpenAIEmbeddings` | `@post(/v1/embeddings$)` |
| `OpenAIImagesAPI` | `MockOpenAIImage` | `@post(/v1/images/generations$)` |
| `OpenAIFilesAPI` | `MockOpenAIFiles` | `@post(/v1/files$)` |

**Pattern:** Remove "API" suffix, prepend "Mock", use exact endpoint path in decorator.

#### Configuring Tests to Use Mock Services

In your test method or `TestOpenAI` method, configure the client to use the mock service:

```4d
var $client:=TestOpenAI()

// Use mock service (uncomment in TestOpenAI.4dm)
$client.baseURL:="http://127.0.0.1:80/v1"
$client.apiKey:="none"  // Mock doesn't validate API key
```

### Test Coverage Checklist

When testing a new feature, ensure you cover:

- [ ] **Happy path** - Normal successful operation
- [ ] **Required parameters** - Test with missing required parameters
- [ ] **Optional parameters** - Test with various optional parameter combinations
- [ ] **Invalid model** - Test with fake/invalid model names
- [ ] **Invalid inputs** - Test with wrong data types or formats
- [ ] **Async operations** - Test async version if applicable
- [ ] **Error handling** - Verify error objects are properly returned
- [ ] **Response parsing** - Verify all response fields are correctly parsed
- [ ] **Edge cases** - Empty strings, null values, boundary values



### Test Assertions Best Practices

1. **Use descriptive messages** - Make failures easy to understand
   ```4d
   ASSERT($result.data#Null; "API should return data object")
   ```

2. **Use Asserted() for dependent checks** - Stop test if prerequisite fails
   ```4d
   If (Asserted($result.choice#Null; "No choice returned"))
       ASSERT($result.choice.message#Null; "No message in choice")
   End if
   ```

3. **Test one thing at a time** - Keep tests focused and clear
   ```4d
   // MARK:- Test parameter validation
   // Test specific scenario
   
   // MARK:- Test response format
   // Test another scenario
   ```

4. **Include context in assertions** - Add JSON stringify for debugging
   ```4d
   ASSERT($result.success; "API call failed: "+JSON Stringify($result))
   ```

---

## ✅ Quick Start for New Features

1. **Identify** the OpenAI endpoint you need
2. **Copy** a similar existing implementation
3. **Modify** for your specific endpoint
4. **Create test method** following `test_openai_[feature].4dm` pattern
5. **Add mock service** in 4DAIKitTest workspace if available
6. **Test** with the 4D debugger and run automated tests
7. **Document** your implementation
8. **Create examples** showing usage

---
