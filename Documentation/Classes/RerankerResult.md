# RerankerResult

The `RerankerResult` class is designed to handle the response from HTTP requests and provides functions to evaluate the success of the rerank request.

## Functions

### sigmoid

Takes any real number as input and "squashes" it into a range between `0` and `1`.

| Argument | Type | Description |
|----------|------|-------------|
| $x     | Real | The value to squash. |

**Returns**: Real between `0` and `1`.

```4d
ASSERT(0.5=cs._Reranker.new().sigmoid(0))
```
