//%attributes = {}

var $formData:=cs:C1710._MultipartFormData.new()

$formData.addField("field1"; "value1")
$formData.addField("field2"; "value2")

var $file : 4D:C1709.File:=Folder:C1567(fk database folder:K87:14).folder("Project").files().filter(Formula:C1597($1.value.extension=".4DProject")).first()
$formData.addFile("file1"; $file)

var $audioFile:=File:C1566("/System/Library/PrivateFrameworks/PersonalAudio.framework/Versions/A/Resources/Enrollment_1.mp3")
$formData.addFile("file2"; $audioFile)

var $options:={}
$options:=$formData.configure($options)

If (Not:C34(Shift down:C543))
	//return 
End if 

// We need to add cs:C1710._TestWeb.me.test() into onWebConnection to test that

var $mustStop:=False:C215
If (Not:C34(WEB Server:C1674().isRunning))
	WEB Server:C1674().start()
	$mustStop:=True:C214
End if 

var $client:=4D:C1709.HTTPRequest.new("http://localhost/test"; $options)

$client.wait(10)

If (Asserted:C1132(cs:C1710._TestWeb.me.parts.length=4))
	ASSERT:C1129(cs:C1710._TestWeb.me.parts[0].name="field1")
	ASSERT:C1129(BLOB to text:C555(cs:C1710._TestWeb.me.parts[0].content; UTF8 text without length:K22:17)=("value1"+$formData.LINE_BREAK))
	ASSERT:C1129(cs:C1710._TestWeb.me.parts[1].name="field2")
	ASSERT:C1129(BLOB to text:C555(cs:C1710._TestWeb.me.parts[1].content; UTF8 text without length:K22:17)=("value2"+$formData.LINE_BREAK))
	ASSERT:C1129(cs:C1710._TestWeb.me.parts[2].name="file1")
	ASSERT:C1129(BLOB to text:C555(cs:C1710._TestWeb.me.parts[2].content; UTF8 text without length:K22:17)=($file.getText()+$formData.LINE_BREAK))
	ASSERT:C1129(cs:C1710._TestWeb.me.parts[3].name="file2")
End if 

If ($mustStop)
	WEB Server:C1674().stop()
End if 