# 4D-AIKit

[![language][code-shield]][code-url]

## Overview

4D AIKit is a built-in 4D component that allows you to interact with third-party AI API.

## OpenAI

The `OpenAI` class allows you to make request to the OpenAI API.

### Configuration

```4d
var $client:=cs.ai.OpenAI.new("your api key")
```

For provider compatible API you could configure the server url.

```4d
var $client:=cs.ai.OpenAI.new({apiKey: "your api key"; baseURL: "https://server.ai"})
```

### Chat

#### Completions

```4d
var $messages:=[{role: "system"; content: "You are a helpful assistant."}]
$messages.push({role: "user"; content: "Could you explain me why 42 is a special number"})
var $result:=$client.chat.completions.create($messages; {model: "gpt-4o-mini"})
// result in $result.choice
```

#### Chat helper

This helper allow to keep a list of user message, response from assistant.

```4d
var $helper:=$client.chat.create("You are a helpful assistant.")
var $result:=$helper.prompt("Could you explain me why 42 is a special number")
$result:=$helper.prompt("and could you decompose this number")
// conversation in $helper.messages
```

#### Vision helper

This helper allow to analyse an image using the chat.

```4d
var $result:=$client.chat.vision.create($imageUrl).prompt("give me a description of the image")
```

### Images

```4d
var $images:=$client.images.generate("A futuristic city skyline at sunset"; {size: "1024x1024"}).images
```

### Models

Get full list of models

```4d
var $models:=$client.models.list().models // you can then extract the `id`
```

Get one model information

```4d
var $model:=$client.models.retrieve("a model id").model
```

### Moderations

```4d
var $moderation:=$client.moderations.create("This text contains inappropriate language and offensive behavior.").moderation
```

## License

See the [LICENSE][license-url] file for details

## Contributing

See [CONTRIBUTING][contributing-url] guide.

## Copyright

- This library is not affiliated with, endorsed by, or officially connected to OpenAI in any way. 
- "OpenAI" and any related marks are trademarks or registered trademarks of OpenAI, LLC. All rights related to OpenAI's services, APIs, and technologies remain the property of OpenAI.
- This project simply provides an interface to OpenAI’s services and does not claim any ownership over their technology, branding, or intellectual property.

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[code-shield]: https://img.shields.io/static/v1?label=language&message=4d&color=blue
[code-url]: https://developer.4d.com/
[contributing-url]: .github/CONTRIBUTING.md
[license-url]: LICENSE.md
