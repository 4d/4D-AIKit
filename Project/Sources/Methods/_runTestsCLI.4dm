//%attributes = {}
var $results:=_runTests(True:C214)

Folder:C1567(Temporary folder:C486; fk platform path:K87:2).file("testsAIKIT.json").setText(JSON Stringify:C1217($results; *))

var $test : Object
For each ($test; $results.tests || [])
	If ($test.success)
		LOG EVENT:C667(Into system standard outputs:K38:9; "✅ "+String:C10($test.name)+"\n")
	Else 
		LOG EVENT:C667(Into system standard outputs:K38:9; "❌ "+String:C10($test.name)+" "+JSON Stringify:C1217($test.errors)+"\n")
	End if 
End for each 

QUIT 4D:C291