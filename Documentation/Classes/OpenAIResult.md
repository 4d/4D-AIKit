# OpenAIResult

The `OpenAIResult` class is designed to handle the response from HTTP requests and provides functions to evaluate the success of the request, retrieve body content, and collect any errors that may have occurred during processing.

## Computed properties

### `success` 

A Boolean indicating whether the HTTP request was successful.

### `errors` 

Returns a collection of errors. These could be network errors or errors returned by OpenAI.

### `terminated` 

A Boolean indicating whether the HTTP request was terminated.

