//%attributes = {"invisible":true}
#DECLARE($init : Boolean)

If (Bool:C1537($init))
	Use (Storage:C1525)
		Storage:C1525.errors:=New shared object:C1526
	End use 
Else 
	Use (Storage:C1525.errors)
		Storage:C1525.errors.last:=Last errors:C1799.copy(ck shared:K85:29; Storage:C1525.errors)
	End use 
	
End if 