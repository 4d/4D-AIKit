# _Reranker

The `_Reranker` internal class provides utility functions for reranking. 

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
