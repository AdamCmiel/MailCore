//
//  Mail.swift
//  MailCore
//
//  Created by Adam Cmiel on 1/19/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import Foundation

struct Mail {
    
    static var sharedMail = Mail()
    
    static let kGmailIMAPHostnameKey = "GmailIMAPHostname"
    static let kGmailIMAPFolderKey = "GmailIMAPFolder"
    static let kGmailIMAPPortKey = "GmailIMAPPort"
    
    var folder: String {
        return Info[Mail.kGmailIMAPFolderKey] as! String
    }
    
    var session: MCOIMAPSession = {
        let s = MCOIMAPSession()
        s.hostname = Info[Mail.kGmailIMAPHostnameKey] as! String
        s.port = UInt32(Info[Mail.kGmailIMAPPortKey] as! Int)
        s.authType = .XOAuth2
        s.connectionType = .TLS
        return s
    }()
    
    func fetchFolderInfo(completionHandler: (NSError?, MCOIMAPFolderInfo?) -> Void) {
        session.folderInfoOperation(folder).start(completionHandler)
    }
    
    func fetchMessageHeaders(count: Int, completionHandler: (NSError?, [AnyObject]?, MCOIndexSet?) -> Void, errorHandler: ErrorType -> Void) {
        
        fetchFolderInfo { (error, info) -> Void in
            
            if let error = error {
                print("error downloading message headers")
                return errorHandler(error)
            }
            
            let firstId = (info!.firstUnseenUid == 0) ? UInt64(info!.messageCount - count) : UInt64(Int(info!.firstUnseenUid) - count)
            let lastId = UInt64.max
            let numbers = MCOIndexSet(range: MCORangeMake(firstId, lastId))
            let requestKind: MCOIMAPMessagesRequestKind = [.Uid, .Flags, .Headers, .Structure, .Size]
            let fetchOperation = self.session.fetchMessagesOperationWithFolder(self.folder, requestKind: requestKind, uids: numbers)
    
            fetchOperation.start(completionHandler)
        }
    }
    
    /**
     
     Gets 50 emails
     
     - Parameter completionHandler: callback with email
     
     */
    func getEmailHeaders(completionHandler: [MCOIMAPMessage]! -> Void, errorHandler: ErrorType -> Void) {
        getEmailHeaders(50, completionHandler: completionHandler, errorHandler: errorHandler)
    }
    
    /**
     
     Gets n emails
     
     - Parameter count: number of emails
     
     - Parameter completionHandler: callback with email
     
    */
    func getEmailHeaders(count: Int, completionHandler: [MCOIMAPMessage]! -> Void, errorHandler: ErrorType -> Void) {
        
        fetchMessageHeaders(count, completionHandler: { error, messages, vanishedMessages in
            print("operation callback")
            
            guard error == nil else {
                print("error downloading message headers")
                print(error)
                fatalError()
            }
            
            print("the post man delivereth")
            print(messages)
            
            let imapMessages = messages as! [MCOIMAPMessage]
            completionHandler(imapMessages.reverse())
        }, errorHandler: errorHandler)
    }
    
    func getEmailData(message: MCOIMAPMessage, completionHandler: NSData -> Void) {
        let f = folder
        let messageDownloadOperation = session.fetchMessageOperationWithFolder(f, uid: message.uid)
        
        messageDownloadOperation.start { (error, messageData) -> Void in
            
            guard error == nil else {
                print("error downloading email body")
                print(error)
                fatalError()
            }
            
            completionHandler(messageData!)
        }
    }
    
    func emailHTML(message: MCOIMAPMessage, completionHandler: String -> Void) {
        getEmailData(message) { data in
            let messageParser = MCOMessageParser(data: data)
            completionHandler(messageParser.htmlRenderingWithDelegate(nil))
        }
    }
}