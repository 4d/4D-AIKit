# GeminiEmbeddingsParameters

## Description

Parameters for creating text embeddings. Allows specification of task type, title, and output dimensionality.

## Inherits

[GeminiParameters](GeminiParameters.md)

## Properties

| Property            | Type    | Description                                          |
|---------------------|---------|------------------------------------------------------|
| taskType            | Text    | Task type for optimized embeddings                   |
| title               | Text    | Title for RETRIEVAL_DOCUMENT tasks                  |
| outputDimensionality| Integer | Output dimension size (if supported by model)        |

## Constructor

```4d
$params:=cs.GeminiEmbeddingsParameters.new()
$params:=cs.GeminiEmbeddingsParameters.new($object)
```

## Examples

### Basic Usage

```4d
var $params:=cs.GeminiEmbeddingsParameters.new()
$params.taskType:="RETRIEVAL_QUERY"

var $result:=$gemini.embeddings.create("search query"; "text-embedding-004"; $params)
```

### Document Embedding with Title

```4d
var $params:=cs.GeminiEmbeddingsParameters.new()
$params.taskType:="RETRIEVAL_DOCUMENT"
$params.title:="Introduction to Machine Learning"

var $docText:="Machine learning is a subset of artificial intelligence..."
var $result:=$gemini.embeddings.create($docText; "text-embedding-004"; $params)
```

### Semantic Similarity

```4d
var $params:=cs.GeminiEmbeddingsParameters.new()
$params.taskType:="SEMANTIC_SIMILARITY"

var $text1:="I love programming"
var $text2:="Coding is fun"

var $result1:=$gemini.embeddings.create($text1; "text-embedding-004"; $params)
var $result2:=$gemini.embeddings.create($text2; "text-embedding-004"; $params)

// Compare similarity
var $similarity:=$result1.vector.dot($result2.vector) / \
    ($result1.vector.norm() * $result2.vector.norm())
ALERT("Similarity: "+String($similarity))
```

### Classification Task

```4d
var $params:=cs.GeminiEmbeddingsParameters.new()
$params.taskType:="CLASSIFICATION"

var $result:=$gemini.embeddings.create("This movie is amazing!"; "text-embedding-004"; $params)
```

### Clustering

```4d
var $params:=cs.GeminiEmbeddingsParameters.new()
$params.taskType:="CLUSTERING"

var $documents:=["Doc about AI"; "Doc about cooking"; "Doc about machine learning"]
var $embeddings:=[]

For each ($doc; $documents)
    var $result:=$gemini.embeddings.create($doc; "text-embedding-004"; $params)
    If ($result.success)
        $embeddings.push($result.vector)
    End if
End for each

// Use embeddings for clustering algorithm
```

### Custom Output Dimensionality

```4d
var $params:=cs.GeminiEmbeddingsParameters.new()
$params.outputDimensionality:=256  // Reduce from default 768

var $result:=$gemini.embeddings.create("text"; "text-embedding-004"; $params)
If ($result.success)
    ALERT("Embedding size: "+String($result.vector.length))  // 256
End if
```

### Question Answering

```4d
var $params:=cs.GeminiEmbeddingsParameters.new()
$params.taskType:="QUESTION_ANSWERING"

// Embed question
var $question:="What is the capital of France?"
var $questionEmb:=$gemini.embeddings.create($question; "text-embedding-004"; $params)

// Embed potential answers
$params.taskType:="RETRIEVAL_DOCUMENT"
var $answers:=["Paris is the capital"; "London is a city"; "Berlin is in Germany"]
var $answerEmbs:=[]

For each ($answer; $answers)
    var $result:=$gemini.embeddings.create($answer; "text-embedding-004"; $params)
    $answerEmbs.push($result.vector)
End for each

// Find best match
var $bestScore:=0
var $bestIndex:=0
For ($i; 0; $answerEmbs.length-1)
    var $score:=$questionEmb.vector.dot($answerEmbs[$i]) / \
        ($questionEmb.vector.norm() * $answerEmbs[$i].norm())
    If ($score>$bestScore)
        $bestScore:=$score
        $bestIndex:=$i
    End if
End for

ALERT("Best answer: "+$answers[$bestIndex])
```

### Fact Verification

```4d
var $params:=cs.GeminiEmbeddingsParameters.new()
$params.taskType:="FACT_VERIFICATION"

var $claim:="The Earth orbits around the Sun"
var $result:=$gemini.embeddings.create($claim; "text-embedding-004"; $params)
```

## Task Types

| Task Type              | Description                                      | Use Case                     |
|------------------------|--------------------------------------------------|------------------------------|
| TASK_TYPE_UNSPECIFIED  | Default, no specific optimization                | General purpose              |
| RETRIEVAL_QUERY        | Optimized for search queries                     | User search queries          |
| RETRIEVAL_DOCUMENT     | Optimized for documents to be searched           | Document corpus              |
| SEMANTIC_SIMILARITY    | Optimized for similarity comparisons             | Text comparison              |
| CLASSIFICATION         | Optimized for classification tasks               | Text categorization          |
| CLUSTERING             | Optimized for clustering                         | Grouping similar texts       |
| QUESTION_ANSWERING     | Optimized for Q&A systems                        | Questions and answers        |
| FACT_VERIFICATION      | Optimized for fact checking                      | Claim verification           |

## Best Practices

### For Search/Retrieval

```4d
// For queries
var $queryParams:=cs.GeminiEmbeddingsParameters.new()
$queryParams.taskType:="RETRIEVAL_QUERY"

// For documents
var $docParams:=cs.GeminiEmbeddingsParameters.new()
$docParams.taskType:="RETRIEVAL_DOCUMENT"
$docParams.title:="Document Title"
```

### For Similarity

```4d
var $params:=cs.GeminiEmbeddingsParameters.new()
$params.taskType:="SEMANTIC_SIMILARITY"
// Use same task type for both texts being compared
```

## Notes

- Task type optimization can improve embedding quality for specific use cases
- `title` is only applicable for `RETRIEVAL_DOCUMENT` task type
- `outputDimensionality` may not be supported by all models
- Use consistent task types when comparing embeddings

## See Also

- [GeminiParameters](GeminiParameters.md) - Base parameters class
- [GeminiEmbeddingsAPI](GeminiEmbeddingsAPI.md) - Embeddings API
- [GeminiEmbeddingsResult](GeminiEmbeddingsResult.md) - Result structure
- [GeminiEmbedding](GeminiEmbedding.md) - Embedding data
