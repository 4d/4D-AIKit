//%attributes = {"invisible":true}
// Test for Provider Management Feature #19212
// Tests: Name uniqueness, Delete protection, Rename propagation

// MARK:- Test Setup
var $testResults : Collection:=[]
var $providers : cs:C1710.OpenAIProviders:=cs:C1710.OpenAIProviders.me
var $tempFolder : 4D:C1709.Folder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2)
var $configFile : 4D:C1709.File
var $config : Object
var $listener : cs:C1710._TestProviderListener

// MARK:- TC-19243-01: Name Uniqueness Test
// The Provider name shall be unique

$configFile:=$tempFolder.file("test-providers-uniqueness.json")
$config:={\
providers: {\
provider1: {\
baseURL: "https://api.example1.com/v1"; \
apiKey: "key1"\
}; \
provider2: {\
baseURL: "https://api.example2.com/v1"; \
apiKey: "key2"\
}\
}\
}
$configFile.setText(JSON Stringify:C1217($config))
$providers.providersFile:=$configFile

// Test: Two providers with different names should work
var $keys : Collection:=$providers.getProviderKeys()
If (Asserted:C1132($keys.length=2; "Should have 2 providers"))
	ASSERT:C1129($keys.includes("provider1"); "Should contain provider1")
	ASSERT:C1129($keys.includes("provider2"); "Should contain provider2")
End if 

// Test: Adding provider with existing key should replace it (key-based uniqueness)
$providers.addProvider("provider1"; {baseURL: "https://api.new.com/v1"; apiKey: "newkey"})
var $p1 : Object:=$providers.getProvider("provider1")
ASSERT:C1129($p1.baseURL="https://api.new.com/v1"; "Provider1 should be updated, not duplicated")
ASSERT:C1129($providers.getProviderKeys().length=2; "Should still have 2 providers after update")

$testResults.push({test: "TC-19243-01"; name: "Name Uniqueness"; status: "PASS"})
$configFile.delete()

// MARK:- TC-19244-01: Delete Unused Provider
// Deleting an unused provider should succeed

$configFile:=$tempFolder.file("test-providers-delete.json")
$config:={\
providers: {\
usedProvider: {\
baseURL: "https://api.used.com/v1"; \
apiKey: "usedkey"\
}; \
unusedProvider: {\
baseURL: "https://api.unused.com/v1"; \
apiKey: "unusedkey"\
}\
}\
}
$configFile.setText(JSON Stringify:C1217($config))
$providers.providersFile:=$configFile

// Create listener with usedProvider blocked
$listener:=cs:C1710._TestProviderListener.new()
$listener.blockProvider("usedProvider")
$providers.addListener($listener)

// Test: Remove unused provider should work
var $resultUnused : Object:=$providers.removeProvider("unusedProvider")
ASSERT:C1129($resultUnused.success=True:C214; "Should be able to remove unused provider")
ASSERT:C1129($providers.getProvider("unusedProvider")=Null:C1517; "Unused provider should be gone")
ASSERT:C1129($providers.getProviderKeys().length=1; "Should have 1 provider left")
ASSERT:C1129($listener.removedProviders.includes("unusedProvider"); "Listener should be notified")

$providers.removeListener($listener)
$testResults.push({test: "TC-19244-01"; name: "Delete Unused Provider"; status: "PASS"})
$configFile.delete()

// MARK:- TC-19244-02: Delete Protected Provider (Blocked)
// Deleting a provider that is blocked should fail

$configFile:=$tempFolder.file("test-providers-delete-blocked.json")
$config:={\
providers: {\
protectedProvider: {\
baseURL: "https://api.protected.com/v1"; \
apiKey: "protectedkey"\
}\
}\
}
$configFile.setText(JSON Stringify:C1217($config))
$providers.providersFile:=$configFile

// Create listener that blocks protectedProvider
$listener:=cs:C1710._TestProviderListener.new()
$listener.blockProvider("protectedProvider")
$providers.addListener($listener)

// Test: Remove protected provider should fail
var $resultProtected : Object:=$providers.removeProvider("protectedProvider")
ASSERT:C1129($resultProtected.success=False:C215; "Should NOT be able to remove protected provider")
ASSERT:C1129(Length:C16($resultProtected.message)>0; "Should have error message")
ASSERT:C1129($providers.getProvider("protectedProvider")#Null:C1517; "Protected provider should still exist")
ASSERT:C1129($listener.removedProviders.length=0; "Listener should NOT be notified of removal")

$providers.removeListener($listener)
$testResults.push({test: "TC-19244-02"; name: "Delete Protected Provider Blocked"; status: "PASS"})
$configFile.delete()

// MARK:- TC-19244-03: Delete Provider Used by Vector
// Deleting a provider used by a vector should fail

$configFile:=$tempFolder.file("test-providers-delete-vector.json")
$config:={\
providers: {\
vectorProvider: {\
baseURL: "https://api.vector.com/v1"; \
apiKey: "vectorkey"\
}\
}\
}
$configFile.setText(JSON Stringify:C1217($config))
$providers.providersFile:=$configFile

// Simulate a vector that uses this provider
var $simulatedVector : Object:={name: "MyVector"; providerName: "vectorProvider"}

// Create listener that checks vector usage
$listener:=cs:C1710._TestProviderListener.new()
$listener.registerVector($simulatedVector)
$providers.addListener($listener)

// Test: Remove provider used by vector should fail
var $resultVector : Object:=$providers.removeProvider("vectorProvider")
ASSERT:C1129($resultVector.success=False:C215; "Should NOT be able to remove provider used by vector")
ASSERT:C1129($resultVector.message="Provider 'vectorProvider' is used by vector 'MyVector'"; "Should have correct error message")
ASSERT:C1129($providers.getProvider("vectorProvider")#Null:C1517; "Provider should still exist")

$providers.removeListener($listener)
$testResults.push({test: "TC-19244-03"; name: "Delete Provider Used by Vector Blocked"; status: "PASS"})
$configFile.delete()

// MARK:- TC-19408-01: Rename Provider
// Renaming a provider should work and notify listeners

$configFile:=$tempFolder.file("test-providers-rename.json")
$config:={\
providers: {\
oldName: {\
baseURL: "https://api.example.com/v1"; \
apiKey: "testkey"\
}\
}\
}
$configFile.setText(JSON Stringify:C1217($config))
$providers.providersFile:=$configFile

$listener:=cs:C1710._TestProviderListener.new()
$providers.addListener($listener)

// Test: Rename provider
var $renameResult : Object:=$providers.renameProvider("oldName"; "newName")
ASSERT:C1129($renameResult.success=True:C214; "Rename should succeed")
ASSERT:C1129($providers.getProvider("oldName")=Null:C1517; "Old name should not exist")
ASSERT:C1129($providers.getProvider("newName")#Null:C1517; "New name should exist")
ASSERT:C1129($providers.getProvider("newName").baseURL="https://api.example.com/v1"; "Config should be preserved")
ASSERT:C1129($listener.renamedProviders.length=1; "Listener should be notified of rename")
ASSERT:C1129($listener.renamedProviders[0].oldKey="oldName"; "Should track old key")
ASSERT:C1129($listener.renamedProviders[0].newKey="newName"; "Should track new key")

$providers.removeListener($listener)
$testResults.push({test: "TC-19408-01"; name: "Rename Provider"; status: "PASS"})
$configFile.delete()

// MARK:- TC-19408-02: Rename Blocked Provider
// Renaming a blocked provider should fail

$configFile:=$tempFolder.file("test-providers-rename-blocked.json")
$config:={\
providers: {\
blockedName: {\
baseURL: "https://api.blocked.com/v1"; \
apiKey: "blockedkey"\
}\
}\
}
$configFile.setText(JSON Stringify:C1217($config))
$providers.providersFile:=$configFile

$listener:=cs:C1710._TestProviderListener.new()
$listener.blockRename("blockedName")
$providers.addListener($listener)

// Test: Rename blocked provider should fail
var $renameBlocked : Object:=$providers.renameProvider("blockedName"; "newName")
ASSERT:C1129($renameBlocked.success=False:C215; "Rename should be blocked")
ASSERT:C1129(Length:C16($renameBlocked.message)>0; "Should have error message")
ASSERT:C1129($providers.getProvider("blockedName")#Null:C1517; "Original provider should still exist")
ASSERT:C1129($providers.getProvider("newName")=Null:C1517; "New name should not exist")

$providers.removeListener($listener)
$testResults.push({test: "TC-19408-02"; name: "Rename Blocked Provider"; status: "PASS"})
$configFile.delete()

// MARK:- TC-19408-03: Rename Updates Vector References
// When a provider is renamed, vectors should be updated automatically

$configFile:=$tempFolder.file("test-providers-rename-vector.json")
$config:={\
providers: {\
myProvider: {\
baseURL: "https://api.myai.com/v1"; \
apiKey: "mykey"\
}\
}\
}
$configFile.setText(JSON Stringify:C1217($config))
$providers.providersFile:=$configFile

// Simulate a vector that references this provider
var $vector : Object:={name: "TestVector"; providerName: "myProvider"}

$listener:=cs:C1710._TestProviderListener.new()
$listener.registerVector($vector)
$providers.addListener($listener)

// Verify initial state
ASSERT:C1129($vector.providerName="myProvider"; "Vector should reference myProvider initially")

// Perform rename
var $renameVector : Object:=$providers.renameProvider("myProvider"; "renamedProvider")
ASSERT:C1129($renameVector.success=True:C214; "Rename should succeed")

// Verify vector was updated by the listener
ASSERT:C1129($vector.providerName="renamedProvider"; "Vector should be updated to renamedProvider")

$providers.removeListener($listener)
$testResults.push({test: "TC-19408-03"; name: "Rename Updates Vector Reference"; status: "PASS"})
$configFile.delete()

// MARK:- Test Summary
var $passed : Integer:=$testResults.query("status = :1"; "PASS").length
var $total : Integer:=$testResults.length

If (Shift down:C543)
	ALERT:C41("Provider Management Tests\n\nPassed: "+String:C10($passed)+"/"+String:C10($total)+"\n\n"+\
		$testResults.map(Formula:C1597($1.value.test+": "+$1.value.status)).join("\n"))
End if 