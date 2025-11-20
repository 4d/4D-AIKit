# GeminiEmbeddingsAPI

## Description

API for creating text embeddings using Gemini models. Embeddings convert text into numerical vectors that can be used for semantic search, clustering, and similarity comparisons.

## Access

```4d
var $gemini:=cs.Gemini.new($apiKey)
var $embeddingsAPI:=$gemini.embeddings
```

## Functions

### create()

**create**(*content* : Variant ; *model* : Text ; *parameters* : GeminiEmbeddingsParameters) : GeminiEmbeddingsResult

| Parameter       | Type                        | Description                                |
|-----------------|-----------------------------|--------------------------------------------|
| *content*       | Text or Object              | The text content to embed                  |
| *model*         | Text                        | Model name (e.g., "text-embedding-004")    |
| *parameters*    | GeminiEmbeddingsParameters  | Optional embedding parameters              |
| Function result | GeminiEmbeddingsResult      | The embedding result                       |

Creates an embedding vector from the input content.

#### Example Usage

```4d
var $gemini:=cs.Gemini.new($apiKey)

var $result:=$gemini.embeddings.create("Text to embed"; "text-embedding-004")

If ($result.success)
    var $vector:=$result.vector  // 4D.Vector
    ALERT("Embedding dimension: "+String($vector.length))
End if
```

## Examples

### Basic Embedding

```4d
var $gemini:=cs.Gemini.new($apiKey)

var $result:=$gemini.embeddings.create("Machine learning is fascinating"; "text-embedding-004")

If ($result.success)
    var $embedding:=$result.embedding
    var $values:=$embedding.values  // 4D.Vector

    // Use the embedding for similarity search, clustering, etc.
    ALERT("Created embedding with "+String($values.length)+" dimensions")
End if
```

### With Task Type

```4d
var $params:=cs.GeminiEmbeddingsParameters.new()
$params.taskType:="RETRIEVAL_QUERY"  // Optimize for search queries

var $result:=$gemini.embeddings.create("What is quantum computing?"; "text-embedding-004"; $params)
```

### Document Embedding with Title

```4d
var $params:=cs.GeminiEmbeddingsParameters.new()
$params.taskType:="RETRIEVAL_DOCUMENT"
$params.title:="Introduction to AI"

var $result:=$gemini.embeddings.create("Artificial intelligence is..."; "text-embedding-004"; $params)
```

### Semantic Search Example

```4d
// Create embeddings for documents
var $docs:=["AI and machine learning"; "Cooking recipes"; "Sports news"]
var $docEmbeddings:=[]

var $params:=cs.GeminiEmbeddingsParameters.new()
$params.taskType:="RETRIEVAL_DOCUMENT"

For each ($doc; $docs)
    var $result:=$gemini.embeddings.create($doc; "text-embedding-004"; $params)
    If ($result.success)
        $docEmbeddings.push($result.vector)
    End if
End for each

// Create embedding for search query
$params.taskType:="RETRIEVAL_QUERY"
var $queryResult:=$gemini.embeddings.create("Tell me about AI"; "text-embedding-004"; $params)
var $queryVector:=$queryResult.vector

// Find most similar document using cosine similarity
var $similarities:=[]
For each ($docVector; $docEmbeddings)
    var $similarity:=$queryVector.dot($docVector) / ($queryVector.norm() * $docVector.norm())
    $similarities.push($similarity)
End for each
```

## Task Types

Available task types:
- `RETRIEVAL_QUERY` - For search queries
- `RETRIEVAL_DOCUMENT` - For documents to be searched
- `SEMANTIC_SIMILARITY` - For similarity comparisons
- `CLASSIFICATION` - For classification tasks
- `CLUSTERING` - For clustering tasks
- `QUESTION_ANSWERING` - For Q&A systems
- `FACT_VERIFICATION` - For fact-checking

## Available Models

- `text-embedding-004` - Latest embedding model (768 dimensions)

Use `$gemini.models.list()` to see all available models.

## Response Structure

The result contains:
- `embedding`: GeminiEmbedding object with the vector
- `vector`: Direct access to 4D.Vector (convenience property)
- `usage`: Token usage information

## Working with Vectors

```4d
var $result:=$gemini.embeddings.create("sample text"; "text-embedding-004")

If ($result.success)
    var $vector:=$result.vector  // 4D.Vector

    // Vector operations
    var $length:=$vector.length  // Dimension count
    var $norm:=$vector.norm()    // Vector magnitude

    // Similarity with another vector
    var $otherResult:=$gemini.embeddings.create("similar text"; "text-embedding-004")
    var $dotProduct:=$vector.dot($otherResult.vector)
    var $cosineSim:=$dotProduct / ($vector.norm() * $otherResult.vector.norm())
End if
```

## Error Handling

```4d
var $result:=$gemini.embeddings.create(""; "text-embedding-004")

If (Not($result.success))
    For each ($error; $result.errors)
        ALERT($error.message)
    End for each
End if
```

## See Also

- [Gemini](Gemini.md) - Main client class
- [GeminiEmbeddingsParameters](GeminiEmbeddingsParameters.md) - Embedding parameters
- [GeminiEmbeddingsResult](GeminiEmbeddingsResult.md) - Result structure
- [GeminiEmbedding](GeminiEmbedding.md) - Embedding data
