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
│       └── Methods/          # Project methods
├── Documentation/            # API documentation
├── Resources/               # Localized resources
└── Libraries/               # External libraries
```

---

## 🎯 Feature Implementation Checklist

### 1. Planning Phase
- [ ] Define the feature requirements
- [ ] Identify which OpenAI API endpoint(s) to use
- [ ] Determine if new classes or methods are needed
- [ ] Check for existing similar functionality

### 2. Implementation Phase
- [ ] Create/modify 4D class files (*.4dm)
- [ ] Add parameter classes if needed
- [ ] Add result classes if needed
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

Class constructor($client : cs.OpenAI)
	Super($client)
	This.endpoint:="/v1/[endpoint-path]"

// Main API method
Function [actionName]($params : cs.OpenAI[Feature]Parameters) : cs.OpenAI[Feature]Result
	var $result : cs.OpenAI[Feature]Result
	var $options : Object
	
	// Build request
	$options:=New object
	$options.method:="POST"  // or GET, DELETE, etc.
	$options.endpoint:=This.endpoint
	$options.body:=$params.toObject()
	
	// Make request
	$result:=cs.OpenAI[Feature]Result.new()
	$result.response:=This._request($options)
	
	// Handle response
	If ($result.response.success)
		$result.parse($result.response.data)
	Else 
		$result.error:=cs.OpenAIError.new($result.response)
	End if 
	
	return $result

// Async version
Function [actionName]Async($params : cs.OpenAI[Feature]Parameters; $callback : 4D.Function)
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
4. Add the API accessor to the main `OpenAI` class
5. Document the new endpoint

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
	$result.error:=cs.OpenAIError.new($result.response)
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

## Inheritance
Extends: [ParentClass]

## Constructor
\`\`\`4d
$instance:=cs.[ClassName].new([params])
\`\`\`

## Properties
| Property | Type | Description |
|----------|------|-------------|
| property1 | Text | Description |
| property2 | Integer | Description |

## Methods

### methodName
Description of what the method does.

**Parameters:**
- `$param1` (Type): Description
- `$param2` (Type): Description

**Returns:**
- Type: Description

**Example:**
\`\`\`4d
$result:=$instance.methodName($param1; $param2)
\`\`\`

## Examples

### Basic Usage
\`\`\`4d
// Example code here
\`\`\`

### Advanced Usage
\`\`\`4d
// Advanced example
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

### 4. Add to Main Client
Update `OpenAI.4dm` to include:
```4d
Function get audio() : cs.OpenAIAudioAPI
	return cs.OpenAIAudioAPI.new(This)
```

### 5. Document
**File:** `Documentation/Classes/OpenAIAudioAPI.md`

---

## 📞 Getting Help

- Check existing implementations in `Project/Sources/Classes/`
- Review OpenAI API documentation: https://platform.openai.com/docs
- Look at examples in `Documentation/`
- Use the patterns from `OpenAIChatAPI` as a reference

---

## ✅ Quick Start for New Features

1. **Identify** the OpenAI endpoint you need
2. **Copy** a similar existing implementation
3. **Modify** for your specific endpoint
4. **Test** with the 4D debugger
5. **Document** your implementation
6. **Create examples** showing usage
