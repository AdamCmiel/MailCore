//
//  Info.swift
//  MailCore
//
//  Created by Adam Cmiel on 1/19/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import Foundation
import KeychainSwift

struct AppInfo {
    static let sharedInfo = AppInfo()
    subscript(key: String) -> AnyObject? {
        return NSBundle.mainBundle().infoDictionary?[key]
    }
}

struct AppSecrets {
    static let sharedSecrets = AppSecrets()
    
    let keychain: KeychainSwift = {
        let keychain = KeychainSwift()
        keychain.accessGroup = "com.adamcmiel.app.MailCore"
        return keychain
    }()

    subscript(key: String) -> String? {
        get {
            return keychain.get(key)
        }
        
        set(value) {
            if value == nil {
                keychain.delete(key)
            } else {
                keychain.set(value!, forKey:key, withAccess: .AccessibleWhenUnlocked)
            }
        }
    }
    
    func nukeAll() -> Bool {
        return keychain.clear()
    }
    
    func nuke(key: String) -> Bool {
        return keychain.delete(key)
    }
}

struct AppDefaults {
    static let sharedDefaults = AppDefaults()
    
    subscript(key: String) -> AnyObject? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(key)
        }
        
        set(value) {
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
        }
    }
    
    func integerForKey(key: String) -> Int {
            return NSUserDefaults.standardUserDefaults().integerForKey(key)
    }
    
    func setInteger(i: Int, forKey key: String) {
            return NSUserDefaults.standardUserDefaults().setInteger(i, forKey: key)
    }
}

struct GmailCreds {
    static let kUserIdKey = "gmailUserId"
    static let kTokenKey = "gmailToken"
    static let kNameKey = "gmailName"
    static let kEmailKey = "gmailAddress"
    
    let userId: String
    let accessToken: String
    let name: String
    let email: String
    
    static func readFromStorage() -> GmailCreds? {
        /*
        guard let _userId = Secrets[kUserIdKey] else {
            return nil
        }
        
        guard let _token = Secrets[kTokenKey] else {
            return nil
        }
        */
        guard let _userId = Defaults[kUserIdKey] as? String else {
            return nil
        }
        
        guard let _token = Defaults[kTokenKey] as? String else {
            return nil
        }
        
        guard let _name = Defaults[kNameKey] as? String else {
            return nil
        }
        
        guard let _email = Defaults[kEmailKey] as? String else {
            return nil
        }
        
        return GmailCreds(userId: _userId, accessToken: _token, name: _name, email: _email)
    }
    
    func saveToStorage() {
        Defaults[GmailCreds.kNameKey] = name
        Defaults[GmailCreds.kEmailKey] = email
        
        /* iOS 9 broke keychain-swift?
        Secrets[GmailCreds.kUserIdKey] = userId
        Secrets[GmailCreds.kTokenKey] = accessToken
        */
        Defaults[GmailCreds.kUserIdKey] = userId
        Defaults[GmailCreds.kTokenKey] = accessToken
    }
    
    static func clearStorage() {
        Defaults[GmailCreds.kNameKey] = nil
        Defaults[GmailCreds.kEmailKey] = nil
        Secrets[GmailCreds.kUserIdKey] = nil
        Secrets[GmailCreds.kTokenKey] = nil
        
        /* ioS 9 broke keychain-swift? */
        Defaults[GmailCreds.kUserIdKey] = nil
        Defaults[GmailCreds.kTokenKey] = nil
        GmailSession.sharedSession.inMemoryCreds = nil
    }
}

struct GmailSession {
    static var sharedSession = GmailSession()
    
    private var inMemoryCreds: GmailCreds?
    
    mutating func creds() throws -> GmailCreds {
        if let _creds = inMemoryCreds {
            return _creds
        }
        
        if let _creds = GmailCreds.readFromStorage() {
            inMemoryCreds = _creds
            return _creds
        }
        
        throw NSError(domain: "no creds", code: 0, userInfo: nil)
    }
}

// Globals  dawg
let Info = AppInfo.sharedInfo
var Secrets = AppSecrets.sharedSecrets
var Defaults = AppDefaults.sharedDefaults
