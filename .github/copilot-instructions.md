
## Code

### New API resources

In OpenAI class is defined properties with all service. When implementing new one take example from existing services and follow the same structure.

Ex: `property embeddings : cs:C1710.OpenAIEmbeddingsAPI`

- OpenAIXXXAPI contains methods for interacting.
- OpenAIXXXParameters contains parameters for the API methods.
  - it contains python case parameters to follow json rules of api
- OpenAIXXXResult contains results for the API methods.
- OpenAIXXX could be the response object decoded in result

Follow exact api naming inspired from passed doc or website url or other language implementations.

## Documentation

please write documentation for the class. Inspire for other api resources. If OpenAIXXXResult, see another OpenAIXXXResult object to have same structure. table, talk about parent etc...

have correct links between same services class.