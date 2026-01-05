//%attributes = {"shared":true}
#DECLARE($action : Text) : Integer

var $form:="AIPROVIDERS"
var $openDial : Boolean

If (Num:C11(Storage:C1525.studio[$form])=0)
	
	// Create the window
	var $winRef:=Open form window:C675($form; Plain form window:K39:10; Horizontally centered:K39:1; At the top:K39:5; *)
	$openDial:=True:C214
	
Else 
	
	// Select the window
	$winRef:=Num:C11(Storage:C1525.studio[$form])
	var $left; $top; $right; $bottom : Integer
	GET WINDOW RECT:C443($left; $top; $right; $bottom; $winRef)
	SET WINDOW RECT:C444($left; $top; $right; $bottom; $winRef)
	
End if 

Case of 
		
		// ______________________________________________________
	: (Count parameters:C259=0)  // C++ call
		
		// <NOTHING MORE TO DO>
		
		// ______________________________________________________
	: ($action="new")
		
		CALL FORM:C1391($winref; Formula:C1597(Form:C1466.newProvider()))
		
		// ______________________________________________________
	Else   // the name od a model to select
		
		CALL FORM:C1391($winref; Formula:C1597(Form:C1466.selectProvider($action)))
		
		// ______________________________________________________
End case 

If ($openDial)
	
	If (Structure file:C489=Structure file:C489(*))\
		 && (Num:C11(Storage:C1525.studio[$form])=0)  // DEV TESTS
		
		DIALOG:C40($form)
		CLOSE WINDOW:C154($winRef)
		
	Else 
		
		DIALOG:C40($form; *)
		
	End if 
End if 

return $winRef