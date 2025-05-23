# OpenAIEmbeddingsAPI

The `OpenAIEmbeddingsAPI` provides functionalities to create embeddings using OpenAI's API.

https://platform.openai.com/docs/api-reference/embeddings

## Functions

### create()

**create**(*input* : Text; *model*: Text; *parameters* : OpenAIEmbeddingsParameters) : OpenAIEmbeddingsResult

Creates an embeddings for the provided input, model and parameters.

| Argument   | Type                                  | Description                                      |
|------------|---------------------------------------|--------------------------------------------------|
| *input*    | Text or Collection of Text           | The input to vectorize.              |
| *model*    | Text                                 | The model.                |
| *parameters* | [OpenAIEmbeddingsParameters](OpenAIEmbeddingsParameters.md) | The parameters to customize the embeddings request. |
| Function result| [OpenAIEmbeddingsResult](OpenAIEmbeddingsResult.md) | The embeddings.  |

#### Example Usage

```4d
var $result:=$client.embedding.create("some data"; "text-embedding-ada-002")
var $vector: 4D.Vector:=$result.vector
// or var $embedding: cs.AIKit.OpenAIEmbedding:=$result.embedding
```
