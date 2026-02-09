# RerankerResult

The `RerankerResult` class is designed to handle the response from HTTP requests and provides functions to evaluate the success of the rerank request.

## Computed properties

| Property    | Type       | Description                                                                 |
|-------------|------------|-----------------------------------------------------------------------------|
| `results`   | Collecion   | Returns a collection of `result` objects.   |

### result

Each element of the `results` property is an object with the following properties:

| Field       | Type   | Description                                      |
|-------------|--------|--------------------------------------------------|
|`index`|Integer|The `0`-based position index in the original list of documents submitted for reranking. 
|`relevance_score`|Real|A score between `0` and `1` inclusive. A score closer to `1` indicates a high relevance to the query. A score closer to `0` indicates a low relevance to the query. 
