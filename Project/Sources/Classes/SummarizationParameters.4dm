// Prompt to use for summarization
property prompt : Text:="Progressively summarize the conversation so far, focusing on key points, decisions, user preferences, technical details, and any unresolved issues. Write a concise summary that preserves critical information."

// What sampling temperature to use for summarization, between 0 and 2. Lower values (0.0-0.5) recommended for consistency.
property temperature : Real:=0.3

// ID of the model to use for summarization. Using a cheaper model like gpt-4o-mini is recommended.
property model : Text:="gpt-4o-mini"

// The maximum number of tokens for the summary
property maxTokens : Integer:=1000

// Number of recent messages to keep verbatim (not summarized)
property keepLastMessages : Integer:=10

Class constructor($object : Object)
	If ($object=Null:C1517)
		return
	End if

	// Copy all attributes from object
	var $key : Text
	For each ($key; $object)
		This:C1470[$key]:=$object[$key]
	End for each
