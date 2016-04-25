//
//  Email.swift
//  MailCore
//
//  Created by Adam Cmiel on 1/19/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import Foundation
import CoreData


class Email: NSManagedObject {

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
    
    class func all() -> [Email] {
        let (context, request) = _emailFetchRequest()
        
        do {
            return try context.executeFetchRequest(request) as! [Email]
        } catch let error {
            print(error)
            return []
        }
    }
    
    class func all(sinceUID minUID: Int) -> [Email] {
        let (context, request) = _emailFetchRequest()
        let predicate = NSPredicate(format: "uid >= \(minUID)")
        request.predicate = predicate
        
        do {
            return try context.executeFetchRequest(request) as! [Email]
        } catch let error {
            print(error)
            return []
        }
    }
    
    func filePath() -> String {
        return "e\(self.uid!.integerValue).email.html"
    }
    
}

extension Array where Element:MCOIMAPMessage {
    
    /**
    Maps headers to emails, saves core data
     */
    func mapToEmails() -> [Email] {
        let emails = self.map { (headers: MCOIMAPMessage) -> Email in
            let email = Email.create()
            email.uid = NSNumber(int: Int32(headers.uid))
            email.read = NSNumber(bool: headers.flags.contains(.Seen))
            email.subject = headers.header.subject
            return email
        }
        
        AppDelegate.thatDelegate.saveContext()
        return emails
    }
}
