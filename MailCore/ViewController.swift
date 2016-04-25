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
    var emails: [Email] = []
    var refresher = UIRefreshControl()
    var loginRetries = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func logout(sender: AnyObject) {
        GmailCreds.clearStorage()
        Mail.sharedMail = Mail()
    GTMOAuth2ViewControllerTouch.removeAuthFromKeychainForName("googleKeychain")
        emails = []
        reload()
        loginAndFetchEmail()
    }
    
    @IBAction func refresh(sender: AnyObject) {
        Mail.sharedMail.getEmailHeaders({ headers in
            self.messagesDidFetchWithHeaders(headers)
        }, errorHandler: { error in
            print(error)
            
            do {
                let creds = try GmailSession.sharedSession.creds()
                self.messagesDidFetchWithHeaders(Email.all(limit: 100))
            } catch {
                if self.loginRetries < 3 {
                    self.loginRetries += 1
                    self.logout(self)
                    self.loginAndFetchEmail()
                } else {
                    fatalError()
                }
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        refresher.attributedTitle = NSAttributedString(string: "Get them emails")
        refresher.addTarget(self, action: #selector(ViewController.refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refresher)
        
        loginAndFetchEmail()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    func loginAndFetchEmail() {
        do {
            let creds = try GmailSession.sharedSession.creds()
            loadEmail(creds: creds)
        } catch {
            signIn()
        }
    }
    
    func messagesDidFetchWithHeaders(emails: [Email]) {
        self.emails = emails
        self.reload()
        self.refresher.endRefreshing()
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
        cell.textLabel!.text = email.subject
        cell.textLabel?.textColor = email.read ? UIColor.blackColor() :UIColor.blueColor().colorWithAlphaComponent(0.4)
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let email = emails[indexPath.row]
        cell.textLabel?.textColor = email.read ? UIColor.blackColor() :UIColor.blueColor().colorWithAlphaComponent(0.4)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let email = emails[indexPath.row]
        email.setValue(true, forKey: "read")
        
        AppDelegate.thatDelegate.saveContext()
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            self.tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
            cell.setSelected(false, animated: true)
        }
        
        performSegueWithIdentifier("showWebViewController", sender: email)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is WebViewViewController {
            let webViewController = segue.destinationViewController as! WebViewViewController
            let email = sender as! Email
            
            webViewController.email = email
        }
        else {
            fatalError()
        }
    }
    
    func loadEmail(creds creds: GmailCreds) {
        Mail.sharedMail.session.username = creds.email
        Mail.sharedMail.session.OAuth2Token = creds.accessToken
        
        refresher.beginRefreshing()
        refresh(self)
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
            poorNetworkAlert("There was an error refreshing the session", sender: self, completionHandler: nil)
            
            return
        }
        
        windowController(nil, finishedWithAuth: auth, error: error)
    }
    
    func windowController(windowController: GTMOAuth2ViewControllerTouch?, finishedWithAuth auth: GTMOAuth2Authentication, error: NSError?) {
        
        guard error == nil else {
            if let windowController = windowController {
                windowController.dismissViewControllerAnimated(true) {
                    print("window controller dismissed")
                }
            }
            poorNetworkAlert("There was an error finishing the authentication", sender: self, completionHandler: nil)
            return
        }
        
        if let windowController = windowController {
            windowController.dismissViewControllerAnimated(true) {
                print("window controller dismissed")
            }
        }
        
        let userID = auth.userID
        let access = auth.accessToken
        let email = auth.userEmail
        
        let gmailCreds = GmailCreds(userId: userID, accessToken: access, name: "", email: email)
        gmailCreds.saveToStorage()
        loadEmail(creds: gmailCreds)
    }
}
