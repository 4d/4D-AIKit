//%attributes = {}
// Test OpenAI Chat Helper with weather tool (non-async)

var $client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// Create a helper with specific system prompt and numberOfMessages limit
var $helper:=$client.chat.create("You are a helpful weather assistant. Provide weather information for cities when requested."; {model: "gpt-4o-mini"})
$helper.numberOfMessages:=5
$helper.autoHandleToolCalls:=True:C214

// Define the weather tool
var $getWeatherTool:={type: "function"; \
function: {name: "get_weather"; \
description: "Get the current weather for a specific city"; \
parameters: {type: "object"; \
properties: {city: {type: "string"; description: "The name of the city to get weather for"}}; \
required: ["city"]; \
additionalProperties: False:C215}; \
strict: True:C214}}

// Define precomputed weather data for cities
var $weatherData:={}
$weatherData["Paris"]:={city: "Paris"; temperature: 18; condition: "Partly Cloudy"; humidity: 65; wind_speed: 12}
$weatherData["London"]:={city: "London"; temperature: 15; condition: "Rainy"; humidity: 78; wind_speed: 8}
$weatherData["Tokyo"]:={city: "Tokyo"; temperature: 22; condition: "Sunny"; humidity: 45; wind_speed: 15}
$weatherData["New York"]:={city: "New York"; temperature: 20; condition: "Cloudy"; humidity: 60; wind_speed: 10}
$weatherData["Sydney"]:={city: "Sydney"; temperature: 25; condition: "Sunny"; humidity: 50; wind_speed: 18}

// Define weather tool handler that uses precomputed data
var $weatherHandler:=Formula:C1597(JSON Stringify:C1217($weatherData[String:C10($1.city)]))

// Register the weather tool
$helper.registerTool($getWeatherTool; $weatherHandler)

// Test 1: Ask for weather of 4 cities in one prompt
var $result1:=$helper.prompt("Can you get the weather for these 4 cities: Paris, London, Tokyo, and New York?")
If (Asserted:C1132($result1.success; "Cannot get weather for 4 cities: "+JSON Stringify:C1217($result1)))
	ASSERT:C1129(Length:C16($result1.choice.message.text)>0; "Weather response should have content")
End if 

// Test 2: Ask for weather of a fifth city (after the initial 4)
var $result2:=$helper.prompt("Now can you also get the weather for Sydney?")
If (Asserted:C1132($result2.success; "Cannot get weather for Sydney: "+JSON Stringify:C1217($result2)))
	ASSERT:C1129(Length:C16($result2.choice.message.text)>0; "Weather response should have content")
End if 
