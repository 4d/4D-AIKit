# RerankerParameters

The `RerankerParameters` class is designed to configure and manage the parameters used for reranking through the proprietary `/rerank` API. 

## Properties

| Property Name      | Type    | Description                                                                                      |
|--------------------|---------|--------------------------------------------------------------------------------------------------|
| `model`  | Text    | The model used to rerank documents against a query. |
| `top_n`  | Integer    | The maximum number of rerank results to return. (default: `3`)    |
