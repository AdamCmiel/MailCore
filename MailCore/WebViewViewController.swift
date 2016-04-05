//
//  WebViewViewController.swift
//  MailCore
//
//  Created by Adam Cmiel on 1/19/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController, WKNavigationDelegate {
    var uid: UInt64?
    var email: MCOIMAPMessage?
    
    var indicator: UIActivityIndicatorView?
    
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
        
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        if let indicator = indicator {
            indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
            indicator.center = self.view.center
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        }
        
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
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("starting navigation")
        
        indicator?.startAnimating()
        
        if let indicator = indicator {
            if indicator.superview == nil {
                self.view.addSubview(indicator)
                self.view.bringSubviewToFront(indicator)
            }
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        print("finished navigation")
        
        indicator?.stopAnimating()
        indicator?.removeFromSuperview()
    }
}
