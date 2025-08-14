//%attributes = {}

// Simple test without type declarations to check basic functionality
var $client
$client:=TestOpenAI()
If ($client=Null:C1517)
	return   // skip test
End if 

// Check if responses property exists
If (Asserted:C1132($client.responses#Null:C1517; "Client should have responses property"))
	
	// Check if input_items property exists  
	If (Asserted:C1132($client.responses.input_items#Null:C1517; "Responses should have input_items property"))
		
		// Simple test - create parameters object
		var $parameters
		$parameters:=New object:C1471
		$parameters.model:="gpt-4o-mini"
		$parameters.instructions:="You are a helpful assistant."
		$parameters.max_output_tokens:=100
		
		// Try to call create method
		var $result
		$result:=$client.responses.create("Hello, test"; $parameters)
		
		If ($result#Null:C1517)
			TRACE:C157
		End if 
		
	End if 
	
End if
