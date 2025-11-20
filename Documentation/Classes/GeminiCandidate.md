# GeminiCandidate

## Description

Represents a single response candidate from content generation. Contains the generated content, finish reason, safety ratings, and metadata.

## Properties

| Property         | Type          | Description                          |
|------------------|---------------|--------------------------------------|
| content          | GeminiContent | Generated content                    |
| finishReason     | Text          | Why generation stopped               |
| safetyRatings    | Collection    | Safety assessment ratings            |
| citationMetadata | Object        | Citation sources                     |
| tokenCount       | Integer       | Number of tokens in this candidate   |
| index            | Integer       | Candidate index                      |

## Constructor

```4d
$candidate:=cs.GeminiCandidate.new($data)
```

## Functions

### get text

**text** : Text

| Property        | Type | Description                              |
|-----------------|------|------------------------------------------|
| Function result | Text | Text from first part (convenience method)|

Returns the text content from the first part.

## Examples

### Access Text Content

```4d
var $result:=$gemini.content.generate("Hello"; "gemini-2.0-flash-exp")

If ($result.success)
    var $candidate:=$result.candidate

    // Convenience property
    ALERT($candidate.text)

    // Or access parts directly
    ALERT($candidate.content.parts[0].text)
End if
```

### Check Finish Reason

```4d
var $result:=$gemini.content.generate("Write a very long story"; "gemini-2.0-flash-exp")

If ($result.success)
    var $candidate:=$result.candidate

    Case of
        : ($candidate.finishReason="STOP")
            ALERT("Completed normally")
        : ($candidate.finishReason="MAX_TOKENS")
            ALERT("Hit token limit - response may be incomplete")
        : ($candidate.finishReason="SAFETY")
            ALERT("Stopped due to safety concerns")
        : ($candidate.finishReason="RECITATION")
            ALERT("Stopped due to recitation detection")
    End case
End if
```

### Check Safety Ratings

```4d
var $result:=$gemini.content.generate("Your prompt"; "gemini-2.0-flash-exp")

If ($result.success)
    var $candidate:=$result.candidate

    For each ($rating; $candidate.safetyRatings)
        var $category:=$rating.category
        var $probability:=$rating.probability

        If ($probability="HIGH")
            ALERT("Warning: "+$category+" rated HIGH")
        End if
    End for each
End if
```

### Access Citation Metadata

```4d
var $result:=$gemini.content.generate("Tell me about Einstein"; "gemini-2.0-flash-exp")

If ($result.success)
    var $candidate:=$result.candidate

    If ($candidate.citationMetadata#Null)
        For each ($citation; $candidate.citationMetadata.citationSources)
            ALERT("Source: "+String($citation.uri))
            ALERT("Start: "+String($citation.startIndex))
            ALERT("End: "+String($citation.endIndex))
        End for each
    End if
End if
```

### Multiple Parts

```4d
var $result:=$gemini.content.generate("Prompt"; "gemini-2.0-flash-exp")

If ($result.success)
    var $candidate:=$result.candidate

    For each ($part; $candidate.content.parts)
        If (Length($part.text)>0)
            ALERT("Text part: "+$part.text)
        End if

        If ($part.functionCall#Null)
            ALERT("Function call: "+$part.functionCall.name)
        End if
    End for each
End if
```

### Check Token Count

```4d
var $result:=$gemini.content.generate("Long prompt..."; "gemini-2.0-flash-exp")

If ($result.success)
    var $candidate:=$result.candidate

    ALERT("Response tokens: "+String($candidate.tokenCount))
End if
```

### Handle Multiple Candidates

```4d
var $params:=cs.GeminiContentParameters.new()
$params.generationConfig:={candidateCount: 3}

var $result:=$gemini.content.generate("Write a joke"; "gemini-2.0-flash-exp"; $params)

If ($result.success)
    For each ($candidate; $result.candidates)
        ALERT("Candidate "+String($candidate.index)+":")
        ALERT($candidate.text)
        ALERT("Finish reason: "+$candidate.finishReason)
        ALERT("---")
    End for each
End if
```

### Filter by Finish Reason

```4d
var $result:=$gemini.content.generate("Prompt"; "gemini-2.0-flash-exp")

If ($result.success)
    // Get only candidates that completed normally
    var $completed:=[]

    For each ($candidate; $result.candidates)
        If ($candidate.finishReason="STOP")
            $completed.push($candidate)
        End if
    End for each

    ALERT("Completed candidates: "+String($completed.length))
End if
```

## Finish Reasons

| Reason       | Description                                      |
|--------------|--------------------------------------------------|
| STOP         | Natural completion point reached                 |
| MAX_TOKENS   | Maximum token limit reached                      |
| SAFETY       | Content flagged by safety filters                |
| RECITATION   | Recitation of training data detected             |
| OTHER        | Other reason                                     |

## Safety Rating Structure

Each safety rating contains:

```4d
{
    category: "HARM_CATEGORY_HARASSMENT",  // Category
    probability: "LOW"                     // Probability (NEGLIGIBLE, LOW, MEDIUM, HIGH)
}
```

## Safety Categories

- `HARM_CATEGORY_HARASSMENT`
- `HARM_CATEGORY_HATE_SPEECH`
- `HARM_CATEGORY_SEXUALLY_EXPLICIT`
- `HARM_CATEGORY_DANGEROUS_CONTENT`

## Citation Metadata Structure

```4d
{
    citationSources: [
        {
            startIndex: 0,
            endIndex: 100,
            uri: "https://example.com",
            license: "..."
        }
    ]
}
```

## See Also

- [GeminiContentResult](GeminiContentResult.md) - Content result
- [GeminiContent](GeminiContent.md) - Content structure
- [GeminiPart](GeminiPart.md) - Content parts
