/*
 * OpenAIMiddleware - Base class for all middleware
 *
 * Middleware intercepts and transforms conversation context before/after API calls.
 * Implements chain of responsibility pattern for composable conversation management.
 *
 * Usage:
 *   1. Extend this class
 *   2. Override processBeforeRequest() and/or processAfterResponse()
 *   3. Add to middleware pipeline via OpenAIChatHelper.middleware.add()
 *
 * Example:
 *   Class extends OpenAIMiddleware
 *
 *   Function processBeforeRequest($context : Object)->$result : Object
 *       // Transform context before API call
 *       return $context
 *   End function
 */

property config : Object
property enabled : Boolean
property _name : Text

Class constructor($config : Object)
	This:C1470.config:=($config#Null:C1517) ? $config : {}
	This:C1470.enabled:=True:C214
	This:C1470._name:=""  // Override in subclass or via config

	If (This:C1470.config.name#Null:C1517)
		This:C1470._name:=This:C1470.config.name
	End if

/*
 * Process context before API request
 *
 * @param $context Object - {helper, messages, parameters, metadata}
 * @return Object - Modified context or Null to abort request
 */
Function processBeforeRequest($context : Object)->$result : Object
	// Default: pass through without modification
	return $context

/*
 * Process context after API response
 *
 * @param $context Object - {helper, messages, parameters, result, newMessage, metadata}
 * @return Object - Modified context or Null to abort adding message
 */
Function processAfterResponse($context : Object)->$result : Object
	// Default: pass through without modification
	return $context

/*
 * Get middleware name for debugging and management
 *
 * @return Text - Middleware name
 */
Function getName()->$name : Text
	If (This:C1470._name#"")
		return This:C1470._name
	End if

	// Return class name by default
	return String:C10(This:C1470)

/*
 * Enable middleware
 */
Function enable()
	This:C1470.enabled:=True:C214

/*
 * Disable middleware (will be skipped in pipeline)
 */
Function disable()
	This:C1470.enabled:=False:C215

/*
 * Check if middleware is enabled
 *
 * @return Boolean
 */
Function isEnabled()->$enabled : Boolean
	return This:C1470.enabled

/*
 * Log message if debug enabled
 *
 * @param $message Text - Message to log
 */
Function _log($message : Text)
	If (This:C1470.config.debug)
		LOG EVENT:C667(Into system standard outputs:K38:9; "["+This:C1470.getName()+"] "+$message; Information message:K38:1)
	End if
