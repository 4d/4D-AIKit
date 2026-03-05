# RerankerParameters

The `RerankerParameters` class configures the parameters for a reranking request.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `model` | Text | - | The model to use for reranking. Supports `provider:model` syntax (e.g. `"cohere:rerank-english-v3.0"`) for cross-provider model resolution. |
| `top_n` | Integer | `3` | The maximum number of results to return. |

## Constructor

**RerankerParameters**(*config* : Object) : cs.AIKit.RerankerParameters

| Parameter | Type | Description |
|-----------|------|-------------|
| *config* | Object | Object with `model` (Text) and/or `top_n` (Integer) properties. |

### Examples

```4d
// Specify model and limit
var $params:=cs.AIKit.RerankerParameters.new({model: "rerank-english-v3.0"; top_n: 5})

// Default top_n (3), no specific model
var $params:=cs.AIKit.RerankerParameters.new({})

// Cross-provider model resolution
var $params:=cs.AIKit.RerankerParameters.new({model: "cohere:rerank-english-v3.0"})
```

## See also

- [Reranker](Reranker.md) - Main entry point
- [RerankerQuery](RerankerQuery.md) - Query and documents input
- [RerankerResult](RerankerResult.md) - Reranking results
