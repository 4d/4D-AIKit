//%attributes = {}
#DECLARE($quiet : Boolean) : Object
var $tests : Object

$tests:={success: False:C215}

ARRAY TEXT:C222($tTxt_tests; 0)
METHOD GET NAMES:C1166($tTxt_tests; "test_@")
$tests.tests:=[]
ARRAY TO COLLECTION:C1563($tests.tests; $tTxt_tests)

$tests.tests:=$tests.tests.map(Formula:C1597({name: $1.value}))

var $test : Object
For each ($test; $tests.tests)
	
	Try(Formula from string:C1601($test.name).call())
	
	$test.errors:=Last errors:C1799
	If ($test.errors#Null:C1517)
		// TRACE
	End if 
	$test.success:=($test.errors=Null:C1517)
	
End for each 

$tests.success:=Not:C34($tests.tests.some(Formula:C1597(Not:C34($1.value.success))))

If (Not:C34($quiet))
	ASSERT:C1129($tests.success; JSON Stringify:C1217($tests; *))
End if 

return $tests