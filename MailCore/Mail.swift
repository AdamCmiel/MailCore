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
    
    private static let kGmailIMAPHostnameKey = "GmailIMAPHostname"
    private static let kGmailIMAPFolderKey = "GmailIMAPFolder"
    private static let kGmailIMAPPortKey = "GmailIMAPPort"
    
    private var folder: String {
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
    
    private func fetchFolderInfo(completionHandler: (NSError?, MCOIMAPFolderInfo?) -> Void) {
        session.folderInfoOperation(folder).start(completionHandler)
    }
    
    private func fetchMessageHeaders(count: Int, completionHandler: (NSError?, [AnyObject]?, MCOIndexSet?) -> Void, errorHandler: ErrorType -> Void) {
        
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
    func getEmailHeaders(completionHandler: [Email] -> Void, errorHandler: ErrorType -> Void) {
        getEmailHeaders(50, completionHandler: completionHandler, errorHandler: errorHandler)
    }
    
    /**
     
     Gets n emails
     
     - Parameter count: number of emails
     
     - Parameter completionHandler: callback with email
     
    */
    func getEmailHeaders(count: Int, completionHandler: [Email] -> Void, errorHandler: ErrorType -> Void) {
        
        fetchMessageHeaders(count, completionHandler: { error, messages, vanishedMessages in
            print("operation callback")
            
            guard error == nil else {
                print("error downloading message headers")
                print(error)
                fatalError()
            }
            
            let imapMessages = messages as! [MCOIMAPMessage]
            print("fetched \(imapMessages.count) messages")
            completionHandler(imapMessages.mapToEmails())
        }, errorHandler: errorHandler)
    }
    
    private func getEmailData(email: Email, completionHandler: NSData -> Void) {
        let f = folder
        let emailUID = UInt32(email.uid!.intValue)
        let messageDownloadOperation = session.fetchMessageOperationWithFolder(f, uid: emailUID)
        
        messageDownloadOperation.start { (error, messageData) -> Void in
            
            guard error == nil else {
                print("error downloading email body")
                print(error)
                return
            }
            
            completionHandler(messageData!)
        }
    }
    
    /**
 
    Renders the IMAP email into HTML to be viewed in a WebView
 
    - Parameter message: the message record to look up
 
    - Parameter completionHandler: have email, will call back
 
    */
    func emailHTML(email: Email, completionHandler: String -> Void) {
        
        let emailFilePath = email.filePath()
        if let file = Files.get(emailFilePath) {
            return completionHandler(file)
        }
        
        getEmailData(email) { data in
            let messageParser = MCOMessageParser(data: data)
            let htmlString = messageParser.htmlRenderingWithDelegate(nil)
            let didSave = Files.store(htmlString, withIdentifier: emailFilePath)
            if !didSave {
                print("error saving file \(emailFilePath)")
            }
            completionHandler(htmlString)
        }
    }
}