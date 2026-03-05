# RerankerQuery

The `RerankerQuery` class represents the input for a reranking request: a search query and a collection of documents to rerank against it.

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `query` | Text | The search query. |
| `documents` | Collection | A collection of texts (or objects with a `text` property) to compare against the query. |

## Constructor

**RerankerQuery**(*config* : Object) : cs.AIKit.RerankerQuery

| Parameter | Type | Description |
|-----------|------|-------------|
| *config* | Object | Object with `query` (Text) and `documents` (Collection) properties. |

### Example

```4d
var $query:=cs.AIKit.RerankerQuery.new({\
    query: "How do neural networks learn?"; \
    documents: [\
        "Neural networks learn by adjusting weights."; \
        "The weather forecast shows rain tomorrow."; \
        "Backpropagation computes gradients for learning."\
    ]})
```

## See also

- [Reranker](Reranker.md) - Main entry point
- [RerankerParameters](RerankerParameters.md) - Model and top_n configuration
- [RerankerResult](RerankerResult.md) - Reranking results
