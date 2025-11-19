// API resource for managing fine-tuning jobs in OpenAI
// Fine-tuning lets you create custom models from your own data
Class extends OpenAIAPIResource

Class constructor($client : cs:C1710.OpenAI)
	Super:C1705($client)

/*
* Creates a fine-tuning job which begins the process of creating a new model from a given dataset.
*
* The response includes details about the enqueued job including job status and the name of
* the fine-tuned models once complete.
*
* @param $model {Text} The name of the model to fine-tune (required)
* @param $training_file {Text} The ID of an uploaded file that contains training data (required)
* @param $parameters {cs.OpenAIFineTuningJobParameters} Optional parameters for the fine-tuning job
* @return {cs.OpenAIFineTuningJobResult} Result containing the fine-tuning job information
* @throws Error if model or training_file is empty
*/
Function create($model : Text; $training_file : Text; $parameters : cs:C1710.OpenAIFineTuningJobParameters) : cs:C1710.OpenAIFineTuningJobResult
	// Validate required parameters
	If (Length:C16($model)=0)
		throw:C1805(1; "Expected a non-empty value for `model`")
	End if

	If (Length:C16($training_file)=0)
		throw:C1805(1; "Expected a non-empty value for `training_file`")
	End if

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIFineTuningJobParameters)))
		$parameters:=cs:C1710.OpenAIFineTuningJobParameters.new($parameters)
	End if

	var $body:=$parameters.body()
	$body.model:=$model
	$body.training_file:=$training_file

	return This:C1470._client._post("/fine_tuning/jobs"; $body; $parameters; cs:C1710.OpenAIFineTuningJobResult)

/*
* Get info about a fine-tuning job.
*
* @param $fineTuningJobId {Text} The ID of the fine-tuning job (required)
* @param $parameters {cs.OpenAIParameters} Optional parameters for the request
* @return {cs.OpenAIFineTuningJobResult} Result containing the fine-tuning job information
* @throws Error if fineTuningJobId is empty
*/
Function retrieve($fineTuningJobId : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIFineTuningJobResult
	If (Length:C16($fineTuningJobId)=0)
		throw:C1805(1; "Expected a non-empty value for `fineTuningJobId`")
	End if

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIParameters)))
		$parameters:=cs:C1710.OpenAIParameters.new($parameters)
	End if

	return This:C1470._client._get("/fine_tuning/jobs/"+$fineTuningJobId; $parameters; cs:C1710.OpenAIFineTuningJobResult)

/*
* List your organization's fine-tuning jobs.
*
* @param $parameters {cs.OpenAIFineTuningJobListParameters} Optional parameters for filtering and pagination
* @return {cs.OpenAIFineTuningJobListResult} Result containing a collection of fine-tuning job objects
*/
Function list($parameters : cs:C1710.OpenAIFineTuningJobListParameters) : cs:C1710.OpenAIFineTuningJobListResult

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIFineTuningJobListParameters)))
		$parameters:=cs:C1710.OpenAIFineTuningJobListParameters.new($parameters)
	End if

	var $query:=$parameters.body()
	return This:C1470._client._getApiList("/fine_tuning/jobs"; $query; $parameters; cs:C1710.OpenAIFineTuningJobListResult)

/*
* Immediately cancel a fine-tuning job.
*
* @param $fineTuningJobId {Text} The ID of the fine-tuning job to cancel (required)
* @param $parameters {cs.OpenAIParameters} Optional parameters for the request
* @return {cs.OpenAIFineTuningJobResult} Result containing the cancelled fine-tuning job information
* @throws Error if fineTuningJobId is empty
*/
Function cancel($fineTuningJobId : Text; $parameters : cs:C1710.OpenAIParameters) : cs:C1710.OpenAIFineTuningJobResult
	If (Length:C16($fineTuningJobId)=0)
		throw:C1805(1; "Expected a non-empty value for `fineTuningJobId`")
	End if

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIParameters)))
		$parameters:=cs:C1710.OpenAIParameters.new($parameters)
	End if

	return This:C1470._client._post("/fine_tuning/jobs/"+$fineTuningJobId+"/cancel"; Null:C1517; $parameters; cs:C1710.OpenAIFineTuningJobResult)

/*
* Get status updates for a fine-tuning job.
*
* @param $fineTuningJobId {Text} The ID of the fine-tuning job to get events for (required)
* @param $parameters {cs.OpenAIFineTuningJobListParameters} Optional parameters for pagination
* @return {cs.OpenAIFineTuningEventListResult} Result containing a collection of fine-tuning event objects
* @throws Error if fineTuningJobId is empty
*/
Function listEvents($fineTuningJobId : Text; $parameters : cs:C1710.OpenAIFineTuningJobListParameters) : cs:C1710.OpenAIFineTuningEventListResult
	If (Length:C16($fineTuningJobId)=0)
		throw:C1805(1; "Expected a non-empty value for `fineTuningJobId`")
	End if

	If (Not:C34(OB Instance of:C1731($parameters; cs:C1710.OpenAIFineTuningJobListParameters)))
		$parameters:=cs:C1710.OpenAIFineTuningJobListParameters.new($parameters)
	End if

	var $query:=$parameters.body()
	return This:C1470._client._getApiList("/fine_tuning/jobs/"+$fineTuningJobId+"/events"; $query; $parameters; cs:C1710.OpenAIFineTuningEventListResult)
