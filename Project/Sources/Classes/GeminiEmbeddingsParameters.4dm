// The task type for the embedding. Optional.
// Values: TASK_TYPE_UNSPECIFIED, RETRIEVAL_QUERY, RETRIEVAL_DOCUMENT, SEMANTIC_SIMILARITY, CLASSIFICATION, CLUSTERING, QUESTION_ANSWERING, FACT_VERIFICATION
property taskType : Text

// Optional title for the text. Only applicable for RETRIEVAL_DOCUMENT task type.
property title : Text

// Output dimensionality (optional). Only certain models support this.
property outputDimensionality : Integer

Class extends GeminiParameters

Class constructor($object : Object)
	Super:C1705($object)

Function body() : Object
	var $body : Object:=Super:C1706.body()

	If (Length:C16(String:C10(This:C1470.taskType))>0)
		$body.taskType:=This:C1470.taskType
	End if

	If (Length:C16(String:C10(This:C1470.title))>0)
		$body.title:=This:C1470.title
	End if

	If (This:C1470.outputDimensionality>0)
		$body.outputDimensionality:=This:C1470.outputDimensionality
	End if

	return $body

