//
//  Files.swift
//  MailCore
//
//  Created by Adam Cmiel on 4/20/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import UIKit

struct Files {
    
    private static var inMemoryCache = NSCache()
    
    // MARK: - Retreiving files
    
    static func get(identifier: String?) -> String? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        // First try the memory cache
        if let str = inMemoryCache.objectForKey(path) as? String {
            return str
        }
        
        // Next Try the disk
        do {
            let str = try String(contentsOfFile: path)
            return str
        } catch {
            return nil
        }
    }
    
    // MARK: - Saving files
    
    static func store(string: String?, withIdentifier identifier: String) -> Bool {
        let path = pathForIdentifier(identifier)
        
        // If the image is nil, remove images from the cache
        if string == nil {
            inMemoryCache.removeObjectForKey(path)
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
                print("deleted file at \(path)")
                return true
            } catch _ {
                print("failed to delete file at \(path)")
                return false
            }
        }
        
        // Otherwise, keep the image in memory
        inMemoryCache.setObject(string!, forKey: path)
        
        // And in documents directory
        do {
            try string!.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Helper
    
    private static func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
}
