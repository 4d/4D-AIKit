// The fine-tuning job identifier, which can be referenced in the API endpoints
property id : Text

// The object type, which is always "fine_tuning.job"
property object : Text

// The Unix timestamp (in seconds) for when the fine-tuning job was created
property created_at : Integer

// The Unix timestamp (in seconds) for when the fine-tuning job was finished
property finished_at : Integer

// For fine-tuning jobs that have failed, this will contain more information on the cause of the failure
property error : Object

// The name of the fine-tuned model that is being created. The value will be null if the fine-tuning job is still running
property fine_tuned_model : Text

// The hyperparameters used for the fine-tuning job
property hyperparameters : Object

// The base model that is being fine-tuned
property model : Text

// The organization that owns the fine-tuning job
property organization_id : Text

// The compiled results file ID(s) for the fine-tuning job
property result_files : Collection

// The current status of the fine-tuning job (queued, running, succeeded, failed, or cancelled)
property status : Text

// The total number of billable tokens processed by this fine-tuning job
property trained_tokens : Integer

// The file ID used for training
property training_file : Text

// The file ID used for validation
property validation_file : Text

// A list of integrations to enable for this fine-tuning job
property integrations : Collection

// The seed used for the fine-tuning job
property seed : Integer

// A set of 16 key-value pairs that can be attached to the fine-tuning job
property metadata : Object

// The method used for fine-tuning
property method : Object

Class constructor($object : Object)
	If ($object=Null:C1517)
		return
	End if
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each
