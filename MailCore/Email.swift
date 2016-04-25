//
//  Email.swift
//  MailCore
//
//  Created by Adam Cmiel on 1/19/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import Foundation
import CoreData


class Email: NSManagedObject, UniqueUid {

    static let NAME = "Email"
    
    class func create() -> Email {
        return NSEntityDescription.insertNewObjectForEntityForName(NAME, inManagedObjectContext: AppDelegate.thatDelegate.managedObjectContext) as! Email
    }
    
    private class func _emailFetchRequest() -> (NSManagedObjectContext, NSFetchRequest) {
        let context = AppDelegate.thatDelegate.managedObjectContext
        let request = NSFetchRequest(entityName: "Email")
        
        let sortDescriptor = NSSortDescriptor(key: "uid", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        return (context, request)
    }
    
    class func all(predicateBlock: ((NSManagedObjectContext, NSFetchRequest) -> NSFetchRequest)?) -> [Email] {
        
        let (context, request) = _emailFetchRequest()
        
        var requestToExecute: NSFetchRequest
        if let block = predicateBlock {
            requestToExecute = block(context, request)
        } else {
            requestToExecute = request
        }
        
        do {
            return try context.executeFetchRequest(requestToExecute) as! [Email]
        } catch let error {
            print(error)
            return []
        }
    }
    
    class func all() -> [Email] {
        return all(nil)
    }
    
    class func all(fromUid minUID: Int, toUid maxUID: Int) -> [Email] {
        return all { _, request in
            let predicate = NSPredicate(format: "uid >= \(minUID) AND uid <= \(maxUID)")
            request.predicate = predicate
            return request
        }
    }
    
    class func all(limit returnLimit: Int) -> [Email] {
        return all { _, request in
            request.fetchLimit = returnLimit
            return request
        }
    }
    
    func filePath() -> String {
        return "e\(self.uid).email.html"
    }
    
}

extension Array where Element:MCOIMAPMessage {
    
    /**
    Maps headers to emails, saves core data
     */
    func mapToEmails() -> [Email] {
        let emails = self.map { (headers: MCOIMAPMessage) -> Email in
            let email = Email.create()
            email.uid = headers.uid
            email.read = headers.flags.contains(.Seen)
            email.subject = headers.header.subject
            return email
        }
        
        AppDelegate.thatDelegate.saveContext()
        return emails
    }
    
    func filterUidsAlreadyHave() -> [Element] {
        if let lowerLimit = leastUid() {
            if let upperLimit = greatestUid() {
                let iLowerLimit = Int(lowerLimit)
                let iUpperLimit = Int(upperLimit)
                
                let emailUidsToFilter = Email.all(fromUid: iLowerLimit, toUid: iUpperLimit).map({ $0.uid })
                return filter { !emailUidsToFilter.contains($0.uid) }
            }
        }
        
        return []
    }
}

extension Array where Element:UniqueUid {
    func greatestUid() -> UInt32? {
        return map({ $0.uid }).maxElement()
    }
    
    func leastUid() -> UInt32? {
        return map({ $0.uid }).minElement()
    }
}

extension MCOIMAPMessage: UniqueUid {}

protocol UniqueUid {
    var uid: UInt32 { get }
}