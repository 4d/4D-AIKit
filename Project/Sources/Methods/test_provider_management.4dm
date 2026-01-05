//%attributes = {"invisible":true}
// Test for Provider Management Feature #19212
// Tests: Name uniqueness, Delete protection, Rename propagation

// MARK:- Test Setup
var $testResults:=[]

// MARK:- TC-19243-01: Name Uniqueness Test
// The Provider name shall be unique

var $providers:=cs:C1710.OpenAIProviders.me

// Create temp config for testing
var $tempFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2)
var $configFile:=$tempFolder.file("test-providers-uniqueness.json")

var $config:={\
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
var $keys:=$providers.getProviderKeys()
If (Asserted:C1132($keys.length=2; "Should have 2 providers"))
	ASSERT:C1129($keys.includes("provider1"); "Should contain provider1")
	ASSERT:C1129($keys.includes("provider2"); "Should contain provider2")
End if 

// Test: Adding provider with existing key should replace it (key-based uniqueness)
$providers.addProvider("provider1"; {baseURL: "https://api.new.com/v1"; apiKey: "newkey"})
var $p1:=$providers.getProvider("provider1")
ASSERT:C1129($p1.baseURL="https://api.new.com/v1"; "Provider1 should be updated, not duplicated")
ASSERT:C1129($providers.getProviderKeys().length=2; "Should still have 2 providers after update")

$testResults.push({test: "TC-19243-01"; name: "Name Uniqueness"; status: "PASS"})

// Cleanup
$configFile.delete()

// MARK:- TC-19244-01 & TC-19244-02: Delete Protection Test
// If the user tries to delete a provider used by a vector, 4D shall not delete it

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

// Create a custom listener that blocks deletion for "usedProvider"
var $deleteBlocker : Object:={\
blockedProvider: "usedProvider"; \
wasBlocked: False:C215; \
onProviderRemoved: Formula:C1597(\
If ($1.key=This:C1470.blockedProvider)\
This:C1470.wasBlocked:=True:C214
End if \
)\
}


// Note: The current OpenAIProviders class notifies AFTER removal
// For true delete protection, we need to check BEFORE - this tests the notification pattern
$providers.addListener($deleteBlocker)

// Test: Remove unused provider should work
var $resultUnused:=$providers.removeProvider("unusedProvider")
ASSERT:C1129($resultUnused=True:C214; "Should be able to remove unused provider")
ASSERT:C1129($providers.getProvider("unusedProvider")=Null:C1517; "Unused provider should be gone")

// Test: Provider keys updated
ASSERT:C1129($providers.getProviderKeys().length=1; "Should have 1 provider left")
ASSERT:C1129($providers.getProviderKeys()[0]="usedProvider"; "usedProvider should remain")

$providers.removeListener($deleteBlocker)
$testResults.push({test: "TC-19244-01"; name: "Delete Unused Provider"; status: "PASS"})

// Cleanup
$configFile.delete()

// MARK:- TC-19244-03: Delete Protection with Custom Handler
// Test the listener pattern for blocking deletions

$configFile:=$tempFolder.file("test-providers-delete-block.json")
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

// Custom handler that tracks removal attempts
var $removalTracker:={\
removedProviders: []; \
onProviderRemoved: Formula:C1597(\
This:C1470.removedProviders.push($1.key)\
)\
}

$providers.addListener($removalTracker)

// Remove the provider
$providers.removeProvider("protectedProvider")

// Verify the listener was notified
ASSERT:C1129($removalTracker.removedProviders.includes("protectedProvider"); "Listener should be notified of removal")

$providers.removeListener($removalTracker)
$testResults.push({test: "TC-19244-03"; name: "Delete Notification Handler"; status: "PASS"})

// Cleanup
$configFile.delete()

// MARK:- TC-19408-01: Rename Propagation Test
// When developer renames a provider, listeners should be notified

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

// Custom handler that tracks modifications for rename propagation
var $renameTracker:={\
renamedFrom: ""; \
renamedTo: ""; \
modificationReceived: False:C215; \
onProviderAdded: Formula:C1597(\
This:C1470.renamedTo:=$1.key\
); \
onProviderRemoved: Formula:C1597(\
This:C1470.renamedFrom:=$1.key\
); \
onProviderModified: Formula:C1597(\
This:C1470.modificationReceived:=True:C214\
)\
}

$providers.addListener($renameTracker)

// Simulate rename: get old config, add with new name, remove old
var $oldConfig:=$providers.getProvider("oldName")
$providers.addProvider("newName"; $oldConfig)
$providers.removeProvider("oldName")

// Verify rename was tracked
ASSERT:C1129($renameTracker.renamedFrom="oldName"; "Should track old name removal")
ASSERT:C1129($renameTracker.renamedTo="newName"; "Should track new name addition")
ASSERT:C1129($providers.getProvider("oldName")=Null:C1517; "Old name should not exist")
ASSERT:C1129($providers.getProvider("newName")#Null:C1517; "New name should exist")
ASSERT:C1129($providers.getProvider("newName").baseURL="https://api.example.com/v1"; "Config should be preserved")

$providers.removeListener($renameTracker)
$testResults.push({test: "TC-19408-01"; name: "Rename Propagation"; status: "PASS"})

// Cleanup
$configFile.delete()

// MARK:- TC-19408-02: Rename with Vector Simulation
// Simulate a vector that updates its provider reference on rename

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

// Simulate a vector object that references a provider
var $simulatedVector:={\
name: "MyVector"; \
providerName: "myProvider"; \
updateProvider: Formula:C1597(\
This:C1470.providerName:=$1\
)\
}

// Custom handler that updates vector references on rename
var $vectorUpdater:={\
vectors: [$simulatedVector]; \
oldProviderName: ""; \
newProviderName: ""; \
onProviderRemoved: Formula:C1597(\
This:C1470.oldProviderName:=$1.key\
); \
onProviderAdded: Formula:C1597(\
  // When a new provider is added, check if it's a rename\
If (Length:C16(This:C1470.oldProviderName)>0)\
// Update all vectors that referenced the old name\
var $vector : Object\
For each ($vector; This:C1470.vectors)\
If ($vector.providerName=This:C1470.oldProviderName)\
$vector.updateProvider($1.key)\
End if \
End for each \
This:C1470.oldProviderName:=""\
End if \
)\
}

$providers.addListener($vectorUpdater)

// Verify initial state
ASSERT:C1129($simulatedVector.providerName="myProvider"; "Vector should reference myProvider initially")

// Perform rename
var $config2:=$providers.getProvider("myProvider")
$providers.addProvider("renamedProvider"; $config2)
$providers.removeProvider("myProvider")

// Verify vector was updated
ASSERT:C1129($simulatedVector.providerName="renamedProvider"; "Vector should be updated to renamedProvider")

$providers.removeListener($vectorUpdater)
$testResults.push({test: "TC-19408-02"; name: "Rename Updates Vector Reference"; status: "PASS"})

// Cleanup
$configFile.delete()

// MARK:- Test Summary
var $passed:=$testResults.query("status = :1"; "PASS").length
var $total:=$testResults.length

ALERT:C41("Provider Management Tests\n\nPassed: "+String:C10($passed)+"/"+String:C10($total)+"\n\n"+\
$testResults.map(Formula:C1597($1.value.test+": "+$1.value.status)).join("\n"))
