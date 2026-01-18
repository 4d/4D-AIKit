# AIKit

## Overview

[4D AIKit](https://github.com/4d/4D-AIKit) is a built-in 4D component that enables interaction with third-party AI APIs.

This repo was forked for experimentation and testing purposes.

Normally you should use the offical releases.

## Install

Add `https://github.com/miyako/AIKit/` (without the official `4D-` prefix) to `dependencies.json`

## History

* [feature-google-stream](https://github.com/miyako/AIKit/tree/feature-google-stream): Gemini chat completion stream support and tool calling support

#### Compatibility with AIKit function calling

|Model&nbsp;Family|Version|Function&nbsp;Calling|
|-|-|:-:|:-:|
|3.5|
|o1|
|o3|
|o4|
|4|
|4o|✅
|4.1|✅
|5|
|5.1|✅
|5.2|✅

For function calling you would want to use a **reasoning** (thinking, chain of thought) model. The first reasoning model from OpenAI is **4o** which was released between 4 and 4.1. 4.1 is the last non-reasoning model. After 4.1 came o1, o3, and o4 which are all reasoning models. GPT 5 series are all reasoninig models. As of today, 3.5, 4o, 4.1, o1, o3, o4 are legacy models.

#### TL; DR

Use 4o, 4.1, 5.1, or 5.2.
