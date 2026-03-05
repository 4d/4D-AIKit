# RerankerRankGPTAPI

The `RerankerRankGPTAPI` class implements listwise reranking using an LLM through the chat/completions endpoint. The LLM receives all documents in a multi-turn conversation and outputs a ranking permutation (e.g. `[3] > [1] > [2]`).

This strategy does not require a dedicated reranking model or endpoint. Any LLM accessible via the OpenAI-compatible chat/completions API can be used (e.g. GPT-4o-mini, Claude, Mistral, or a local model). The trade-off is that it is slower and more expensive than [API-based reranking](RerankerAPI.md), but it works with any chat LLM.

### How it works

1. A multi-turn conversation is constructed: a system message introduces the LLM as "RankGPT", followed by user/assistant message pairs presenting each document with a numbered identifier (`[1]`, `[2]`, ...).
2. A final user message asks the LLM to rank the documents in descending relevance order using the format `[1] > [3] > [2]`.
3. The response is parsed to extract the ranking permutation. Documents not mentioned by the LLM are appended at the end in their original order.
4. Results contain `index` (0-based original position) and `rank` (1-based rank) but no `relevance_score`, since the LLM only provides relative ordering.

Documents longer than 300 words are automatically truncated to keep the prompt within reasonable token limits.

### When to use RankGPT

- You do not have access to a dedicated reranking API (Cohere, Jina, etc.).
- You want to leverage an existing LLM (e.g. your OpenAI key) for reranking without additional services.
- You need relative ordering rather than absolute relevance scores.

## Functions

### create()

**create**(*query* : [RerankerQuery](RerankerQuery.md) ; *parameters* : [RerankerParameters](RerankerParameters.md)) : [RerankerResult](RerankerResult.md)

Reranks documents by asking an LLM to produce a ranking permutation.

| Parameter | Type | Description |
|-----------|------|-------------|
| *query* | [RerankerQuery](RerankerQuery.md) | The search query and documents to rerank. |
| *parameters* | [RerankerParameters](RerankerParameters.md) | The LLM model to use. Default: `gpt-4o-mini`. |
| Function result | [RerankerResult](RerankerResult.md) | Results with `index` and `rank` (no `relevance_score`). |

#### Example

```4d
var $reranker:=cs.AIKit.Reranker.new({type: "rankgpt"; apiKey: "sk-..."; \
    baseURL: "https://api.openai.com/v1"})

var $query:=cs.AIKit.RerankerQuery.new({\
    query: "How do neural networks learn?"; \
    documents: [\
        "Deep learning uses neural networks for learning."; \
        "The weather forecast shows rain tomorrow."; \
        "Backpropagation updates weights to minimize loss."\
    ]})

var $params:=cs.AIKit.RerankerParameters.new({model: "gpt-4o-mini"})
var $result:=$reranker.create($query; $params)

If ($result.success)
    For each ($item; $result.results)
        // $item.index : original document position (0-based)
        // $item.rank : 1, 2, 3, ...
        // $item.relevance_score : Null (not available for RankGPT)
    End for each
End if
```

#### Example: Using a local LLM

```4d
var $reranker:=cs.AIKit.Reranker.new({type: "rankgpt"; \
    baseURL: "http://127.0.0.1:8080/v1"})

var $query:=cs.AIKit.RerankerQuery.new({query: "What is AI?"; \
    documents: ["AI is artificial intelligence."; "The sun is a star."]})

var $result:=$reranker.create($query; cs.AIKit.RerankerParameters.new())
```

## See also

- [Reranker](Reranker.md) - Main entry point and constructor
- [RerankerAPI](RerankerAPI.md) - API-based reranking (faster, with scores)
- [RerankerLLMFilterAPI](RerankerLLMFilterAPI.md) - LLM-based binary relevance filter
- [RerankerQuery](RerankerQuery.md) - Query and documents input
- [RerankerParameters](RerankerParameters.md) - Model and top_n configuration
- [RerankerResult](RerankerResult.md) - Result with scores and ranks
