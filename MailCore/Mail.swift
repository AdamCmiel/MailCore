//
//  Mail.swift
//  MailCore
//
//  Created by Adam Cmiel on 1/19/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import Foundation

struct Mail {
    
    static let sharedMail = Mail()
    
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
    
    func fetchMessageHeaders(count: Int, completionHandler: (NSError?, [AnyObject]?, MCOIndexSet?) -> Void) {
        
        fetchFolderInfo { (error, info) -> Void in
            
            guard error == nil else {
                print("error downloading message headers")
                print(error)
                fatalError()
            }
            
            let numberOfMessages: UInt64 = UInt64(count)
            let numbers = MCOIndexSet(range: MCORangeMake(UInt64(info!.messageCount) - numberOfMessages, numberOfMessages))
            let fetchOperation = self.session.fetchMessagesOperationWithFolder(self.folder, requestKind: .Headers, uids: numbers)
    
            fetchOperation.start(completionHandler)
        }
    }
    
    func getEmailHeaders(completionHandler: [MCOIMAPMessage]! -> Void) {
        
        fetchMessageHeaders(50) { error, messages, vanishedMessages in
            print("operation callback")
            
            guard error == nil else {
                print("error downloading message headers")
                print(error)
                fatalError()
            }
            
            print("the post man delivereth")
            print(messages)
            
            let imapMessages = messages as! [MCOIMAPMessage]
            completionHandler(imapMessages)
        }
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