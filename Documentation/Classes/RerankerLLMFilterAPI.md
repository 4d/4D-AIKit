# RerankerLLMFilterAPI

The `RerankerLLMFilterAPI` class implements binary relevance filtering using an LLM through the chat/completions endpoint. For each document, the LLM evaluates whether it is `RELEVANT` or `NOT_RELEVANT` to the query, producing a binary score of `1` or `0`.

This approach is useful when you need to filter out irrelevant documents rather than produce a fine-grained ranking.

### How it works

1. All documents are formatted as XML blocks (`<document id=0>text</document>`) in a single user message, along with the query wrapped in `<query>` tags.
2. An instruction prompt asks the LLM to evaluate each document's relevance and respond with `RELEVANT` or `NOT_RELEVANT` inside `<answer>` tags.
3. The response is parsed to extract per-document decisions. Documents not mentioned in the response default to `NOT_RELEVANT` (score `0`).
4. Results are sorted with `RELEVANT` documents first (score `1`), followed by `NOT_RELEVANT` documents (score `0`), preserving original order within each group. Each result receives a `rank` (1-based).

### When to use LLM Filter

- You want a simple relevant/not-relevant classification rather than a continuous score.
- You are filtering a large candidate set and only need to keep relevant documents.
- You want to use an existing LLM without a dedicated reranking endpoint.
- Partially relevant documents should be kept (the LLM is instructed to label them as `RELEVANT`).

## Functions

### create()

**create**(*query* : [RerankerQuery](RerankerQuery.md) ; *parameters* : [RerankerParameters](RerankerParameters.md)) : [RerankerResult](RerankerResult.md)

Classifies each document as RELEVANT or NOT_RELEVANT using an LLM.

| Parameter | Type | Description |
|-----------|------|-------------|
| *query* | [RerankerQuery](RerankerQuery.md) | The search query and documents to evaluate. |
| *parameters* | [RerankerParameters](RerankerParameters.md) | The LLM model to use. Default: `gpt-4o-mini`. |
| Function result | [RerankerResult](RerankerResult.md) | Results with `index`, `rank`, and `relevance_score` (`1` or `0`). |

#### Example

```4d
var $reranker:=cs.AIKit.Reranker.new({type: "llm-filter"; apiKey: "sk-..."; \
    baseURL: "https://api.openai.com/v1"})

var $query:=cs.AIKit.RerankerQuery.new({\
    query: "How do neural networks learn?"; \
    documents: [\
        "Neural networks learn by adjusting weights."; \
        "The cat sat on the mat."; \
        "Backpropagation computes gradients for learning."\
    ]})

var $params:=cs.AIKit.RerankerParameters.new({model: "gpt-4o-mini"})
var $result:=$reranker.create($query; $params)

If ($result.success)
    For each ($item; $result.results)
        // $item.index : original document position (0-based)
        // $item.relevance_score : 1 (RELEVANT) or 0 (NOT_RELEVANT)
        // $item.rank : 1, 2, 3, ...
    End for each
End if
```

#### Example: Filtering before RAG generation

```4d
var $reranker:=cs.AIKit.Reranker.new({type: "llm-filter"; apiKey: "sk-...";\
    baseURL: "https://api.openai.com/v1"})

var $candidates:=["doc about neural nets"; "doc about cooking"; "doc about gradient descent"]
var $query:=cs.AIKit.RerankerQuery.new({query: "How do neural networks learn?"; \
    documents: $candidates})
var $result:=$reranker.create($query; cs.AIKit.RerankerParameters.new({model: "gpt-4o-mini"}))

// Keep only RELEVANT documents
var $relevant:=$result.results.query("relevance_score = :1"; 1)
var $context:=""
For each ($item; $relevant)
    $context:=$context+$candidates[$item.index]+"\n"
End for each
```

## See also

- [Reranker](Reranker.md) - Main entry point and constructor
- [RerankerAPI](RerankerAPI.md) - API-based reranking (faster, with continuous scores)
- [RerankerRankGPTAPI](RerankerRankGPTAPI.md) - LLM-based listwise ranking
- [RerankerQuery](RerankerQuery.md) - Query and documents input
- [RerankerParameters](RerankerParameters.md) - Model and top_n configuration
- [RerankerResult](RerankerResult.md) - Result with scores and ranks
