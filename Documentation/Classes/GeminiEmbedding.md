# GeminiEmbedding

## Description

Represents an embedding vector. Contains the numerical vector values that represent the semantic meaning of text.

## Properties

| Property | Type      | Description                  |
|----------|-----------|------------------------------|
| values   | 4D.Vector | The embedding vector values  |

## Constructor

```4d
$embedding:=cs.GeminiEmbedding.new($object)
```

## Examples

### Access Vector

```4d
var $result:=$gemini.embeddings.create("Sample text"; "text-embedding-004")

If ($result.success)
    var $embedding:=$result.embedding
    var $vector:=$embedding.values

    ALERT("Dimension: "+String($vector.length))
    ALERT("First value: "+String($vector[0]))
End if
```

### Vector Operations

```4d
var $result:=$gemini.embeddings.create("Text"; "text-embedding-004")

If ($result.success)
    var $vector:=$result.embedding.values

    // Vector magnitude
    var $magnitude:=$vector.norm()
    ALERT("Magnitude: "+String($magnitude))

    // Normalize
    var $normalized:=$vector.normalize()

    // Scale
    var $doubled:=$vector.multiply(2)
End if
```

### Compare Embeddings

```4d
var $text1:="I love coding"
var $text2:="Programming is fun"

var $result1:=$gemini.embeddings.create($text1; "text-embedding-004")
var $result2:=$gemini.embeddings.create($text2; "text-embedding-004")

If ($result1.success && $result2.success)
    var $vec1:=$result1.embedding.values
    var $vec2:=$result2.embedding.values

    // Cosine similarity
    var $similarity:=$vec1.dot($vec2) / ($vec1.norm() * $vec2.norm())

    ALERT("Similarity: "+String($similarity))
End if
```

### Store Embedding

```4d
var $result:=$gemini.embeddings.create("Document text"; "text-embedding-004")

If ($result.success)
    var $embedding:=$result.embedding

    // Convert to collection for storage
    var $values:=[]
    For ($i; 0; $embedding.values.length-1)
        $values.push($embedding.values[$i])
    End for

    // Store in database or file
    var $record:={text: "Document text"; embedding: $values}
End if
```

### Calculate Distance

```4d
var $result1:=$gemini.embeddings.create("Text A"; "text-embedding-004")
var $result2:=$gemini.embeddings.create("Text B"; "text-embedding-004")

If ($result1.success && $result2.success)
    var $v1:=$result1.embedding.values
    var $v2:=$result2.embedding.values

    // Euclidean distance
    var $diff:=$v1.subtract($v2)
    var $distance:=$diff.norm()

    ALERT("Distance: "+String($distance))
End if
```

### Find Nearest Neighbor

```4d
// Create document embeddings
var $docs:=["Doc A"; "Doc B"; "Doc C"]
var $embeddings:=[]

For each ($doc; $docs)
    var $result:=$gemini.embeddings.create($doc; "text-embedding-004")
    If ($result.success)
        $embeddings.push($result.embedding.values)
    End if
End for each

// Search query
var $queryResult:=$gemini.embeddings.create("Search term"; "text-embedding-004")

If ($queryResult.success)
    var $queryVec:=$queryResult.embedding.values

    // Find closest
    var $minDistance:=999999
    var $closestIndex:=-1

    For ($i; 0; $embeddings.length-1)
        var $distance:=$queryVec.subtract($embeddings[$i]).norm()

        If ($distance<$minDistance)
            $minDistance:=$distance
            $closestIndex:=$i
        End if
    End for

    ALERT("Closest: "+$docs[$closestIndex])
End if
```

### Vector Averaging

```4d
var $texts:=["Text 1"; "Text 2"; "Text 3"]
var $vectors:=[]

For each ($text; $texts)
    var $result:=$gemini.embeddings.create($text; "text-embedding-004")
    If ($result.success)
        $vectors.push($result.embedding.values)
    End if
End for each

// Average the vectors
var $avgVector:=$vectors[0]
For ($i; 1; $vectors.length-1)
    $avgVector:=$avgVector.add($vectors[$i])
End for
$avgVector:=$avgVector.multiply(1/$vectors.length)

ALERT("Average vector created")
```

## Vector Structure

Gemini embeddings are returned as:

```json
{
    "values": [0.123, 0.456, 0.789, ...]
}
```

The `values` property is converted to a 4D.Vector for convenient mathematical operations.

## Typical Dimensions

- `text-embedding-004`: 768 dimensions

## 4D.Vector Operations

Available operations on the `values` vector:

- `length` - Number of dimensions
- `norm()` - Vector magnitude
- `dot(vector)` - Dot product
- `add(vector)` - Vector addition
- `subtract(vector)` - Vector subtraction
- `multiply(scalar)` - Scalar multiplication
- `normalize()` - Unit vector
- `[index]` - Element access

## See Also

- [GeminiEmbeddingsResult](GeminiEmbeddingsResult.md) - Embeddings result
- [GeminiEmbeddingsAPI](GeminiEmbeddingsAPI.md) - Embeddings API
- [GeminiEmbeddingsParameters](GeminiEmbeddingsParameters.md) - Embedding parameters
