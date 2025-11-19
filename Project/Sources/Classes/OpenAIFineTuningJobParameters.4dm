// Parameters for creating a fine-tuning job

// The hyperparameters used for the fine-tuning job (deprecated, use method instead)
property hyperparameters : Object

// The method configuration for fine-tuning (supervised, DPO, reinforcement)
property method : Object

// A string of up to 64 characters that will be added to your fine-tuned model name
property suffix : Text

// The ID of an uploaded file that contains validation data
property validation_file : Text

// The seed controls the reproducibility of the job
property seed : Integer

// A list of integrations to enable for your fine-tuning job
property integrations : Collection

// A set of 16 key-value pairs that can be attached to an object
property metadata : Object

Class extends OpenAIParameters

Class constructor($object : Object)
	Super:C1705($object)

Function body() : Object
	var $body:=Super:C1706.body()

	// Add hyperparameters if provided (deprecated but still supported)
	If (This:C1470.hyperparameters#Null:C1517)
		$body.hyperparameters:=This:C1470.hyperparameters
	End if

	// Add method if provided
	If (This:C1470.method#Null:C1517)
		$body.method:=This:C1470.method
	End if

	// Add suffix if provided
	If (Length:C16(This:C1470.suffix)>0)
		$body.suffix:=This:C1470.suffix
	End if

	// Add validation_file if provided
	If (Length:C16(This:C1470.validation_file)>0)
		$body.validation_file:=This:C1470.validation_file
	End if

	// Add seed if provided
	If (This:C1470.seed#Null:C1517)
		$body.seed:=This:C1470.seed
	End if

	// Add integrations if provided
	If (This:C1470.integrations#Null:C1517)
		$body.integrations:=This:C1470.integrations
	End if

	// Add metadata if provided
	If (This:C1470.metadata#Null:C1517)
		$body.metadata:=This:C1470.metadata
	End if

	return $body
