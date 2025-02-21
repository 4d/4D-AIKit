# Asynchronous Call

If you do not want to wait for the OpenAPI response when making a request to its API, you need to use asynchronous code.

You must provide a `formula` to receive the result. See [OpenAIParameters](Classes/OpenAIParameters.md).

The asynchronous method is based on 4D HTTPRequest, so the response will be received within the current process.

> ⚠️ If your process ends at the conclusion of the current method (e.g., using New process, or playing in the method editor), the callback formula might not be called asynchronously. In such cases, consider using `CALL WORKER` or `CALL FORM`.

## Examples of Usage

```4d
$client.models.list({formula: Formula(MyReceiveMethod($1))})
```

`$1` will be an instance of [OpenAIResult](Classes/OpenAIResult.md) (specifically, in this example, [OpenAIModelResult](Classes/OpenAIModelResult.md)).


`MyReceiveMethod` method could be:

```4d
#DECLARE($result: cs.AIKit.OpenAIModelResult)

If($result.success)

   Form.models:=$result.models

Else

// Alert($result.errors.formula(Formula(JSON Stringify($1))).join("\n"))

End if
```