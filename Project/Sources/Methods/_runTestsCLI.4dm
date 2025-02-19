//%attributes = {}
var $results : Object
$results:=_runTests(True:C214)

Folder:C1567(Temporary folder:C486; fk platform path:K87:2).file("testsAIKIT.json").setText(JSON Stringify:C1217($results; *))

QUIT 4D:C291