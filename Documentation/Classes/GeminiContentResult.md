# GeminiContentResult

## Description

Result object for content generation requests. Contains generated candidates, prompt feedback, and usage information.

## Inherits

[GeminiResult](GeminiResult.md)

## Functions

### get candidates

**candidates** : Collection

| Property        | Type       | Description                              |
|-----------------|------------|------------------------------------------|
| Function result | Collection | Collection of GeminiCandidate objects    |

Returns all response candidates.

### get candidate

**candidate** : cs.GeminiCandidate

| Property        | Type              | Description                      |
|-----------------|-------------------|----------------------------------|
| Function result | GeminiCandidate   | First candidate (convenience)    |

Returns the first candidate.

### get promptFeedback

**promptFeedback** : Object

| Property        | Type   | Description                      |
|-----------------|--------|----------------------------------|
| Function result | Object | Prompt feedback information      |

Returns feedback about the prompt (safety ratings, block reasons).

### get usage

**usage** : Object

| Property        | Type   | Description                      |
|-----------------|--------|----------------------------------|
| Function result | Object | Token usage metadata             |

Returns usage metadata (overrides base class to use `usageMetadata`).

## Examples

### Basic Usage

```4d
var $result:=$gemini.content.generate("Hello world"; "gemini-2.0-flash-exp")

If ($result.success)
    var $text:=$result.candidate.text
    ALERT($text)
End if
```

### Multiple Candidates

```4d
var $params:=cs.GeminiContentParameters.new()
$params.generationConfig:={candidateCount: 3}

var $result:=$gemini.content.generate("Write a joke"; "gemini-2.0-flash-exp"; $params)

If ($result.success)
    For each ($candidate; $result.candidates)
        ALERT("Candidate "+String($candidate.index)+": "+$candidate.text)
    End for each
End if
```

### Access Candidate Details

```4d
var $result:=$gemini.content.generate("Tell me about AI"; "gemini-2.0-flash-exp")

If ($result.success)
    var $candidate:=$result.candidate

    ALERT("Text: "+$candidate.text)
    ALERT("Finish reason: "+$candidate.finishReason)

    // Safety ratings
    For each ($rating; $candidate.safetyRatings)
        ALERT($rating.category+": "+$rating.probability)
    End for each
End if
```

### Check Prompt Feedback

```4d
var $result:=$gemini.content.generate("Dangerous content"; "gemini-2.0-flash-exp")

If ($result.success)
    If ($result.promptFeedback#Null)
        If ($result.promptFeedback.blockReason#Null)
            ALERT("Blocked: "+$result.promptFeedback.blockReason)
        End if

        // Safety ratings for prompt
        For each ($rating; $result.promptFeedback.safetyRatings)
            ALERT("Prompt safety - "+$rating.category+": "+$rating.probability)
        End for each
    End if
End if
```

### Check Usage

```4d
var $result:=$gemini.content.generate("Long prompt..."; "gemini-2.0-flash-exp")

If ($result.success)
    var $usage:=$result.usage

    ALERT("Prompt tokens: "+String($usage.promptTokenCount))
    ALERT("Response tokens: "+String($usage.candidatesTokenCount))
    ALERT("Total tokens: "+String($usage.totalTokenCount))
End if
```

### Handle Finish Reasons

```4d
var $result:=$gemini.content.generate("Write a very long story"; "gemini-2.0-flash-exp")

If ($result.success)
    var $candidate:=$result.candidate

    Case of
        : ($candidate.finishReason="STOP")
            ALERT("Completed normally")
        : ($candidate.finishReason="MAX_TOKENS")
            ALERT("Hit token limit")
        : ($candidate.finishReason="SAFETY")
            ALERT("Stopped due to safety")
        : ($candidate.finishReason="RECITATION")
            ALERT("Stopped due to recitation")
        : ($candidate.finishReason="OTHER")
            ALERT("Stopped for other reason")
    End case
End if
```

### Extract Parts

```4d
var $result:=$gemini.content.generate("Analyze this"; "gemini-2.0-flash-exp")

If ($result.success)
    var $content:=$result.candidate.content

    For each ($part; $content.parts)
        If (Length($part.text)>0)
            ALERT("Text: "+$part.text)
        End if

        If ($part.functionCall#Null)
            ALERT("Function call: "+$part.functionCall.name)
        End if
    End for each
End if
```

### Handle Blocked Content

```4d
var $result:=$gemini.content.generate("Risky prompt"; "gemini-2.0-flash-exp")

If ($result.success)
    If ($result.candidates.length=0)
        // No candidates - check prompt feedback
        If ($result.promptFeedback.blockReason#Null)
            ALERT("Content blocked: "+$result.promptFeedback.blockReason)
        End if
    Else
        // Process candidates
        ALERT($result.candidate.text)
    End if
End if
```

### Function Calling Response

```4d
// After sending prompt with tools
var $result:=$gemini.content.generate("What's the weather?"; "gemini-2.0-flash-exp"; $paramsWithTools)

If ($result.success)
    var $part:=$result.candidate.content.parts[0]

    If ($part.functionCall#Null)
        var $funcName:=$part.functionCall.name
        var $funcArgs:=$part.functionCall.args

        ALERT("Call function: "+$funcName)
        ALERT("Args: "+JSON Stringify($funcArgs))

        // Execute function and send result back
    End if
End if
```

### Token Counting

```4d
var $prompts:=["Short"; "Medium length prompt"; "Very long prompt with lots of text..."]

For each ($prompt; $prompts)
    var $result:=$gemini.content.generate($prompt; "gemini-2.0-flash-exp")

    If ($result.success)
        ALERT($prompt+": "+String($result.usage.totalTokenCount)+" tokens")
    End if
End for each
```

## Candidate Properties

Each candidate in the `candidates` collection contains:
- `content` - GeminiContent with parts
- `text` - Convenience property for first text part
- `finishReason` - Why generation stopped
- `safetyRatings` - Safety assessment
- `citationMetadata` - Citation information
- `tokenCount` - Tokens in this candidate
- `index` - Candidate index

## Finish Reasons

- `STOP` - Natural completion
- `MAX_TOKENS` - Token limit reached
- `SAFETY` - Safety threshold triggered
- `RECITATION` - Recitation detected
- `OTHER` - Other reason

## Prompt Feedback Structure

```4d
{
    blockReason: "SAFETY",  // If blocked
    safetyRatings: [
        {
            category: "HARM_CATEGORY_HARASSMENT",
            probability: "LOW"
        }
    ]
}
```

## See Also

- [GeminiResult](GeminiResult.md) - Base result class
- [GeminiCandidate](GeminiCandidate.md) - Candidate structure
- [GeminiContent](GeminiContent.md) - Content structure
- [GeminiContentAPI](GeminiContentAPI.md) - Content generation API
