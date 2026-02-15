# RerankerAPI

The `RerankerAPI` class provides functionalities for reranking using the proprietary `/rerank` API. 

## Functions

### create()

**create**(*query* : [RerankerQuery](RerankerQuery.md) ; *parameters* : [RerankerParameters](RerankerParameters.md)) : RerankerResult

| Parameter         | Type                                      | Description                               |
|-------------------|-------------------------------------------|-------------------------------------------|
| *query*        | [RerankerQuery](RerankerQuery.md) | The search query and a collection of texts that will be compared to the query. |
| *parameters*        | [RerankerParameters](RerankerParameters.md) | The model name and maximum number of rerank results to return. |

#### Example Usages

##### Rerank a collection of documents for a query and get the top `3` results

```4d
var $client:=cs.AIKit.Reranker.new({baseURL: "http://127.0.0.1:8080/v1"})

var $query:=cs.AIKit.RerankerQuery.new({query: "What is deep learning?"; documents: [\
"Deep learning is a subset of machine learning based on artificial neural networks."; \
"Apples are red and sweet fruits that grow on trees."; \
"The theory of relativity was developed by Albert Einstein."; \
"Neural networks simulate the human brain to solve complex problems."\
]})

var $parameters:=cs.AIKit.RerankerParameters.new({top_n: 3})

var $result:=$client.rerank.create($query; $parameters)
```
