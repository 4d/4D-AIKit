# AIKit

## Overview

[4D AIKit](https://github.com/4d/4D-AIKit) is a built-in 4D component that enables interaction with third-party AI APIs.

This repo was forked for experimentation and testing purposes.

Normally you should use the offical releases.

## Install

Add `https://github.com/miyako/AIKit/` (without the official `4D-` prefix) to `dependencies.json`

## History

* [feature-google-stream](https://github.com/miyako/AIKit/tree/feature-google-stream): Gemini chat completion stream support and tool calling support

#### OpenAI Compatibility with AIKit function calling

|Model&nbsp;Family|Version|Function&nbsp;Calling|Remarks
|-|-|:-:|-|
|GPT|3.5||This is not a chat model and thus not supported in the v1/chat/completions endpoint. 
||3.5-turbo||This is not a chat model and thus not supported in the v1/chat/completions endpoint. 
||o1||This model is only supported in v1/responses and not in v1/chat/completions.
||o3||This is not a chat model and thus not supported in the v1/chat/completions endpoint. 
||o4||Unsupported value: 'temperature' does not support 0 with this model. Only the default (1) value is supported.
||4||
||4o|✅|
||4-turbo|✅|
||4.1|✅|
||5||This model is only supported in v1/responses and not in v1/chat/completions.
||5.1|✅|
||5.2|✅|

For function calling you would want to use a **reasoning** (thinking, chain of thought) model. The first reasoning model from OpenAI is **4o** which was released between 4 and 4.1. 4.1 is the last non-reasoning model. After 4.1 came o1, o3, and o4 which are all reasoning models. GPT 5 series are all reasoninig models. As of today, 3.5, 4o, 4.1, o1, o3, o4 are legacy models.

#### TL; DR

Use 4o, 4-turbo, 4.1, 5.1, or 5.2.

#### Google Compatibility with AIKit function calling

|Model&nbsp;Family|Version|Function&nbsp;Calling|Remarks
|-|-|:-:|-|
|Gemini|2.0|
||2.5|✅|
| |3||

#### TL; DR

Use 2.5. Gemini 3 (preview) on OpenAI compatibility seems to have a regression.

#### Claude Compatibility with AIKit function calling

|Model&nbsp;Family|Version|Function&nbsp;Calling|Remarks
|-|-|:-:|-|
|Haiku|4.5|✅|
|Opus|4.5|✅|
|Sonnet|4.5|✅|Request might exceed the rate limit of 10,000 input tokens per minute.
