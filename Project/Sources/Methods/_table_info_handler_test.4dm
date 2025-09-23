//%attributes = {"invisible":true}

#DECLARE($arguments : Object) : Text

var $tableName : Text:=$arguments.tableName
var $table : 4D:C1709.DataClass:=ds:C1482[$tableName]

If ($table=Null:C1517)
	return "Table '"+$tableName+"' does not exist"
End if 

var $info : Object:={}
$info.tableName:=$tableName
$info.fieldCount:=$table.getInfo().fields.length
$info.recordCount:=$table.all().length
$info.fields:=$table.getInfo().fields.extract("name")

return JSON Stringify:C1217($info)