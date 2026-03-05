# Reranker

Reranking is a technique that improves search quality by reordering an initial set of retrieved documents according to their relevance to a query. While a first-stage retrieval (e.g. vector similarity search) is fast, it can return documents that are only loosely related. A reranker applies a more powerful model to rescore and reorder these candidates, placing the most relevant documents first.

Reranking is commonly used as the second stage of a **Retrieval-Augmented Generation (RAG)** pipeline:

1. **Retrieve** a broad set of candidate documents (e.g. top 20 from a vector store).
2. **Rerank** the candidates to surface the most relevant ones (e.g. keep top 3).
3. **Generate** a response using only the top-ranked documents as context.

This two-stage approach balances speed (fast retrieval) with accuracy (precise reranking), reducing noise in the LLM context and improving answer quality.

The `Reranker` class is the main entry point for all reranking operations. It supports three different reranking strategies through a unified `create()` interface:

| Strategy | Type | Handler | Description |
|----------|------|---------|-------------|
| API-based | `cohere`, `jina`, `voyage`, `pinecone`, ... | [RerankerAPI](RerankerAPI.md) | Uses a dedicated `/rerank` endpoint. Fast, returns relevance scores. |
| Listwise LLM | `rankgpt` | [RerankerRankGPTAPI](RerankerRankGPTAPI.md) | Uses an LLM via chat/completions to rank documents by relative ordering. No scores. |
| Binary LLM filter | `llm-filter` | [RerankerLLMFilterAPI](RerankerLLMFilterAPI.md) | Uses an LLM via chat/completions to classify each document as RELEVANT or NOT_RELEVANT. |

## Constructor

**Reranker**(*config* : Object) : cs.AIKit.Reranker

Creates a new Reranker instance.

| Parameter | Type | Description |
|-----------|------|-------------|
| *config* | Object | Configuration object (see below) or an existing `cs.AIKit.OpenAI` instance. |

### Configuration Properties

| Property | Type | Description | Optional |
|----------|------|-------------|----------|
| `type` | Text | Reranker type (see table above). Auto-detected from `baseURL` for well-known providers. | Yes |
| `apiKey` | Text | API key for the reranker service. | Yes |
| `baseURL` | Text | Base URL for API requests. Auto-resolved from `type` for well-known providers. | Yes |

When `type` is omitted but `baseURL` is provided, the type is auto-detected from the domain (e.g. `api.cohere.ai` resolves to type `cohere`). When `type` is provided without `baseURL`, the base URL is resolved from a built-in table of well-known providers. Credentials can also be resolved from [OpenAIProviders](OpenAIProviders.md) when a matching provider name exists.

### Constructor Examples

#### With a well-known provider (type auto-detected from URL)

```4d
var $reranker:=cs.AIKit.Reranker.new({apiKey: "sk-..."; baseURL: "https://api.cohere.ai/v1"})
// type is auto-detected as "cohere"
```

#### With type only (baseURL auto-resolved)

```4d
var $reranker:=cs.AIKit.Reranker.new({type: "jina"; apiKey: "jina_..."})
// baseURL is auto-resolved to "https://api.jina.ai/v1"
```

#### With a local inference server

```4d
var $reranker:=cs.AIKit.Reranker.new({type: "text-embeddings-inference"; \
    baseURL: "http://127.0.0.1:8080/v1"})
```

#### With an existing OpenAI client

```4d
var $client:=cs.AIKit.OpenAI.new({apiKey: "sk-..."; baseURL: "https://api.cohere.ai/v1"})
var $reranker:=cs.AIKit.Reranker.new($client)
```

#### LLM-based reranking (RankGPT)

```4d
var $reranker:=cs.AIKit.Reranker.new({type: "rankgpt"; apiKey: "sk-..."; \
    baseURL: "https://api.openai.com/v1"})
```

#### LLM-based binary filter

```4d
var $reranker:=cs.AIKit.Reranker.new({type: "llm-filter"; apiKey: "sk-..."; \
    baseURL: "https://api.openai.com/v1"})
```

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `type` | Text | The resolved reranker type. |

## Functions

### create()

**create**(*query* : [RerankerQuery](RerankerQuery.md) ; *parameters* : [RerankerParameters](RerankerParameters.md)) : [RerankerResult](RerankerResult.md)

Reranks documents according to their relevance to a query.

| Parameter | Type | Description |
|-----------|------|-------------|
| *query* | [RerankerQuery](RerankerQuery.md) | The search query and the collection of documents to rerank. |
| *parameters* | [RerankerParameters](RerankerParameters.md) | The model name and optional `top_n` limit. |
| Function result | [RerankerResult](RerankerResult.md) | The reranked results with scores and/or ranks. |

The `model` parameter supports the `provider:model` syntax (e.g. `"cohere:rerank-english-v3.0"`). When used, the provider's credentials and base URL are resolved automatically from [OpenAIProviders](OpenAIProviders.md), allowing a single Reranker instance to dispatch to different backends per call.

#### Example: API-based reranking

```4d
var $reranker:=cs.AIKit.Reranker.new({type: "cohere"; apiKey: "..."})

var $query:=cs.AIKit.RerankerQuery.new({\
    query: "How do neural networks learn?"; \
    documents: [\
        "Neural networks learn by adjusting weights through backpropagation."; \
        "The weather forecast predicts rain tomorrow."; \
        "Gradient descent optimizes the loss function during training."\
    ]})

var $params:=cs.AIKit.RerankerParameters.new({model: "rerank-english-v3.0"; top_n: 2})
var $result:=$reranker.create($query; $params)

If ($result.success)
    For each ($item; $result.results)
        // $item.index : original document position (0-based)
        // $item.relevance_score : 0.0 to 1.0
    End for each
End if
```

#### Example: RAG pipeline with reranking

```4d
// 1. Retrieve candidates from a vector store (pseudo-code)
var $candidates:=$vectorStore.search("How do neural networks learn?"; 20)

// 2. Rerank the candidates
var $reranker:=cs.AIKit.Reranker.new({type: "cohere"; apiKey: "..."})
var $query:=cs.AIKit.RerankerQuery.new({query: "How do neural networks learn?"; \
    documents: $candidates})
var $params:=cs.AIKit.RerankerParameters.new({model: "rerank-english-v3.0"; top_n: 3})
var $ranked:=$reranker.create($query; $params)

// 3. Build context from top results and generate with an LLM
var $context:=""
For each ($item; $ranked.results)
    $context:=$context+$candidates[$item.index]+"\n"
End for each

var $client:=cs.AIKit.OpenAI.new()
var $chatHelper:=$client.chat.create("Answer using only the provided context.\n\n"+$context)
var $answer:=$chatHelper.prompt("How do neural networks learn?")
```

## See also

- [RerankerQuery](RerankerQuery.md) - Query and documents input
- [RerankerParameters](RerankerParameters.md) - Model and top_n configuration
- [RerankerResult](RerankerResult.md) - Result with scores and ranks
- [RerankerAPI](RerankerAPI.md) - API-based reranking (dedicated `/rerank` endpoint)
- [RerankerRankGPTAPI](RerankerRankGPTAPI.md) - LLM-based listwise ranking
- [RerankerLLMFilterAPI](RerankerLLMFilterAPI.md) - LLM-based binary relevance filter
