# OpenAIEmbeddingsAPI

The `OpenAIEmbeddingsAPI` provides functionalities to create embeddings using OpenAI's API.

https://platform.openai.com/docs/api-reference/embeddings

## Functions

### create

Creates an embeddings for the provided input, model and parameters.

| Argument   | Type                                  | Description                                      |
|------------|---------------------------------------|--------------------------------------------------|
| `$input`    | Text or Collection of Text           | The input to vectorize.              |
| `$model`    | Text                                 | The model.                |
| `$parameters` | [OpenAIEmbeddingsParameters](OpenAIEmbeddingsParameters.md) | The parameters to customize the embeddings request. |

#### Returns: [OpenAIEmbeddingsResult](OpenAIEmbeddingsResult.md)

#### Example Usage

```4d
var $result:=$client.embedding.create("some data"; "text-embedding-ada-002")
var $embedding:=$result.embedding
```