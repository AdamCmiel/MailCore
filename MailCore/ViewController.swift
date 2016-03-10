//
//  ViewController.swift
//  MailCore
//
//  Created by Adam Cmiel on 1/9/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GIDSignInUIDelegate, GIDSignInDelegate {
    var emails: [MCOIMAPMessage] = []
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let creds = try GmailSession.sharedSession.creds()
            loadEmail(creds: creds)
        } catch {
            let GIDSignInSharedInstance = GIDSignIn.sharedInstance()
            GIDSignInSharedInstance.uiDelegate = self
            GIDSignInSharedInstance.delegate = self
            GIDSignInSharedInstance.signIn()
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
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
            if (error == nil) {
                // Perform any operations on signed in user here.
                let userId = user.userID                  // For client-side use only!
                let accessToken = user.authentication.accessToken // Safe to send to the server
                let name = user.profile.name
                let email = user.profile.email
                
                let gmailCreds = GmailCreds(userId: userId, accessToken: accessToken, name: name, email: email)
                gmailCreds.saveToStorage()
                self.loadEmail(creds: gmailCreds)
            } else {
                print("\(error.localizedDescription)")
            }
    }
}
