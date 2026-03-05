# RerankerResult

The `RerankerResult` class handles the response from a reranking request. It extends `OpenAIResult` and provides the `results` computed property to access reranked documents.

## Computed Properties

| Property | Type | Description |
|----------|------|-------------|
| `success` | Boolean | Whether the reranking request succeeded. |
| `results` | Collection | Collection of result objects, sorted by relevance. |

## Result Object

Each element of the `results` collection is an object with the following properties:

| Property | Type | Description |
|----------|------|-------------|
| `index` | Integer | The 0-based position in the original `documents` collection. |
| `relevance_score` | Real or Null | A relevance score. `0` to `1` for [RerankerAPI](RerankerAPI.md), `1` or `0` for [RerankerLLMFilterAPI](RerankerLLMFilterAPI.md), `Null` for [RerankerRankGPTAPI](RerankerRankGPTAPI.md). |
| `rank` | Integer | The 1-based rank in the reranked ordering (present for RankGPT and LLM filter results). |

### Score Normalization

The `results` property automatically normalizes scores:

- **Sigmoid normalization**: Some servers (e.g. `llama-server`) return raw logits instead of probabilities. If any score is greater than `1` or negative, all scores are transformed through a sigmoid function to bring them into the `[0, 1]` range.
- **Key mapping**: Providers that use `score` instead of `relevance_score` (Pinecone, Mixedbread, TEI, Isaacus) are automatically mapped to `relevance_score`.

### Example

```4d
var $result:=$reranker.create($query; $params)

If ($result.success)
    For each ($item; $result.results)
        var $originalDoc:=$documents[$item.index]
        var $score:=$item.relevance_score  // 0.0 to 1.0, or Null for RankGPT
    End for each
End if
```

## See also

- [Reranker](Reranker.md) - Main entry point
- [RerankerQuery](RerankerQuery.md) - Query and documents input
- [RerankerParameters](RerankerParameters.md) - Model and top_n configuration
- [RerankerAPI](RerankerAPI.md) - API-based reranking
- [RerankerRankGPTAPI](RerankerRankGPTAPI.md) - LLM-based listwise ranking
- [RerankerLLMFilterAPI](RerankerLLMFilterAPI.md) - LLM-based binary relevance filter
