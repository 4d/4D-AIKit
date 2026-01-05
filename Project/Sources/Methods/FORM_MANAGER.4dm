//%attributes = {}
//%attributes = {"invisible":true,"preemptive":"incapable"}
If (Structure file:C489=Structure file:C489(*))  // Don't hide errors
	
	Form:C1466.manager(FORM Event:C1606)
	
	return 
	
End if 

Try
	
	Form:C1466.manager(FORM Event:C1606)
	
Catch
	
	var $errors:=Last errors:C1799
	
	TRACE:C157
	
End try