# RerankerAPI

The `RerankerAPI` class handles reranking through dedicated `/rerank` API endpoints. This is the default and most common reranking strategy, used by providers such as Cohere, Jina, Voyage, Pinecone, Mixedbread, and others.

API-based reranking sends documents and a query to a specialized endpoint that returns relevance scores for each document. This is typically faster and cheaper than LLM-based approaches ([RerankerRankGPTAPI](RerankerRankGPTAPI.md), [RerankerLLMFilterAPI](RerankerLLMFilterAPI.md)) since the reranking model is purpose-built for this task.

The handler automatically adapts the request and response format to each provider's API conventions (endpoint path, field names, authentication method).

## Supported Types

| Type | Base URL | Endpoint | Notes |
|------|----------|----------|-------|
| `cohere` | `https://api.cohere.ai/v1` | `/rerank` | Default format. Returns `relevance_score`. |
| `jina` | `https://api.jina.ai/v1` | `/rerank` | Same format as Cohere. |
| `voyage` | `https://api.voyageai.com/v1` | `/rerank` | Uses `top_k` instead of `top_n`. Results in `data` key. |
| `mixedbread.ai` | `https://api.mixedbread.ai/v1` | `/reranking` | Uses `input` for documents, `top_k`, results in `data` with `score`. |
| `pinecone` | `https://api.pinecone.io` | `/rerank` | Documents wrapped as `{text: "..."}` objects. Uses `Api-Key` header. |
| `isaacus` | `https://api.isaacus.com/v1` | `/rerankings` | Uses `texts` for documents, `score` key. |
| `text-embeddings-inference` | User-defined (local) | `/rerank` | Uses `texts` for documents. Returns flat array. |
| `""` (empty) | User-defined | `/rerank` | Default Cohere-like format. Use for compatible servers. |

For well-known providers, the `type` is auto-detected from the `baseURL` domain, and the `baseURL` is auto-resolved from the `type`. See [Reranker](Reranker.md) for details.

## Functions

### create()

**create**(*query* : [RerankerQuery](RerankerQuery.md) ; *parameters* : [RerankerParameters](RerankerParameters.md)) : [RerankerResult](RerankerResult.md)

Sends documents and query to the provider's rerank endpoint and returns scored results.

| Parameter | Type | Description |
|-----------|------|-------------|
| *query* | [RerankerQuery](RerankerQuery.md) | The search query and a collection of texts to compare against the query. |
| *parameters* | [RerankerParameters](RerankerParameters.md) | The model name and maximum number of results to return. |
| Function result | [RerankerResult](RerankerResult.md) | The reranked results with relevance scores. |

#### Example: Remote provider (Cohere)

```4d
var $reranker:=cs.AIKit.Reranker.new({type: "cohere"; apiKey: "..."})

var $query:=cs.AIKit.RerankerQuery.new({\
    query: "What is deep learning?"; \
    documents: [\
        "Deep learning is a subset of machine learning based on artificial neural networks."; \
        "Apples are red and sweet fruits that grow on trees."; \
        "The theory of relativity was developed by Albert Einstein."; \
        "Neural networks simulate the human brain to solve complex problems."\
    ]})

var $params:=cs.AIKit.RerankerParameters.new({model: "rerank-english-v3.0"; top_n: 3})
var $result:=$reranker.create($query; $params)
```

#### Example: Remote provider (Jina)

```4d
var $reranker:=cs.AIKit.Reranker.new({type: "jina"; apiKey: "jina_..."})

var $query:=cs.AIKit.RerankerQuery.new({query: "What is deep learning?"; \
    documents: ["Deep learning uses neural networks."; "The sky is blue."]})

var $params:=cs.AIKit.RerankerParameters.new({model: "jina-reranker-v2-base-multilingual"})
var $result:=$reranker.create($query; $params)
```

#### Example: Local server (HuggingFace Text Embeddings Inference)

[Text Embeddings Inference (TEI)](https://huggingface.co/docs/text-embeddings-inference) is an open-source server that supports reranking with cross-encoder models locally.

```4d
// Start TEI locally:
// docker run -p 8080:80 ghcr.io/huggingface/text-embeddings-inference:latest \
//   --model-id BAAI/bge-reranker-base

var $reranker:=cs.AIKit.Reranker.new({type: "text-embeddings-inference"; \
    baseURL: "http://127.0.0.1:8080/v1"})

var $query:=cs.AIKit.RerankerQuery.new({query: "What is deep learning?"; \
    documents: ["Deep learning uses neural networks."; "The sky is blue."]})

var $params:=cs.AIKit.RerankerParameters.new({top_n: 2})
var $result:=$reranker.create($query; $params)
```

#### Example: Local server (llama-server)

```4d
// Start llama-server with a reranker model:
// llama-server -m bge-reranker-v2-m3.gguf --port 8080 --reranking

var $reranker:=cs.AIKit.Reranker.new({baseURL: "http://127.0.0.1:8080/v1"})

var $query:=cs.AIKit.RerankerQuery.new({query: "What is deep learning?"; \
    documents: ["Deep learning uses neural networks."; "The sky is blue."]})

var $result:=$reranker.create($query; cs.AIKit.RerankerParameters.new({top_n: 2}))
```

> Some local servers (e.g. `llama-server`) return raw logits instead of normalized scores. The [RerankerResult](RerankerResult.md) class automatically applies sigmoid normalization when scores fall outside the `[0, 1]` range.

## See also

- [Reranker](Reranker.md) - Main entry point and constructor
- [RerankerRankGPTAPI](RerankerRankGPTAPI.md) - LLM-based listwise ranking (alternative strategy)
- [RerankerLLMFilterAPI](RerankerLLMFilterAPI.md) - LLM-based binary relevance filter (alternative strategy)
- [RerankerQuery](RerankerQuery.md) - Query and documents input
- [RerankerParameters](RerankerParameters.md) - Model and top_n configuration
- [RerankerResult](RerankerResult.md) - Result with scores and ranks
