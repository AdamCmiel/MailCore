//
//  WebViewViewController.swift
//  MailCore
//
//  Created by Adam Cmiel on 1/19/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController, WKNavigationDelegate, UIWebViewDelegate {
    var uid: UInt64?
    var email: MCOIMAPMessage?
    
    lazy var webView: WKWebView = {
        let wv = WKWebView(frame: self.view.bounds)
        wv.navigationDelegate = self
        return wv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem?.title = "Inbox"
        navigationItem.title = email?.header.subject
        
        self.view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[webView]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["webView": webView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[webView]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["webView": webView]))
        
        Mail.sharedMail.emailHTML(email!) { html in
            print(html)
            self.webView.loadHTMLString(html, baseURL: nil)
        }
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        if navigationAction.navigationType == .LinkActivated {
            UIApplication.sharedApplication().openURL(navigationAction.request.URL!)
            decisionHandler(.Cancel)
        } else{
            decisionHandler(.Allow)
        }
    }
}
