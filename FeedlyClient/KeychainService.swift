
import Foundation
import Security

//http://matthewpalmer.net/blog/2014/06/21/example-ios-keychain-swift-save-query/

// Identifiers
let serviceIdentifier = "MySerivice"
let userAccount = "authenticatedUser"
//let accessGroup = "MySerivice"

// Arguments for the keychain queries
let kSecClassValue = kSecClass.takeRetainedValue() as NSString
let kSecAttrAccountValue = kSecAttrAccount.takeRetainedValue() as NSString
let kSecValueDataValue = kSecValueData.takeRetainedValue() as NSString
let kSecClassGenericPasswordValue = kSecClassGenericPassword.takeRetainedValue() as NSString
let kSecAttrServiceValue = kSecAttrService.takeRetainedValue() as NSString
let kSecMatchLimitValue = kSecMatchLimit.takeRetainedValue() as NSString
let kSecReturnDataValue = kSecReturnData.takeRetainedValue() as NSString
let kSecMatchLimitOneValue = kSecMatchLimitOne.takeRetainedValue() as NSString

class KeychainService : NSObject {
    class func saveToken(accessToken: String) {
        self.save(serviceIdentifier, data: accessToken)
    }
    
   /*
    * Internal methods for querying the keychain.
    */
    private class func save(service: NSString, data: NSString) {
        var dataFromString: NSData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        // Instantiate a new default keychain query
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
        
        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionaryRef)
        
        // Add the new keychain item
        var status: OSStatus = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
    }
    
    private class func load(service: NSString) -> NSString? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var dataTypeRef :Unmanaged<AnyObject>?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        
        let opaque = dataTypeRef?.toOpaque()
        
        var contentsOfKeychain: NSString?
        
        if let op = opaque? {
            let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
            
            // Convert the data retrieved from the keychain into a string
            contentsOfKeychain = NSString(data: retrievedData, encoding: NSUTF8StringEncoding)
        } else {
            println("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain
    }
}