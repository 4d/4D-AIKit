# Reranker

The `Reranker` class provides a client for accessing the proprietary `/rerank` endpoint available in some providers and inference servers (not OpenAI). 

## Configuration Properties

| Property Name     | Type  | Description                       | Optional |
|-------------------|-------|-----------------------------------|----------|
| `apiKey`          | Text  | Your API Key.              | Can be required by the provider |
| `baseURL`         | Text  | Base URL for API requests. | No |
