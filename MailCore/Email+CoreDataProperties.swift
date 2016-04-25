//
//  Email+CoreDataProperties.swift
//  MailCore
//
//  Created by Adam Cmiel on 1/19/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Email {

    @NSManaged var subject: String?
    @NSManaged var uid: UInt32
    @NSManaged var read: Bool

}
