# GeminiEmbeddingsResult

## Description

Result object for embedding creation requests. Contains the embedding vector and usage information.

## Inherits

[GeminiResult](GeminiResult.md)

## Functions

### get embedding

**embedding** : cs.GeminiEmbedding

| Property        | Type            | Description                  |
|-----------------|-----------------|------------------------------|
| Function result | GeminiEmbedding | The embedding object         |

Returns the embedding object.

### get vector

**vector** : 4D.Vector

| Property        | Type      | Description                       |
|-----------------|-----------|-----------------------------------|
| Function result | 4D.Vector | The embedding vector (convenience)|

Returns the embedding vector directly.

## Examples

### Basic Usage

```4d
var $result:=$gemini.embeddings.create("Text to embed"; "text-embedding-004")

If ($result.success)
    var $vector:=$result.vector
    ALERT("Embedding dimension: "+String($vector.length))
End if
```

### Access Embedding Object

```4d
var $result:=$gemini.embeddings.create("Sample text"; "text-embedding-004")

If ($result.success)
    var $embedding:=$result.embedding
    var $values:=$embedding.values  // 4D.Vector

    ALERT("Vector length: "+String($values.length))
End if
```

### Calculate Similarity

```4d
var $text1:="I love programming"
var $text2:="Coding is fun"

var $result1:=$gemini.embeddings.create($text1; "text-embedding-004")
var $result2:=$gemini.embeddings.create($text2; "text-embedding-004")

If ($result1.success && $result2.success)
    var $vec1:=$result1.vector
    var $vec2:=$result2.vector

    // Cosine similarity
    var $dotProduct:=$vec1.dot($vec2)
    var $similarity:=$dotProduct / ($vec1.norm() * $vec2.norm())

    ALERT("Similarity: "+String($similarity))
End if
```

### Store Embeddings

```4d
var $documents:=["Doc 1"; "Doc 2"; "Doc 3"]
var $embeddings:=[]

For each ($doc; $documents)
    var $result:=$gemini.embeddings.create($doc; "text-embedding-004")

    If ($result.success)
        $embeddings.push({\
            text: $doc; \
            vector: $result.vector; \
            embedding: $result.embedding})
    End if
End for each

// Store in database or use for search
```

### Semantic Search

```4d
// Create document embeddings
var $docs:=["AI and machine learning"; "Cooking recipes"; "Sports news"]
var $docVectors:=[]

For each ($doc; $docs)
    var $result:=$gemini.embeddings.create($doc; "text-embedding-004")
    If ($result.success)
        $docVectors.push($result.vector)
    End if
End for each

// Search query
var $query:="Tell me about artificial intelligence"
var $queryResult:=$gemini.embeddings.create($query; "text-embedding-004")

If ($queryResult.success)
    var $queryVec:=$queryResult.vector

    // Find most similar document
    var $bestScore:=0
    var $bestIndex:=-1

    For ($i; 0; $docVectors.length-1)
        var $score:=$queryVec.dot($docVectors[$i]) / \
            ($queryVec.norm() * $docVectors[$i].norm())

        If ($score>$bestScore)
            $bestScore:=$score
            $bestIndex:=$i
        End if
    End for

    ALERT("Best match: "+$docs[$bestIndex]+" (score: "+String($bestScore)+")")
End if
```

### Vector Operations

```4d
var $result:=$gemini.embeddings.create("Example"; "text-embedding-004")

If ($result.success)
    var $vector:=$result.vector

    // Vector properties
    ALERT("Length: "+String($vector.length))
    ALERT("Norm: "+String($vector.norm()))

    // Vector operations
    var $doubled:=$vector.multiply(2)
    var $normalized:=$vector.normalize()

    // Element access
    var $firstValue:=$vector[0]
End if
```

### Check Usage

```4d
var $result:=$gemini.embeddings.create("Long text..."; "text-embedding-004")

If ($result.success)
    var $usage:=$result.usage

    If ($usage#Null)
        ALERT("Tokens used: "+String($usage.totalTokenCount))
    End if
End if
```

### Batch Embedding

```4d
var $texts:=["Text 1"; "Text 2"; "Text 3"]
var $results:=[]

For each ($text; $texts)
    var $result:=$gemini.embeddings.create($text; "text-embedding-004")

    If ($result.success)
        $results.push({\
            text: $text; \
            vector: $result.vector; \
            tokenCount: $result.usage.totalTokenCount})
    End if
End for each

ALERT("Created "+String($results.length)+" embeddings")
```

### Distance Calculations

```4d
var $result1:=$gemini.embeddings.create("Text A"; "text-embedding-004")
var $result2:=$gemini.embeddings.create("Text B"; "text-embedding-004")

If ($result1.success && $result2.success)
    var $v1:=$result1.vector
    var $v2:=$result2.vector

    // Euclidean distance
    var $diff:=$v1.subtract($v2)
    var $euclidean:=$diff.norm()

    // Cosine similarity
    var $cosine:=$v1.dot($v2) / ($v1.norm() * $v2.norm())

    // Manhattan distance
    var $manhattan:=0
    For ($i; 0; $v1.length-1)
        $manhattan+:=Abs($v1[$i]-$v2[$i])
    End for

    ALERT("Euclidean: "+String($euclidean))
    ALERT("Cosine: "+String($cosine))
    ALERT("Manhattan: "+String($manhattan))
End if
```

### Clustering Preparation

```4d
var $texts:=["Doc A"; "Doc B"; "Doc C"; "Doc D"]
var $vectors:=[]

For each ($text; $texts)
    var $result:=$gemini.embeddings.create($text; "text-embedding-004")
    If ($result.success)
        $vectors.push($result.vector)
    End if
End for each

// Use vectors in clustering algorithm (k-means, hierarchical, etc.)
```

## Vector Properties

The `vector` property is a 4D.Vector with:
- `length` - Number of dimensions (typically 768)
- `norm()` - Vector magnitude
- `dot(vector)` - Dot product
- `multiply(scalar)` - Scalar multiplication
- `add(vector)` - Vector addition
- `subtract(vector)` - Vector subtraction
- `normalize()` - Unit vector

## Common Vector Operations

### Cosine Similarity
```4d
$similarity:=$vec1.dot($vec2) / ($vec1.norm() * $vec2.norm())
```

### Euclidean Distance
```4d
$distance:=$vec1.subtract($vec2).norm()
```

### Normalization
```4d
$normalized:=$vec.normalize()
```

## See Also

- [GeminiResult](GeminiResult.md) - Base result class
- [GeminiEmbedding](GeminiEmbedding.md) - Embedding structure
- [GeminiEmbeddingsAPI](GeminiEmbeddingsAPI.md) - Embeddings API
- [GeminiEmbeddingsParameters](GeminiEmbeddingsParameters.md) - Embedding parameters
