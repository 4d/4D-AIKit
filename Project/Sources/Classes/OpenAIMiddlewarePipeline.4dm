/*
 * OpenAIMiddlewarePipeline - Manages and executes middleware chain
 *
 * Executes a collection of middleware in order, passing context through
 * each step. Supports before-request and after-response processing.
 *
 * Usage:
 *   $pipeline:=OpenAIMiddlewarePipeline.new()
 *   $pipeline.add($tokenCounter)
 *   $pipeline.add($summarizer)
 *   $context:=$pipeline.executeBeforeRequest($context)
 *
 * Features:
 *   - Chain of responsibility pattern
 *   - Abort on Null return
 *   - Skip disabled middleware
 *   - Error handling and logging
 */

Class constructor
	This:C1470.middleware:=[]  // Collection of OpenAIMiddleware instances
	This:C1470.debug:=False:C215

/*
 * Add middleware to the pipeline
 *
 * @param $middleware OpenAIMiddleware - Middleware instance
 * @return OpenAIMiddlewarePipeline - This (for chaining)
 */
Function add($middleware : Object)->$result : Object
	If ($middleware=Null:C1517)
		return This:C1470
	End if

	// Validate it's a middleware instance
	If (OB Instance of:C1731($middleware; OpenAIMiddleware))
		This:C1470.middleware.push($middleware)
		This:C1470._log("Added middleware: "+$middleware.getName())
	Else
		This:C1470._error("Invalid middleware: must be instance of OpenAIMiddleware")
	End if

	return This:C1470

/*
 * Remove middleware by name
 *
 * @param $name Text - Middleware name
 * @return Boolean - True if removed
 */
Function remove($name : Text)->$removed : Boolean
	var $i : Integer

	For ($i; This:C1470.middleware.length-1; 0; -1)
		If (This:C1470.middleware[$i].getName()=$name)
			This:C1470.middleware.remove($i)
			This:C1470._log("Removed middleware: "+$name)
			return True:C214
		End if
	End for

	return False:C215

/*
 * Get middleware by name
 *
 * @param $name Text - Middleware name
 * @return OpenAIMiddleware - Middleware instance or Null
 */
Function get($name : Text)->$middleware : Object
	var $m : Object

	For each ($m; This:C1470.middleware)
		If ($m.getName()=$name)
			return $m
		End if
	End for each

	return Null:C1517

/*
 * Clear all middleware from pipeline
 */
Function clear()
	This:C1470.middleware:=[]
	This:C1470._log("Cleared all middleware")

/*
 * Get count of middleware in pipeline
 *
 * @return Integer - Count
 */
Function count()->$count : Integer
	return This:C1470.middleware.length

/*
 * List all middleware names
 *
 * @return Collection - Names of all middleware
 */
Function list()->$names : Collection
	return This:C1470.middleware.map(Formula:C1597($1.value.getName()))

/*
 * Execute before-request middleware pipeline
 *
 * Passes context through each middleware in order.
 * If any middleware returns Null, pipeline aborts and returns Null.
 *
 * @param $context Object - {helper, messages, parameters, metadata}
 * @return Object - Modified context or Null to abort request
 */
Function executeBeforeRequest($context : Object)->$result : Object
	var $middleware : Object
	var $startTime : Real

	If ($context=Null:C1517)
		return Null:C1517
	End if

	This:C1470._log("Executing BEFORE middleware pipeline ("+String:C10(This:C1470.middleware.length)+" middleware)")
	$startTime:=Milliseconds:C459

	For each ($middleware; This:C1470.middleware)
		// Skip disabled middleware
		If (Not:C34($middleware.isEnabled()))
			This:C1470._log("Skipping disabled middleware: "+$middleware.getName())
			continue
		End if

		This:C1470._log("Executing BEFORE: "+$middleware.getName())

		try
			$context:=$middleware.processBeforeRequest($context)

			// If middleware returns Null, abort pipeline
			If ($context=Null:C1517)
				This:C1470._log("Middleware aborted pipeline: "+$middleware.getName())
				return Null:C1517
			End if

		catch
			This:C1470._error("Middleware error in "+$middleware.getName()+": "+Last errors:C1799[0].message)
			// Continue with next middleware (resilient)
		End try
	End for each

	This:C1470._log("BEFORE pipeline completed in "+String:C10(Milliseconds:C459-$startTime)+"ms")
	return $context

/*
 * Execute after-response middleware pipeline
 *
 * Passes context through each middleware in order.
 * If any middleware returns Null, pipeline aborts and returns Null.
 *
 * @param $context Object - {helper, messages, parameters, result, newMessage, metadata}
 * @return Object - Modified context or Null to abort adding message
 */
Function executeAfterResponse($context : Object)->$result : Object
	var $middleware : Object
	var $startTime : Real

	If ($context=Null:C1517)
		return Null:C1517
	End if

	This:C1470._log("Executing AFTER middleware pipeline ("+String:C10(This:C1470.middleware.length)+" middleware)")
	$startTime:=Milliseconds:C459

	For each ($middleware; This:C1470.middleware)
		// Skip disabled middleware
		If (Not:C34($middleware.isEnabled()))
			This:C1470._log("Skipping disabled middleware: "+$middleware.getName())
			continue
		End if

		This:C1470._log("Executing AFTER: "+$middleware.getName())

		try
			$context:=$middleware.processAfterResponse($context)

			// If middleware returns Null, abort pipeline
			If ($context=Null:C1517)
				This:C1470._log("Middleware aborted pipeline: "+$middleware.getName())
				return Null:C1517
			End if

		catch
			This:C1470._error("Middleware error in "+$middleware.getName()+": "+Last errors:C1799[0].message)
			// Continue with next middleware (resilient)
		End try
	End for each

	This:C1470._log("AFTER pipeline completed in "+String:C10(Milliseconds:C459-$startTime)+"ms")
	return $context

/*
 * Enable debug logging
 */
Function enableDebug()
	This:C1470.debug:=True:C214

/*
 * Disable debug logging
 */
Function disableDebug()
	This:C1470.debug:=False:C215

/*
 * Log debug message
 *
 * @param $message Text - Message to log
 */
Function _log($message : Text)
	If (This:C1470.debug)
		TRACE:C157("[Pipeline] "+$message)
	End if

/*
 * Log error message
 *
 * @param $message Text - Error message
 */
Function _error($message : Text)
	TRACE:C157("[Pipeline ERROR] "+$message)
