//%attributes = {"invisible":true}
#DECLARE($parameters : cs:C1710.GeminiParameters; $result : cs:C1710.GeminiResult)

If ($result.success)
	If (($parameters.onResponse#Null:C1517) && (OB Instance of:C1731($parameters.onResponse; 4D:C1709.Function)))
		$parameters.onResponse.call($parameters._formulaThis; $result)
	End if
Else
	If (($parameters.onError#Null:C1517) && (OB Instance of:C1731($parameters.onError; 4D:C1709.Function)))
		$parameters.onError.call($parameters._formulaThis; $result)
	End if
End if

If (($parameters.onTerminate#Null:C1517) && (OB Instance of:C1731($parameters.onTerminate; 4D:C1709.Function)))
	$parameters.onTerminate.call($parameters._formulaThis; $result)
End if
If (($parameters.formula#Null:C1517) && (OB Instance of:C1731($parameters.formula; 4D:C1709.Function)))
	$parameters.formula.call($parameters._formulaThis; $result)
End if
