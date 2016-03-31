//
//  ViewController.swift
//  MailCore
//
//  Created by Adam Cmiel on 1/9/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import UIKit
import GTMOAuth2
import GTMSessionFetcher

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var emails: [MCOIMAPMessage] = []
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let creds = try GmailSession.sharedSession.creds()
            loadEmail(creds: creds)
        } catch {
            signIn()
        }
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func reload() {
        tableView.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emails.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let email = emails[indexPath.row]
        cell.textLabel!.text = email.header.subject
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let email = emails[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.setSelected(false, animated: true)
        performSegueWithIdentifier("showWebViewController", sender: email)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is WebViewViewController {
            let webViewController = segue.destinationViewController as! WebViewViewController
            let email = sender as! MCOIMAPMessage
            
            webViewController.email = email
        }
        else {
            fatalError()
        }
    }
    
    func loadEmail(creds creds: GmailCreds) {
        Mail.sharedMail.session.username = creds.email
        Mail.sharedMail.session.OAuth2Token = creds.accessToken
        
        Mail.sharedMail.getEmailHeaders { emailHeaders in
            self.emails = emailHeaders
            self.reload()
        }
    }
    
    func signIn() {
        
        let scope = "https://mail.google.com"
        let clientID = Info["GMAIL_CLIENT_ID"] as! String
        let clientSecret = Info["GMAIL_SECRET"] as! String
        
        let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName("googleKeychain", clientID: clientID, clientSecret: clientSecret)
        
        if auth.refreshToken == nil {
            let windowController = GTMOAuth2ViewControllerTouch(scope: scope, clientID: clientID, clientSecret: clientSecret, keychainItemName: "googleKeychain", delegate: self, finishedSelector: #selector(ViewController.windowController(_:finishedWithAuth:error:)))
            
            presentViewController(windowController, animated: true, completion: {
                print("presented")
            })
            
        } else {
            auth.beginTokenFetchWithDelegate(self, didFinishSelector: #selector(ViewController.auth(_:finishedRefreshWithFetcher:error:)))
        }
            
    }
    
    func auth(auth: GTMOAuth2Authentication, finishedRefreshWithFetcher fetcher: GTMSessionFetcher, error: NSError?) {
        
        guard error == nil else {
            fatalError("there was an error refreshing the session")
        }
        
        windowController(nil, finishedWithAuth: auth, error: error)
    }
    
    func windowController(windowController: GTMOAuth2ViewControllerTouch?, finishedWithAuth auth: GTMOAuth2Authentication, error: NSError?) {
        
        guard error == nil else {
            fatalError("there was an error finishing the authentication")
        }
        
        let userID = auth.userID
        let access = auth.accessToken
        let email = auth.userEmail
        
        let gmailCreds = GmailCreds(userId: userID, accessToken: access, name: "", email: email)
        gmailCreds.saveToStorage()
        loadEmail(creds: gmailCreds)
    }
}
